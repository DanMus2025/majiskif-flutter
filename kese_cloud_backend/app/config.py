from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "KESE Cloud API"
    secret_key: str = "kese-dev-secret-key-change-me"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 12
    creator_access_token_expire_minutes: int = 60 * 8
    creator_username: str = "creator"
    creator_pin: str = "Creator@2026"
    database_url: str = f"sqlite:///{(Path(__file__).resolve().parents[1] / 'data' / 'kese_cloud.sqlite3').as_posix()}"

    model_config = SettingsConfigDict(env_prefix="KESE_", extra="ignore")


settings = Settings()
