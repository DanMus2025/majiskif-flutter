import asyncio
import json
from collections import defaultdict

from fastapi import Depends, FastAPI, HTTPException, Query, WebSocket, WebSocketDisconnect, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy import text
from sqlalchemy.orm import Session

from .database import Base, engine, ensure_schema_extensions, get_db
from .models import SyncOperation, TenantUser
from .schemas import (
    CloudActivationRequest,
    CloudAuthResponse,
    CloudBootstrapResponse,
    CloudBranchOut,
    CloudDeviceOut,
    CloudLicenseOut,
    CloudLoginRequest,
    CloudTenantOut,
    CloudUserOut,
    CreatorAuthRequest,
    CreatorAuthResponse,
    CreatorLicenseResetResponse,
    CreatorLicenseDeleteResponse,
    CreatorProfileUpdateRequest,
    CreatorLicenseUpdateRequest,
    CreatorTenantOverview,
    CreatorTenantsResponse,
    SyncOperationOut,
    SyncPullResponse,
    SyncPushRequest,
    SyncPushResponse,
    TenantCreateRequest,
    TenantCreateResponse,
)
from .security import decode_token
from .service import (
    activate_cloud_user,
    bootstrap_cloud_context,
    creator_list_tenants,
    create_tenant_environment,
    current_creator_username,
    delete_creator_license,
    get_cloud_session_user,
    login_cloud_user,
    pull_sync_operations,
    push_sync_operations,
    update_creator_credentials,
    update_creator_license,
    reset_creator_license,
    verify_creator_credentials,
)
from .config import settings
from .security import create_creator_access_token

app = FastAPI(title="KESE Cloud API", version="1.0.0")
oauth2_cloud_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/cloud/login")
oauth2_creator_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/cloud/creator/auth")

Base.metadata.create_all(bind=engine)
ensure_schema_extensions()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class TenantRealtimeHub:
    def __init__(self):
        self._connections: dict[int, set[WebSocket]] = defaultdict(set)
        self._lock = asyncio.Lock()

    async def connect(self, tenant_id: int, websocket: WebSocket):
        await websocket.accept()
        async with self._lock:
            self._connections[tenant_id].add(websocket)

    async def disconnect(self, tenant_id: int, websocket: WebSocket):
        async with self._lock:
            peers = self._connections.get(tenant_id)
            if not peers:
                return
            peers.discard(websocket)
            if not peers:
                self._connections.pop(tenant_id, None)

    async def broadcast(self, tenant_id: int, payload: dict):
        async with self._lock:
            peers = list(self._connections.get(tenant_id, set()))
        stale: list[WebSocket] = []
        for websocket in peers:
            try:
                await websocket.send_text(json.dumps(payload))
            except Exception:
                stale.append(websocket)
        for websocket in stale:
            await self.disconnect(tenant_id, websocket)


realtime_hub = TenantRealtimeHub()


def operation_out(item: SyncOperation) -> SyncOperationOut:
    return SyncOperationOut(
        id=item.id,
        operation_uid=item.operation_uid,
        entity_name=item.entity_name,
        entity_id=item.entity_id,
        operation_name=item.operation_name,
        payload_json=item.payload_json,
        payload_hash=item.payload_hash,
        sync_status=item.sync_status,
        conflict_reason=item.conflict_reason,
        created_at=item.created_at,
    )


def current_cloud_user(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_cloud_scheme),
) -> TenantUser:
    payload = decode_token(token)
    if not payload or not payload.get("cloud") or not payload.get("sub") or not payload.get("jti"):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Jeton cloud invalide")
    tenant_id = int(payload.get("tenant_id") or 0)
    user_id = int(payload["sub"])
    return get_cloud_session_user(db, user_id=user_id, tenant_id=tenant_id, token_jti=payload["jti"])


def current_cloud_socket_identity(token: str) -> tuple[int, int]:
    payload = decode_token(token)
    if not payload or not payload.get("cloud") or not payload.get("sub") or not payload.get("jti"):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Jeton cloud invalide")
    tenant_id = int(payload.get("tenant_id") or 0)
    user_id = int(payload["sub"])
    if tenant_id <= 0 or user_id <= 0:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Jeton cloud invalide")
    return tenant_id, user_id


def current_creator_identity(
    token: str = Depends(oauth2_creator_scheme),
) -> str:
    payload = decode_token(token)
    if not payload or not payload.get("creator") or not payload.get("sub"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Jeton créateur invalide",
    )
    username = str(payload["sub"]).strip()
    if username.lower() != current_creator_username().strip().lower():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Jeton créateur invalide",
        )
    return username


