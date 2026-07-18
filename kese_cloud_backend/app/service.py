import json
import re
from datetime import datetime, timedelta
from pathlib import Path
from uuid import uuid4

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from .models import (
    CloudSessionToken,
    SyncOperation,
    Tenant,
    TenantBranch,
    TenantDevice,
    TenantLicense,
    TenantUser,
)
from .config import settings
from .schemas import CloudActivationRequest, CloudLoginRequest, SyncOperationIn, TenantCreateRequest
from .security import create_access_token, hash_pin, utcnow, verify_pin

_CREATOR_CREDENTIALS_PATH = (
    Path(__file__).resolve().parents[1] / "data" / "creator_credentials.json"
)


def normalize_username(value: str) -> str:
    return value.strip().lower()


def normalize_license_code(value: str) -> str:
    normalized = value.strip().upper()
    normalized = re.sub(r"\s+", "", normalized)
    normalized = normalized.replace("–", "-").replace("—", "-")
    normalized = re.sub(r"-+", "-", normalized)
    return normalized.strip("-")


def normalize_tenant_key(value: str) -> str:
    return value.strip().lower()


def slugify(value: str) -> str:
    lowered = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return lowered or "tenant"


def generate_tenant_key(db: Session, company_name: str) -> str:
    base = slugify(company_name)[:32]
    candidate = base
    index = 1
    while db.scalar(select(Tenant.id).where(Tenant.tenant_key == candidate)):
        index += 1
        candidate = f"{base}-{index}"
    return candidate


def generate_branch_code(name: str) -> str:
    return slugify(name).replace("-", "_")[:24] or "main_branch"


def generate_license_code_candidate() -> str:
    return f"KESE-{uuid4().hex[:6].upper()}-{uuid4().hex[:6].upper()}-{uuid4().hex[:4].upper()}"


def generate_unique_license_code(db: Session) -> str:
    for _ in range(20):
        candidate = generate_license_code_candidate()
        exists = db.scalar(
            select(TenantLicense.id).where(TenantLicense.license_code == candidate)
        )
        if not exists:
            return candidate
    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Impossible de générer une licence unique",
    )


def normalize_cloud_base_url(value: str | None) -> str | None:
    if value is None:
        return None
    normalized = value.strip()
    if not normalized:
        return None
    if not normalized.startswith(("http://", "https://")):
        normalized = f"http://{normalized}"
    normalized = normalized.rstrip("/")
    if not normalized.endswith("/api/v1/cloud"):
        if normalized.endswith("/api/v1"):
            normalized = f"{normalized}/cloud"
        elif normalized.endswith("/cloud"):
            pass
        else:
            normalized = f"{normalized}/api/v1/cloud"
    return normalized


def normalize_license_duration(value: str) -> str:
    normalized = value.strip().lower()
    if normalized in {"trial-24h", "trial_24h", "24h", "essai-24h", "essai24h"}:
        return "trial-24h"
    if normalized in {"1y", "1-year", "1_year", "1an", "1-annee", "1-ans"}:
        return "1y"
    if normalized in {"2y", "2-years", "2_years", "2ans", "2-annees"}:
        return "2y"
    if normalized in {"5y", "5-years", "5_years", "5ans", "5-annees"}:
        return "5y"
    if normalized in {"indefinite", "illimitee", "illimite", "perpetuelle", "unlimited"}:
        return "indefinite"
    return "1y"


def compute_license_expiry(duration_code: str) -> datetime | None:
    code = normalize_license_duration(duration_code)
    now = utcnow()
    if code == "trial-24h":
        return now + timedelta(hours=24)
    if code == "1y":
        return now + timedelta(days=365)
    if code == "2y":
        return now + timedelta(days=365 * 2)
    if code == "5y":
        return now + timedelta(days=365 * 5)
    return None


def build_plan_code(plan_code: str, duration_code: str) -> str:
    base_plan = plan_code.strip() or "standard"
    return f"{base_plan}@{normalize_license_duration(duration_code)}"


def parse_plan_and_duration(plan_code: str) -> tuple[str, str]:
    raw = plan_code.strip()
    if "@" not in raw:
        return raw or "standard", "1y"
    base_plan, duration_code = raw.split("@", 1)
    return base_plan.strip() or "standard", normalize_license_duration(duration_code)


