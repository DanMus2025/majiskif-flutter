from __future__ import annotations

import argparse
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from app.database import Base, SessionLocal, engine
from app.schemas import TenantCreateRequest
from app.service import create_tenant_environment


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Cree une entreprise KESE, son administrateur initial et une licence cloud."
    )
    parser.add_argument("--company-name", required=True, help="Nom officiel de l'entreprise.")
    parser.add_argument("--owner-name", default="", help="Nom du responsable.")
    parser.add_argument("--phone", default="", help="Telephone principal.")
    parser.add_argument("--email", default="", help="Email principal.")
    parser.add_argument("--address", default="", help="Adresse ou ville.")
    parser.add_argument("--branch-name", default="Site principal", help="Nom de la branche principale.")
    parser.add_argument("--admin-full-name", required=True, help="Nom complet de l'administrateur initial.")
    parser.add_argument("--admin-username", required=True, help="Identifiant de l'administrateur initial.")
    parser.add_argument("--admin-pin", required=True, help="Code PIN initial de l'administrateur.")
    parser.add_argument("--plan-code", default="standard", help="Code du plan de licence.")
    parser.add_argument(
        "--license-duration",
        default="1y",
        help="Duree de licence: trial-24h, 1y, 2y, 5y ou indefinite.",
    )
    parser.add_argument(
        "--max-devices",
        type=int,
        default=3,
        help="Nombre maximal d'appareils autorises par la licence.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        tenant, branch, admin_user, license_record = create_tenant_environment(
            db,
            TenantCreateRequest(
                company_name=args.company_name,
                owner_name=args.owner_name or None,
                phone=args.phone or None,
                email=args.email or None,
                address=args.address or None,
                branch_name=args.branch_name,
                admin_full_name=args.admin_full_name,
                admin_username=args.admin_username,
                admin_pin=args.admin_pin,
                plan_code=args.plan_code,
                license_duration=args.license_duration,
                max_devices=args.max_devices,
            ),
        )
    finally:
        db.close()

    print("company_name=", tenant.company_name)
    print("tenant_key=", tenant.tenant_key)
    print("license_code=", license_record.license_code)
    print("plan_code=", license_record.plan_code)
    print("license_duration=", args.license_duration)
    print("expires_at=", license_record.expires_at.isoformat() if license_record.expires_at else "indefinite")
    print("max_devices=", license_record.max_devices)
    print("branch_name=", branch.branch_name)
    print("branch_code=", branch.branch_code)
    print("admin_username=", admin_user.username)
    print("admin_pin=", args.admin_pin)
    print("activation_login=", f"{admin_user.username} / {args.admin_pin}")
    print("next_step=", "Utiliser le code licence sur le premier appareil KESE.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
