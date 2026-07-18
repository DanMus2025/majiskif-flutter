from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class Tenant(Base):
    __tablename__ = "tenants"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    tenant_key: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    company_name: Mapped[str] = mapped_column(String(160))
    cloud_base_url: Mapped[str | None] = mapped_column(String(255), nullable=True)
    owner_name: Mapped[str | None] = mapped_column(String(120), nullable=True)
    phone: Mapped[str | None] = mapped_column(String(40), nullable=True)
    email: Mapped[str | None] = mapped_column(String(120), nullable=True)
    address: Mapped[str | None] = mapped_column(String(255), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class TenantBranch(Base):
    __tablename__ = "tenant_branches"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    tenant_id: Mapped[int] = mapped_column(ForeignKey("tenants.id"), index=True)
    branch_code: Mapped[str] = mapped_column(String(64))
    branch_name: Mapped[str] = mapped_column(String(120))
    address: Mapped[str | None] = mapped_column(String(255), nullable=True)
    is_main: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class TenantLicense(Base):
    __tablename__ = "tenant_licenses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    tenant_id: Mapped[int] = mapped_column(ForeignKey("tenants.id"), index=True)
    license_code: Mapped[str] = mapped_column(String(160), unique=True, index=True)
    plan_code: Mapped[str] = mapped_column(String(40), default="standard")
    status: Mapped[str] = mapped_column(String(32), default="active")
    max_devices: Mapped[int] = mapped_column(Integer, default=3)
    max_users: Mapped[int] = mapped_column(Integer, default=20)
    activated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class TenantUser(Base):
    __tablename__ = "tenant_users"
    __table_args__ = (
        UniqueConstraint("tenant_id", "username_normalized", name="uq_tenant_username"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    tenant_id: Mapped[int] = mapped_column(ForeignKey("tenants.id"), index=True)
    branch_id: Mapped[int | None] = mapped_column(ForeignKey("tenant_branches.id"), nullable=True)
    username: Mapped[str] = mapped_column(String(60))
    username_normalized: Mapped[str] = mapped_column(String(60))
    full_name: Mapped[str] = mapped_column(String(120))
    role: Mapped[str] = mapped_column(String(32))
    hashed_pin: Mapped[str] = mapped_column(String(255))
    is_blocked: Mapped[bool] = mapped_column(Boolean, default=False)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class TenantDevice(Base):
    __tablename__ = "tenant_devices"
    __table_args__ = (
        UniqueConstraint("tenant_id", "device_uuid", name="uq_tenant_device_uuid"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    tenant_id: Mapped[int] = mapped_column(ForeignKey("tenants.id"), index=True)
    branch_id: Mapped[int | None] = mapped_column(ForeignKey("tenant_branches.id"), nullable=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("tenant_users.id"), nullable=True)
    device_uuid: Mapped[str] = mapped_column(String(120))
    device_label: Mapped[str] = mapped_column(String(160))
    platform_name: Mapped[str] = mapped_column(String(60))
    app_version: Mapped[str | None] = mapped_column(String(40), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class CloudSessionToken(Base):
    __tablename__ = "cloud_session_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    tenant_user_id: Mapped[int] = mapped_column(ForeignKey("tenant_users.id"), index=True)
    token_jti: Mapped[str] = mapped_column(String(120), unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    is_revoked: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class SyncOperation(Base):
    __tablename__ = "sync_operations"
    __table_args__ = (
        UniqueConstraint("tenant_id", "operation_uid", name="uq_sync_operation_uid"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    tenant_id: Mapped[int] = mapped_column(ForeignKey("tenants.id"), index=True)
    branch_id: Mapped[int | None] = mapped_column(ForeignKey("tenant_branches.id"), nullable=True)
    device_id: Mapped[int | None] = mapped_column(ForeignKey("tenant_devices.id"), nullable=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("tenant_users.id"), nullable=True)
    operation_uid: Mapped[str] = mapped_column(String(160))
    entity_name: Mapped[str] = mapped_column(String(80))
    entity_id: Mapped[str] = mapped_column(String(120))
    operation_name: Mapped[str] = mapped_column(String(40))
    payload_json: Mapped[str] = mapped_column(Text)
    payload_hash: Mapped[str | None] = mapped_column(String(80), nullable=True)
    sync_status: Mapped[str] = mapped_column(String(40), default="accepted")
    conflict_reason: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