def normalize_role_name(value: str) -> str:
    normalized = value.strip().lower()
    if normalized == "admin":
        return "admin"
    if normalized in {"gestionnaire", "manager"}:
        return "manager"
    return "cashier"


def _read_creator_credentials() -> dict[str, str]:
    defaults = {
        "username": settings.creator_username.strip() or "creator",
        "pin": settings.creator_pin,
        "hashed_pin": "",
    }
    if not _CREATOR_CREDENTIALS_PATH.exists():
        return defaults
    try:
        payload = json.loads(_CREATOR_CREDENTIALS_PATH.read_text(encoding="utf-8"))
    except Exception:
        return defaults
    username = str(
        payload.get("username", defaults["username"]),
    ).strip() or defaults["username"]
    hashed_pin = str(payload.get("hashed_pin", "")).strip()
    plain_pin = str(payload.get("pin", "")).strip()
    return {
        "username": username,
        "pin": plain_pin or defaults["pin"],
        "hashed_pin": hashed_pin,
    }


def _write_creator_credentials(*, username: str, pin: str) -> str:
    _CREATOR_CREDENTIALS_PATH.parent.mkdir(parents=True, exist_ok=True)
    normalized_username = username.strip() or "creator"
    _CREATOR_CREDENTIALS_PATH.write_text(
        json.dumps(
            {
                "username": normalized_username,
                "hashed_pin": hash_pin(pin.strip()),
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )
    return normalized_username


def current_creator_username() -> str:
    return _read_creator_credentials()["username"].strip()


def _verify_creator_pin(pin: str, record: dict[str, str]) -> bool:
    candidate = pin.strip()
    hashed_pin = record.get("hashed_pin", "").strip()
    if hashed_pin:
        try:
            return verify_pin(candidate, hashed_pin)
        except Exception:
            return False
    return candidate == record.get("pin", "").strip()


def verify_creator_credentials(username: str, pin: str) -> bool:
    record = _read_creator_credentials()
    expected_username = normalize_username(record["username"])
    return (
        normalize_username(username) == expected_username
        and _verify_creator_pin(pin, record)
    )


def update_creator_credentials(
    *,
    current_pin: str,
    username: str,
    pin: str,
) -> str:
    record = _read_creator_credentials()
    if not _verify_creator_pin(current_pin, record):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Code secret créateur actuel invalide",
        )
    next_username = username.strip()
    next_pin = pin.strip()
    if len(next_username) < 3:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Identifiant créateur invalide",
        )
    if len(next_pin) < 4:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Code secret créateur invalide",
        )
    return _write_creator_credentials(username=next_username, pin=next_pin)


def create_tenant_environment(db: Session, payload: TenantCreateRequest):
    license_duration = normalize_license_duration(payload.license_duration)
    tenant = Tenant(
        tenant_key=generate_tenant_key(db, payload.company_name),
        company_name=payload.company_name.strip(),
        cloud_base_url=normalize_cloud_base_url(payload.cloud_base_url),
        owner_name=payload.owner_name.strip() if payload.owner_name else None,
        phone=payload.phone.strip() if payload.phone else None,
        email=payload.email.strip() if payload.email else None,
        address=payload.address.strip() if payload.address else None,
        is_active=True,
    )
    db.add(tenant)
    db.flush()

    branch = TenantBranch(
        tenant_id=tenant.id,
        branch_code=generate_branch_code(payload.branch_name),
        branch_name=payload.branch_name.strip(),
        address=tenant.address,
        is_main=True,
    )
    db.add(branch)
    db.flush()

    admin_user = TenantUser(
        tenant_id=tenant.id,
        branch_id=branch.id,
        username=payload.admin_username.strip(),
        username_normalized=normalize_username(payload.admin_username),
        full_name=payload.admin_full_name.strip(),
        role="admin",
        hashed_pin=hash_pin(payload.admin_pin.strip()),
        is_blocked=False,
    )
    db.add(admin_user)

    license_record = TenantLicense(
        tenant_id=tenant.id,
        license_code=generate_unique_license_code(db),
        plan_code=build_plan_code(payload.plan_code, license_duration),
        status="active",
        max_devices=payload.max_devices,
        max_users=payload.max_users,
        expires_at=compute_license_expiry(license_duration),
    )
    db.add(license_record)
    db.commit()
    db.refresh(tenant)
    db.refresh(branch)
    db.refresh(admin_user)
    db.refresh(license_record)
    return tenant, branch, admin_user, license_record


