from pathlib import Path

from sqlalchemy import create_engine, event, inspect, text
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .config import settings

db_path = Path(__file__).resolve().parents[1] / "data"
db_path.mkdir(parents=True, exist_ok=True)

is_sqlite = settings.database_url.startswith("sqlite")

engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False} if is_sqlite else {},
    pool_pre_ping=not is_sqlite,
)


@event.listens_for(engine, "connect")
def _configure_sqlite_connection(dbapi_connection, _connection_record):
    if not is_sqlite:
        return
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA encoding = 'UTF-8'")
    cursor.execute("PRAGMA foreign_keys = ON")
    cursor.close()


SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def ensure_schema_extensions() -> None:
    inspector = inspect(engine)
    try:
        tenant_columns = {
            column["name"] for column in inspector.get_columns("tenants")
        }
        license_columns = {
            column["name"] for column in inspector.get_columns("tenant_licenses")
        }
    except Exception:
        return
    with engine.begin() as connection:
        if "cloud_base_url" not in tenant_columns:
            connection.execute(
                text("ALTER TABLE tenants ADD COLUMN cloud_base_url VARCHAR(255)")
            )
        if "max_users" not in license_columns:
            connection.execute(
                text("ALTER TABLE tenant_licenses ADD COLUMN max_users INTEGER DEFAULT 20")
            )
