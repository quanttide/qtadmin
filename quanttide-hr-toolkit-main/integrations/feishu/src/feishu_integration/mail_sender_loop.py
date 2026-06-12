"""systemd entry point — runs the mail sender polling loop."""
import logging
import os

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
)

if __name__ == "__main__":
    from feishu_integration.mail_sender import run_loop

    server_url = os.environ.get("QTADMIN_SERVER_URL", "http://localhost:8000")
    run_loop(server_url=server_url)