def active_license_for_tenant(db: Session, tenant_id: int) -> TenantLicense:
    license_record = db.scalar(
        select(TenantLicense)
        .where(TenantLicense.tenant_id == tenant_id)
        .order_by(TenantLicense.created_at.desc())
        .limit(1)
    )
    if not license_record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Licence introuvable")
    if license_record.status != "active":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Licence inactive")
    if license_record.expires_at:
        expires_at = license_record.expires_at
        now = utcnow()
        if expires_at.tzinfo is not None:
            expires_at = expires_at.replace(tzinfo=None)
        if now.tzinfo is not None:
            now = now.replace(tzinfo=None)
        if expires_at < now:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Licence expirée",
            )
    return license_record


def ensure_license_is_usable(license_record: TenantLicense) -> TenantLicense:
    if license_record.status != "active":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Licence inactive")
    if license_record.expires_at:
        expires_at = license_record.expires_at
        now = utcnow()
        if expires_at.tzinfo is not None:
            expires_at = expires_at.replace(tzinfo=None)
        if now.tzinfo is not None:
            now = now.replace(tzinfo=None)
        if expires_at < now:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Licence expirée",
            )
    return license_record


def latest_license_for_tenant(db: Session, tenant_id: int) -> TenantLicense:
    license_record = db.scalar(
        select(TenantLicense)
        .where(TenantLicense.tenant_id == tenant_id)
        .order_by(TenantLicense.created_at.desc())
        .limit(1)
    )
    if not license_record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Licence introuvable",
        )
    return license_record


def revoke_tenant_runtime_access(db: Session, tenant_id: int) -> tuple[int, int]:
    devices = db.execute(
        select(TenantDevice).where(TenantDevice.tenant_id == tenant_id)
    ).scalars().all()
    disabled_devices = len([device for device in devices if device.is_active])
    for device in devices:
        device.is_active = False
        device.user_id = None
        device.last_seen_at = None
    user_ids = db.execute(
        select(TenantUser.id).where(TenantUser.tenant_id == tenant_id)
    ).scalars().all()
    revoked_sessions = 0
    if user_ids:
        revoked_sessions = db.query(CloudSessionToken).filter(
            CloudSessionToken.tenant_user_id.in_(user_ids),
            CloudSessionToken.is_revoked.is_(False),
        ).update(
            {CloudSessionToken.is_revoked: True},
            synchronize_session=False,
        )
    return revoked_sessions, disabled_devices


def require_tenant_user(db: Session, tenant_id: int, username: str) -> TenantUser:
    user = db.scalar(
        select(TenantUser).where(
            TenantUser.tenant_id == tenant_id,
            TenantUser.username_normalized == normalize_username(username),
        )
    )
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Identifiant introuvable")
    return user


def register_device(
    db: Session,
    *,
    tenant: Tenant,
    branch: TenantBranch,
    user: TenantUser,
    license_record: TenantLicense,
    device_uuid: str,
    device_label: str,
    platform_name: str,
    app_version: str | None,
) -> TenantDevice:
    device = db.scalar(
        select(TenantDevice).where(
            TenantDevice.tenant_id == tenant.id,
            TenantDevice.device_uuid == device_uuid.strip(),
        )
    )
    if not device or not device.is_active:
        active_count = db.scalar(
            select(func.count(TenantDevice.id)).where(
                TenantDevice.tenant_id == tenant.id,
                TenantDevice.is_active.is_(True),
            )
        ) or 0
        if active_count >= license_record.max_devices:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Limite d’appareils atteinte pour cette licence",
            )
    if not device:
        device = TenantDevice(
            tenant_id=tenant.id,
            branch_id=branch.id,
            user_id=user.id,
            device_uuid=device_uuid.strip(),
            device_label=device_label.strip(),
            platform_name=platform_name.strip(),
            app_version=app_version.strip() if app_version else None,
            last_seen_at=utcnow(),
            is_active=True,
        )
        db.add(device)
    else:
        device.branch_id = branch.id
        device.user_id = user.id
        device.device_label = device_label.strip()
        device.platform_name = platform_name.strip()
        device.app_version = app_version.strip() if app_version else None
        device.last_seen_at = utcnow()
        device.is_active = True
    return device


