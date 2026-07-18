from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import os


ROOT = Path(__file__).resolve().parent
BUILD_DIR = ROOT / "build" / "web"
PORT = 5200


class NoCacheHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()


def main() -> None:
    os.chdir(BUILD_DIR)
    server = ThreadingHTTPServer(("0.0.0.0", PORT), NoCacheHandler)
    print(f"KESE web local sans cache : http://127.0.0.1:{PORT}/")
    server.serve_forever()


if __name__ == "__main__":
    main()