@app.get("/health")
def health(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Base de données cloud indisponible",
        )
    return {
        "status": "ok",
        "app": "KESE Cloud API",
        "database": "ok",
        "database_engine": engine.url.get_backend_name(),
        "persistent_database": engine.url.get_backend_name() != "sqlite",
    }


@app.post("/api/v1/cloud/creator/auth", response_model=CreatorAuthResponse)
def creator_auth(payload: CreatorAuthRequest):
    if not verify_creator_credentials(payload.username, payload.pin):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Accès créateur refusé",
        )
    access_token, _jti, expires_at = create_creator_access_token(
        payload.username.strip()
    )
    return CreatorAuthResponse(
        access_token=access_token,
        expires_at=expires_at,
        username=payload.username.strip(),
    )


@app.put("/api/v1/cloud/creator/profile", response_model=CreatorAuthResponse)
def creator_update_profile(
    payload: CreatorProfileUpdateRequest,
    _creator: str = Depends(current_creator_identity),
):
    username = update_creator_credentials(
        current_pin=payload.current_pin,
        username=payload.username,
        pin=payload.pin,
    )
    access_token, _jti, expires_at = create_creator_access_token(username)
    return CreatorAuthResponse(
        access_token=access_token,
        expires_at=expires_at,
        username=username,
    )


@app.post("/api/v1/cloud/tenants", response_model=TenantCreateResponse, status_code=status.HTTP_201_CREATED)
def create_tenant(
    payload: TenantCreateRequest,
    db: Session = Depends(get_db),
    _creator: str = Depends(current_creator_identity),
):
    tenant, branch, admin_user, license_record = create_tenant_environment(db, payload)
    return TenantCreateResponse(
        tenant=CloudTenantOut.model_validate(tenant, from_attributes=True),
        branch=CloudBranchOut.model_validate(branch, from_attributes=True),
        admin_user=CloudUserOut.model_validate(admin_user, from_attributes=True),
        license=CloudLicenseOut.model_validate(license_record, from_attributes=True),
        activation_hint={
            "tenant_key": tenant.tenant_key,
            "license_code": license_record.license_code,
            "admin_username": admin_user.username,
        },
    )


@app.get("/api/v1/cloud/creator/tenants", response_model=CreatorTenantsResponse)
def creator_tenants(
    db: Session = Depends(get_db),
    _creator: str = Depends(current_creator_identity),
):
    items = creator_list_tenants(db)
    return CreatorTenantsResponse(
        total=len(items),
        items=[
            CreatorTenantOverview(
                tenant=CloudTenantOut.model_validate(item["tenant"], from_attributes=True),
                branch=CloudBranchOut.model_validate(item["branch"], from_attributes=True),
                license=CloudLicenseOut.model_validate(item["license"], from_attributes=True),
                users_count=item["users_count"],
                devices_count=item["devices_count"],
                active_devices_count=item["active_devices_count"],
                first_activation_done=item["first_activation_done"],
                last_activity_at=item["last_activity_at"],
            )
            for item in items
        ],
    )


@app.patch("/api/v1/cloud/creator/licenses/{license_id}", response_model=CloudLicenseOut)
def creator_update_license(
    license_id: int,
    payload: CreatorLicenseUpdateRequest,
    db: Session = Depends(get_db),
    _creator: str = Depends(current_creator_identity),
):
    license_record = update_creator_license(
        db,
        license_id=license_id,
        license_code=payload.license_code,
        license_status=payload.status,
        plan_code=payload.plan_code,
        license_duration=payload.license_duration,
        max_devices=payload.max_devices,
        max_users=payload.max_users,
        cloud_base_url=payload.cloud_base_url,
    )
    return CloudLicenseOut.model_validate(license_record, from_attributes=True)


@app.post("/api/v1/cloud/creator/licenses/{license_id}/reset", response_model=CreatorLicenseResetResponse)
def creator_reset_license(
    license_id: int,
    db: Session = Depends(get_db),
    _creator: str = Depends(current_creator_identity),
):
    license_record, revoked_sessions, disabled_devices = reset_creator_license(db, license_id=license_id)
    return CreatorLicenseResetResponse(
        license=CloudLicenseOut.model_validate(license_record, from_attributes=True),
        revoked_sessions=revoked_sessions,
        disabled_devices=disabled_devices,
    )