def create_cloud_session(db: Session, user: TenantUser, tenant: Tenant, device: TenantDevice):
    access_token, jti, expires_at = create_access_token(
        str(user.id),
        role=user.role,
        tenant_id=tenant.id,
        tenant_key=tenant.tenant_key,
        device_uuid=device.device_uuid,
    )
    db.add(
        CloudSessionToken(
            tenant_user_id=user.id,
            token_jti=jti,
            expires_at=expires_at,
            is_revoked=False,
        )
    )
    user.last_login_at = utcnow()
    return access_token, expires_at


def activate_cloud_user(db: Session, payload: CloudActivationRequest):
    license_code = normalize_license_code(payload.license_code)
    license_record = db.scalar(
        select(TenantLicense).where(TenantLicense.license_code == license_code)
    )
    if not license_record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Licence introuvable")
    tenant = db.get(Tenant, license_record.tenant_id)
    if not tenant or not tenant.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Entreprise inactive")
    ensure_license_is_usable(license_record)
    user = require_tenant_user(db, tenant.id, payload.username)
    if user.is_blocked:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Compte bloqué")
    if not verify_pin(payload.pin, user.hashed_pin):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Code secret invalide")
    branch = db.get(TenantBranch, user.branch_id) if user.branch_id else None
    if not branch:
        branch = db.scalar(
            select(TenantBranch).where(TenantBranch.tenant_id == tenant.id, TenantBranch.is_main.is_(True))
        )
    if not branch:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Branche introuvable")
    device = register_device(
        db,
        tenant=tenant,
        branch=branch,
        user=user,
        license_record=license_record,
        device_uuid=payload.device_uuid,
        device_label=payload.device_label,
        platform_name=payload.platform_name,
        app_version=payload.app_version,
    )
    if not license_record.activated_at:
        license_record.activated_at = utcnow()
    access_token, expires_at = create_cloud_session(db, user, tenant, device)
    db.commit()
    db.refresh(device)
    db.refresh(user)
    db.refresh(license_record)
    return tenant, branch, user, device, license_record, access_token, expires_at


def login_cloud_user(db: Session, payload: CloudLoginRequest):
    tenant = db.scalar(select(Tenant).where(Tenant.tenant_key == normalize_tenant_key(payload.tenant_key)))
    if not tenant or not tenant.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Entreprise introuvable")
    license_record = active_license_for_tenant(db, tenant.id)
    user = require_tenant_user(db, tenant.id, payload.username)
    if user.is_blocked:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Compte bloqué")
    if not verify_pin(payload.pin, user.hashed_pin):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Code secret invalide")
    branch = db.get(TenantBranch, user.branch_id) if user.branch_id else None
    if not branch:
        branch = db.scalar(
            select(TenantBranch).where(TenantBranch.tenant_id == tenant.id, TenantBranch.is_main.is_(True))
        )
    if not branch:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Branche introuvable")
    device = register_device(
        db,
        tenant=tenant,
        branch=branch,
        user=user,
        license_record=license_record,
        device_uuid=payload.device_uuid,
        device_label=payload.device_label,
        platform_name=payload.platform_name,
        app_version=payload.app_version,
    )
    access_token, expires_at = create_cloud_session(db, user, tenant, device)
    db.commit()
    db.refresh(device)
    db.refresh(user)
    return tenant, branch, user, device, license_record, access_token, expires_at


def get_cloud_session_user(db: Session, *, user_id: int, tenant_id: int, token_jti: str) -> TenantUser:
    session_record = db.scalar(select(CloudSessionToken).where(CloudSessionToken.token_jti == token_jti))
    if not session_record:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session cloud expirée")
    expires_at = session_record.expires_at
    now = utcnow()
    if expires_at.tzinfo is not None:
        expires_at = expires_at.replace(tzinfo=None)
    if now.tzinfo is not None:
        now = now.replace(tzinfo=None)
    if session_record.is_revoked or expires_at < now:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session cloud expirée")
    user = db.get(TenantUser, user_id)
    if not user or user.tenant_id != tenant_id or user.is_blocked:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Compte cloud inactif")
    tenant = db.get(Tenant, tenant_id)
    if not tenant or not tenant.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Entreprise inactive")
    active_license_for_tenant(db, tenant_id)
    return user


