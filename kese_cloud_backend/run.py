import os

from app.main import app

if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT") or os.getenv("KESE_PORT", "8766"))
    uvicorn.run(app, host="0.0.0.0", port=port)
