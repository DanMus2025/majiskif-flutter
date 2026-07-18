from datetime import datetime, timedelta
from uuid import uuid4

from jose import JWTError, jwt
from passlib.context import CryptContext

from .config import settings

pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


def utcnow() -> datetime:
    return datetime.utcnow()


def hash_pin(pin: str) -> str:
    return pwd_context.hash(pin)


def verify_pin(pin: str, hashed: str) -> bool:
    return pwd_context.verify(pin, hashed)


def create_access_token(subject: str, *, role: str, tenant_id: int, tenant_key: str, device_uuid: str) -> tuple[str, str, datetime]:
    expires_at = utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    jti = uuid4().hex
    payload = {
        "sub": subject,
        "role": role,
        "tenant_id": tenant_id,
        "tenant_key": tenant_key,
        "device_uuid": device_uuid,
        "cloud": True,
        "jti": jti,
        "exp": int(expires_at.timestamp()),
    }
    return (
        jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm),
        jti,
        expires_at,
    )


def create_creator_access_token(username: str) -> tuple[str, str, datetime]:
    expires_at = utcnow() + timedelta(
        minutes=settings.creator_access_token_expire_minutes
    )
    jti = uuid4().hex
    payload = {
        "sub": username,
        "creator": True,
        "jti": jti,
        "exp": int(expires_at.timestamp()),
    }
    return (
        jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm),
        jti,
        expires_at,
    )


def decode_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
    except JWTError:
        return None