def bootstrap_cloud_context(db: Session, user: TenantUser):
    tenant = db.get(Tenant, user.tenant_id)
    branch = db.get(TenantBranch, user.branch_id) if user.branch_id else None
    if not tenant:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Entreprise introuvable")
    if not branch:
        branch = db.scalar(
            select(TenantBranch).where(TenantBranch.tenant_id == tenant.id, TenantBranch.is_main.is_(True))
        )
    if not branch:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Branche introuvable")
    license_record = active_license_for_tenant(db, tenant.id)
    devices = db.execute(
        select(TenantDevice).where(TenantDevice.tenant_id == tenant.id).order_by(TenantDevice.created_at.asc())
    ).scalars().all()
    users = db.execute(
        select(TenantUser).where(TenantUser.tenant_id == tenant.id).order_by(TenantUser.created_at.asc())
    ).scalars().all()
    return tenant, branch, license_record, devices, users


def creator_list_tenants(db: Session):
    tenants = db.execute(select(Tenant).order_by(Tenant.created_at.desc())).scalars().all()
    items = []
    for tenant in tenants:
        branch = db.scalar(
            select(TenantBranch).where(
                TenantBranch.tenant_id == tenant.id,
                TenantBranch.is_main.is_(True),
            )
        )
        if not branch:
            branch = db.scalar(
                select(TenantBranch)
                .where(TenantBranch.tenant_id == tenant.id)
                .order_by(TenantBranch.created_at.asc())
            )
        license_record = db.scalar(
            select(TenantLicense)
            .where(TenantLicense.tenant_id == tenant.id)
            .order_by(TenantLicense.created_at.desc())
            .limit(1)
        )
        if not license_record:
            continue
        users_count = (
            db.scalar(
                select(func.count(TenantUser.id)).where(TenantUser.tenant_id == tenant.id)
            )
            or 0
        )
        devices = db.execute(
            select(TenantDevice)
            .where(TenantDevice.tenant_id == tenant.id)
            .order_by(TenantDevice.created_at.desc())
        ).scalars().all()
        devices_count = len(devices)
        active_devices_count = len([item for item in devices if item.is_active])
        last_seen_candidates = [item.last_seen_at for item in devices if item.last_seen_at]
        users = db.execute(
            select(TenantUser)
            .where(TenantUser.tenant_id == tenant.id)
            .order_by(TenantUser.created_at.desc())
        ).scalars().all()
        last_login_candidates = [item.last_login_at for item in users if item.last_login_at]
        last_activity_at = max(
            [tenant.created_at, *last_seen_candidates, *last_login_candidates],
            default=tenant.created_at,
        )
        items.append(
            {
                "tenant": tenant,
                "branch": branch,
                "license": license_record,
                "users_count": users_count,
                "devices_count": devices_count,
                "active_devices_count": active_devices_count,
                "first_activation_done": license_record.activated_at is not None,
                "last_activity_at": last_activity_at,
            }
        )
    return items