@app.delete("/api/v1/cloud/creator/licenses/{license_id}", response_model=CreatorLicenseDeleteResponse)
def creator_delete_license(
    license_id: int,
    db: Session = Depends(get_db),
    _creator: str = Depends(current_creator_identity),
):
    return CreatorLicenseDeleteResponse(**delete_creator_license(db, license_id=license_id))


@app.post("/api/v1/cloud/activate", response_model=CloudAuthResponse)
def activate(payload: CloudActivationRequest, db: Session = Depends(get_db)):
    tenant, branch, user, device, license_record, access_token, expires_at = activate_cloud_user(db, payload)
    return CloudAuthResponse(
        access_token=access_token,
        expires_at=expires_at,
        tenant=CloudTenantOut.model_validate(tenant, from_attributes=True),
        branch=CloudBranchOut.model_validate(branch, from_attributes=True),
        user=CloudUserOut.model_validate(user, from_attributes=True),
        device=CloudDeviceOut.model_validate(device, from_attributes=True),
        license=CloudLicenseOut.model_validate(license_record, from_attributes=True),
    )


@app.post("/api/v1/cloud/login", response_model=CloudAuthResponse)
def login(payload: CloudLoginRequest, db: Session = Depends(get_db)):
    tenant, branch, user, device, license_record, access_token, expires_at = login_cloud_user(db, payload)
    return CloudAuthResponse(
        access_token=access_token,
        expires_at=expires_at,
        tenant=CloudTenantOut.model_validate(tenant, from_attributes=True),
        branch=CloudBranchOut.model_validate(branch, from_attributes=True),
        user=CloudUserOut.model_validate(user, from_attributes=True),
        device=CloudDeviceOut.model_validate(device, from_attributes=True),
        license=CloudLicenseOut.model_validate(license_record, from_attributes=True),
    )


@app.get("/api/v1/cloud/bootstrap", response_model=CloudBootstrapResponse)
def bootstrap(user: TenantUser = Depends(current_cloud_user), db: Session = Depends(get_db)):
    tenant, branch, license_record, devices, users = bootstrap_cloud_context(db, user)
    return CloudBootstrapResponse(
        tenant=CloudTenantOut.model_validate(tenant, from_attributes=True),
        branch=CloudBranchOut.model_validate(branch, from_attributes=True),
        user=CloudUserOut.model_validate(user, from_attributes=True),
        devices=[CloudDeviceOut.model_validate(item, from_attributes=True) for item in devices],
        users=[CloudUserOut.model_validate(item, from_attributes=True) for item in users],
        license=CloudLicenseOut.model_validate(license_record, from_attributes=True),
    )


@app.post("/api/v1/cloud/sync/push", response_model=SyncPushResponse)
async def sync_push(
    payload: SyncPushRequest,
    user: TenantUser = Depends(current_cloud_user),
    db: Session = Depends(get_db),
):
    stored, ignored, conflicts = push_sync_operations(
        db,
        user=user,
        device_uuid=payload.device_uuid,
        operations=payload.operations,
    )
    accepted = [item for item in stored if item.sync_status == "accepted"]
    if accepted:
        await realtime_hub.broadcast(
            user.tenant_id,
            {
                "type": "sync_available",
                "tenant_id": user.tenant_id,
                "count": len(accepted),
            },
        )
    return SyncPushResponse(
        accepted=len(accepted),
        ignored=ignored,
        conflicts=conflicts,
        operations=[operation_out(item) for item in stored],
    )


@app.get("/api/v1/cloud/sync/pull", response_model=SyncPullResponse)
def sync_pull(
    after_id: int = Query(default=0, ge=0),
    limit: int = Query(default=200, ge=1, le=1000),
    user: TenantUser = Depends(current_cloud_user),
    db: Session = Depends(get_db),
):
    operations = pull_sync_operations(db, user=user, after_id=after_id, limit=limit)
    cursor = operations[-1].id if operations else after_id
    return SyncPullResponse(
        cursor=cursor,
        operations=[operation_out(item) for item in operations],
    )


@app.websocket("/api/v1/cloud/ws")
async def cloud_ws(websocket: WebSocket, token: str = Query(default="")):
    try:
        tenant_id, _user_id = current_cloud_socket_identity(token)
    except HTTPException:
        await websocket.close(code=4401)
        return
    await realtime_hub.connect(tenant_id, websocket)
    try:
        while True:
            await asyncio.sleep(25)
            await websocket.send_text(json.dumps({"type": "ping"}))
    except WebSocketDisconnect:
        await realtime_hub.disconnect(tenant_id, websocket)
    except Exception:
        await realtime_hub.disconnect(tenant_id, websocket)



