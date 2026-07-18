from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class TenantCreateRequest(BaseModel):
    company_name: str = Field(min_length=2, max_length=160)
    cloud_base_url: str | None = Field(default=None, max_length=255)
    owner_name: str | None = Field(default=None, max_length=120)
    phone: str | None = Field(default=None, max_length=40)
    email: str | None = Field(default=None, max_length=120)
    address: str | None = Field(default=None, max_length=255)
    branch_name: str = Field(default="Site principal", min_length=2, max_length=120)
    admin_full_name: str = Field(min_length=2, max_length=120)
    admin_username: str = Field(min_length=3, max_length=60)
    admin_pin: str = Field(min_length=6, max_length=128)
    plan_code: str = Field(default="standard", max_length=40)
    license_duration: str = Field(default="1y", max_length=40)
    max_devices: int = Field(default=3, ge=1, le=1000)
    max_users: int = Field(default=20, ge=1, le=10000)


class CloudActivationRequest(BaseModel):
    license_code: str = Field(min_length=8, max_length=160)
    username: str = Field(min_length=3, max_length=60)
    pin: str = Field(min_length=6, max_length=128)
    device_uuid: str = Field(min_length=3, max_length=120)
    device_label: str = Field(min_length=2, max_length=160)
    platform_name: str = Field(min_length=2, max_length=60)
    app_version: str | None = Field(default=None, max_length=40)


class CloudLoginRequest(BaseModel):
    tenant_key: str = Field(min_length=3, max_length=64)
    username: str = Field(min_length=3, max_length=60)
    pin: str = Field(min_length=6, max_length=128)
    device_uuid: str = Field(min_length=3, max_length=120)
    device_label: str = Field(min_length=2, max_length=160)
    platform_name: str = Field(min_length=2, max_length=60)
    app_version: str | None = Field(default=None, max_length=40)


class CreatorAuthRequest(BaseModel):
    username: str = Field(min_length=3, max_length=60)
    pin: str = Field(min_length=6, max_length=128)


class CreatorProfileUpdateRequest(BaseModel):
    current_pin: str = Field(min_length=6, max_length=128)
    username: str = Field(min_length=3, max_length=60)
    pin: str = Field(min_length=6, max_length=128)


class CreatorLicenseUpdateRequest(BaseModel):
    license_code: str | None = Field(default=None, min_length=8, max_length=160)
    status: str | None = Field(default=None, max_length=32)
    plan_code: str | None = Field(default=None, max_length=40)
    license_duration: str | None = Field(default=None, max_length=40)
    max_devices: int | None = Field(default=None, ge=1, le=1000)
    max_users: int | None = Field(default=None, ge=1, le=10000)
    cloud_base_url: str | None = Field(default=None, max_length=255)

class SyncOperationIn(BaseModel):
    operation_uid: str = Field(min_length=3, max_length=160)
    entity_name: str = Field(min_length=2, max_length=80)
    entity_id: str = Field(min_length=1, max_length=120)
    operation_name: str = Field(min_length=2, max_length=40)
    payload_json: str = Field(min_length=2)
    payload_hash: str | None = Field(default=None, max_length=80)
    created_at: datetime


class SyncPushRequest(BaseModel):
    device_uuid: str = Field(min_length=3, max_length=120)
    operations: list[SyncOperationIn] = Field(default_factory=list)


class CloudTenantOut(BaseModel):
    id: int
    tenant_key: str
    company_name: str
    cloud_base_url: str | None = None
    owner_name: str | None = None
    phone: str | None = None
    email: str | None = None
    address: str | None = None
    is_active: bool


class CloudBranchOut(BaseModel):
    id: int
    branch_code: str
    branch_name: str
    address: str | None = None
    is_main: bool


class CloudUserOut(BaseModel):
    id: int
    username: str
    full_name: str
    role: str
    is_blocked: bool


class CloudDeviceOut(BaseModel):
    id: int
    device_uuid: str
    device_label: str
    platform_name: str
    app_version: str | None = None
    is_active: bool
    last_seen_at: datetime | None = None


class CloudLicenseOut(BaseModel):
    id: int
    license_code: str
    plan_code: str
    status: str
    max_devices: int
    max_users: int
    expires_at: datetime | None = None
    activated_at: datetime | None = None


class CreatorLicenseResetResponse(BaseModel):
    license: CloudLicenseOut
    revoked_sessions: int
    disabled_devices: int


class CreatorLicenseDeleteResponse(BaseModel):
    deleted_license_id: int
    deleted_tenant_id: int
    deleted_sessions: int
    deleted_operations: int
    deleted_devices: int
    deleted_users: int
    deleted_branches: int
    deleted_licenses: int


class CloudAuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_at: datetime
    tenant: CloudTenantOut
    branch: CloudBranchOut
    user: CloudUserOut
    device: CloudDeviceOut
    license: CloudLicenseOut


class CloudBootstrapResponse(BaseModel):
    tenant: CloudTenantOut
    branch: CloudBranchOut
    user: CloudUserOut
    devices: list[CloudDeviceOut]
    users: list[CloudUserOut]
    license: CloudLicenseOut


class SyncOperationOut(BaseModel):
    id: int
    operation_uid: str
    entity_name: str
    entity_id: str
    operation_name: str
    payload_json: str
    payload_hash: str | None = None
    sync_status: str
    conflict_reason: str | None = None
    created_at: datetime


class SyncPushResponse(BaseModel):
    accepted: int
    ignored: int
    conflicts: int
    operations: list[SyncOperationOut]


class SyncPullResponse(BaseModel):
    cursor: int
    operations: list[SyncOperationOut]


class TenantCreateResponse(BaseModel):
    tenant: CloudTenantOut
    branch: CloudBranchOut
    admin_user: CloudUserOut
    license: CloudLicenseOut
    activation_hint: dict[str, Any]


class CreatorAuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_at: datetime
    username: str


class CreatorTenantOverview(BaseModel):
    tenant: CloudTenantOut
    branch: CloudBranchOut
    license: CloudLicenseOut
    users_count: int
    devices_count: int
    active_devices_count: int
    first_activation_done: bool
    last_activity_at: datetime | None = None


class CreatorTenantsResponse(BaseModel):
    items: list[CreatorTenantOverview]
    total: int