def update_creator_license(
    db: Session,
    *,
    license_id: int,
    license_code: str | None = None,
    license_status: str | None = None,
    plan_code: str | None = None,
    license_duration: str | None = None,
    max_devices: int | None = None,
    max_users: int | None = None,
    cloud_base_url: str | None = None,
):
    license_record = db.get(TenantLicense, license_id)
    if not license_record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Licence introuvable",
        )
    current_plan, current_duration = parse_plan_and_duration(license_record.plan_code)
    next_plan = (plan_code or current_plan).strip() or "standard"
    next_duration = normalize_license_duration(license_duration or current_duration)
    if license_code is not None:
        next_code = normalize_license_code(license_code)
        if len(next_code) < 8:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Code licence invalide",
            )
        duplicate_id = db.scalar(
            select(TenantLicense.id).where(
                TenantLicense.license_code == next_code,
                TenantLicense.id != license_record.id,
            )
        )
        if duplicate_id:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Ce code licence existe déjà",
            )
        if next_code != license_record.license_code:
            license_record.license_code = next_code
            license_record.activated_at = None
            revoke_tenant_runtime_access(db, license_record.tenant_id)
    if license_status is not None:
        next_status = license_status.strip().lower()
        if next_status not in {"active", "suspended", "revoked"}:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Statut de licence invalide",
            )
        license_record.status = next_status
        if next_status != "active":
            revoke_tenant_runtime_access(db, license_record.tenant_id)
    if max_devices is not None:
        active_devices_count = (
            db.scalar(
                select(func.count(TenantDevice.id)).where(
                    TenantDevice.tenant_id == license_record.tenant_id,
                    TenantDevice.is_active.is_(True),
                )
            )
            or 0
        )
        if max_devices < active_devices_count:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="La limite d’appareils est inférieure aux appareils actifs",
            )
        license_record.max_devices = max_devices
    if max_users is not None:
        users_count = (
            db.scalar(
                select(func.count(TenantUser.id)).where(
                    TenantUser.tenant_id == license_record.tenant_id
                )
            )
            or 0
        )
        if max_users < users_count:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="La limite d’utilisateurs est inférieure aux comptes existants",
            )
        license_record.max_users = max_users
    if cloud_base_url is not None:
        tenant = db.get(Tenant, license_record.tenant_id)
        if not tenant:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Entreprise introuvable",
            )
        tenant.cloud_base_url = normalize_cloud_base_url(cloud_base_url)
    license_record.plan_code = build_plan_code(next_plan, next_duration)
    license_record.expires_at = compute_license_expiry(next_duration)
    db.commit()
    db.refresh(license_record)
    return license_record


def reset_creator_license(db: Session, *, license_id: int):
    license_record = db.get(TenantLicense, license_id)
    if not license_record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Licence introuvable",
        )
    tenant_id = license_record.tenant_id
    revoked_sessions, disabled_devices = revoke_tenant_runtime_access(db, tenant_id)
    license_record.activated_at = None
    db.commit()
    db.refresh(license_record)
    return license_record, revoked_sessions, disabled_devices


def delete_creator_license(db: Session, *, license_id: int):
    license_record = db.get(TenantLicense, license_id)
    if not license_record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Licence introuvable",
        )
    tenant_id = license_record.tenant_id
    tenant = db.get(Tenant, tenant_id)
    deleted_license_id = license_record.id
    user_ids = db.execute(
        select(TenantUser.id).where(TenantUser.tenant_id == tenant_id)
    ).scalars().all()
    deleted_sessions = 0
    if user_ids:
        deleted_sessions = db.query(CloudSessionToken).filter(
            CloudSessionToken.tenant_user_id.in_(user_ids)
        ).delete(synchronize_session=False)
    deleted_operations = db.query(SyncOperation).filter(
        SyncOperation.tenant_id == tenant_id
    ).delete(synchronize_session=False)
    deleted_devices = db.query(TenantDevice).filter(
        TenantDevice.tenant_id == tenant_id
    ).delete(synchronize_session=False)
    deleted_users = db.query(TenantUser).filter(
        TenantUser.tenant_id == tenant_id
    ).delete(synchronize_session=False)
    deleted_branches = db.query(TenantBranch).filter(
        TenantBranch.tenant_id == tenant_id
    ).delete(synchronize_session=False)
    deleted_licenses = db.query(TenantLicense).filter(
        TenantLicense.tenant_id == tenant_id
    ).delete(synchronize_session=False)
    if tenant is not None:
        db.query(Tenant).filter(Tenant.id == tenant_id).delete(
            synchronize_session=False
        )
    db.commit()
    return {
        "deleted_license_id": deleted_license_id,
        "deleted_tenant_id": tenant_id,
        "deleted_sessions": deleted_sessions,
        "deleted_operations": deleted_operations,
        "deleted_devices": deleted_devices,
        "deleted_users": deleted_users,
        "deleted_branches": deleted_branches,
        "deleted_licenses": deleted_licenses,
    }


