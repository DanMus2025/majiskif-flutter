from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from app.database import Base, SessionLocal, engine
from app.schemas import TenantCreateRequest
from app.service import create_tenant_environment


def main():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        tenant, branch, admin_user, license_record = create_tenant_environment(
            db,
            TenantCreateRequest(
                company_name="KESE Demo",
                owner_name="Daniel Test",
                phone="+243971238634",
                email="demo@kese.local",
                address="Bukavu",
                branch_name="Site principal",
                admin_full_name="Administrateur Demo",
                admin_username="Admin",
                admin_pin="Admin@2026",
                plan_code="standard",
                max_devices=5,
            ),
        )
        print("tenant_key=", tenant.tenant_key)
        print("license_code=", license_record.license_code)
        print("admin_username=", admin_user.username)
        print("admin_pin=Admin@2026")
        print("branch_code=", branch.branch_code)
    finally:
        db.close()


if __name__ == "__main__":
    main()