def push_sync_operations(db: Session, *, user: TenantUser, device_uuid: str, operations: list[SyncOperationIn]):
    license_record = active_license_for_tenant(db, user.tenant_id)
    device = db.scalar(
        select(TenantDevice).where(
            TenantDevice.tenant_id == user.tenant_id,
            TenantDevice.device_uuid == device_uuid.strip(),
        )
    )
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Appareil cloud introuvable")
    if not device.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Appareil cloud désactivé")
    stored: list[SyncOperation] = []
    ignored = 0
    conflicts = 0
    for item in operations:
        existing = db.scalar(
            select(SyncOperation).where(
                SyncOperation.tenant_id == user.tenant_id,
                SyncOperation.operation_uid == item.operation_uid,
            )
        )
        if existing:
            ignored += 1
            continue
        operation = SyncOperation(
            tenant_id=user.tenant_id,
            branch_id=user.branch_id,
            device_id=device.id,
            user_id=user.id,
            operation_uid=item.operation_uid,
            entity_name=item.entity_name,
            entity_id=item.entity_id,
            operation_name=item.operation_name,
            payload_json=item.payload_json,
            payload_hash=item.payload_hash,
            sync_status="accepted",
            conflict_reason=None,
            created_at=item.created_at,
        )
        db.add(operation)
        db.flush()
        if item.operation_name in {"create", "upsert"} and item.entity_name not in {"category", "settings"}:
            existing_entity_operation = db.scalar(
                select(SyncOperation).where(
                    SyncOperation.tenant_id == user.tenant_id,
                    SyncOperation.entity_name == item.entity_name,
                    SyncOperation.entity_id == item.entity_id,
                    SyncOperation.sync_status == "accepted",
                    SyncOperation.id != operation.id,
                )
            )
            if existing_entity_operation:
                operation.sync_status = "conflict"
                operation.conflict_reason = "Identifiant d’entité déjà utilisé"
                conflicts += 1
                stored.append(operation)
                continue
        if item.entity_name == "user":
            try:
                payload = json.loads(item.payload_json)
            except json.JSONDecodeError as exc:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Données utilisateur invalides dans la synchronisation",
                ) from exc
            username = str(payload.get("username", "")).strip()
            if username:
                existing_user = db.scalar(
                    select(TenantUser).where(
                        TenantUser.tenant_id == user.tenant_id,
                        TenantUser.username_normalized == normalize_username(username),
                    )
                )
                if item.operation_name == "delete":
                    if existing_user:
                        if existing_user.role == "admin":
                            admin_count = db.scalar(
                                select(func.count(TenantUser.id)).where(
                                    TenantUser.tenant_id == user.tenant_id,
                                    TenantUser.role == "admin",
                                )
                            ) or 0
                            if admin_count <= 1:
                                raise HTTPException(
                                    status_code=status.HTTP_403_FORBIDDEN,
                                    detail="Impossible de supprimer le dernier administrateur",
                                )
                        db.delete(existing_user)
                else:
                    full_name = str(payload.get("name", username)).strip() or username
                    role = normalize_role_name(str(payload.get("role", "cashier")))
                    pin = str(payload.get("pin", "Kese@2026")).strip() or "Kese@2026"
                    is_blocked = bool(payload.get("isBlocked", False))
                    if existing_user:
                        existing_user.full_name = full_name
                        existing_user.role = role
                        existing_user.hashed_pin = hash_pin(pin)
                        existing_user.is_blocked = is_blocked
                    else:
                        users_count = db.scalar(
                            select(func.count(TenantUser.id)).where(
                                TenantUser.tenant_id == user.tenant_id
                            )
                        ) or 0
                        if users_count >= license_record.max_users:
                            raise HTTPException(
                                status_code=status.HTTP_403_FORBIDDEN,
                                detail="Limite d’utilisateurs atteinte pour cette licence",
                            )
                        db.add(
                            TenantUser(
                                tenant_id=user.tenant_id,
                                branch_id=user.branch_id,
                                username=username,
                                username_normalized=normalize_username(username),
                                full_name=full_name,
                                role=role,
                                hashed_pin=hash_pin(pin),
                                is_blocked=is_blocked,
                            )
                        )
        stored.append(operation)
    db.commit()
    return stored, ignored, conflicts


def pull_sync_operations(db: Session, *, user: TenantUser, after_id: int, limit: int):
    active_license_for_tenant(db, user.tenant_id)
    return db.execute(
        select(SyncOperation)
        .where(SyncOperation.tenant_id == user.tenant_id, SyncOperation.id > after_id)
        .order_by(SyncOperation.id.asc())
        .limit(limit)
    ).scalars().all()



