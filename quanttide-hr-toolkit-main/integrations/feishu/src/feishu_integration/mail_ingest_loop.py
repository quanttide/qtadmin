"""Polling loop — periodically fetches and ingests emails from Feishu mailbox.

Can be run as a standalone process (systemd service) or triggered by a timer.

Usage:
    python -m feishu_integration.mail_ingest_loop              # one-shot
    python -m feishu_integration.mail_ingest_loop --watch       # polling loop

Environment:
    QTADMIN_SERVER_URL    服务端地址（默认 http://localhost:8000）
    QTADMIN_MAILBOX       飞书邮箱
    INGEST_INTERVAL       轮询间隔分钟（默认 5）
"""

import argparse
import logging
import os
import time

logger = logging.getLogger(__name__)


def ingest_once(server_url: str, mailbox: str) -> dict:
    """Single ingest cycle: fetch → classify → push to server."""
    from feishu_integration.mail_reader import fetch_and_classify
    from feishu_integration.pipeline_writer import ingest_to_server

    items = fetch_and_classify(mailbox=mailbox)
    if not items:
        logger.info("No new emails to ingest.")
        return {"queued": 0, "skipped": 0, "errors": []}

    logger.info("Fetched %d classified items, pushing to server ...", len(items))
    try:
        result = ingest_to_server(items, server_url=server_url)
        queued = result.get("queued", 0)
        skipped = result.get("skipped", 0)
        errors = len(result.get("errors", []))
        logger.info("Ingest done: %d queued, %d skipped, %d errors", queued, skipped, errors)
        return result
    except Exception as e:
        logger.error("Ingest failed: %s", e)
        return {"queued": 0, "skipped": 0, "errors": [str(e)]}


def run_loop(server_url: str, mailbox: str, interval_minutes: int = 5):
    """Run the ingest polling loop indefinitely."""
    logger.info("Starting ingest loop — server=%s mailbox=%s interval=%dmin",
                server_url, mailbox or "(default)", interval_minutes)
    while True:
        try:
            ingest_once(server_url=server_url, mailbox=mailbox)
        except Exception as e:
            logger.error("Unexpected error in ingest loop: %s", e)
        logger.info("Sleeping %d minutes ...", interval_minutes)
        time.sleep(interval_minutes * 60)


def main():
    parser = argparse.ArgumentParser(description="Feishu email ingest polling loop")
    parser.add_argument("--watch", action="store_true", help="Run continuously (polling loop)")
    parser.add_argument("--server-url", default=os.environ.get("QTADMIN_SERVER_URL", "http://localhost:8000"))
    parser.add_argument("--mailbox", default=os.environ.get("QTADMIN_MAILBOX", ""))
    parser.add_argument("--interval", type=int, default=int(os.environ.get("INGEST_INTERVAL", "5")),
                        help="Polling interval in minutes (default: 5)")
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
    )

    if args.watch:
        run_loop(server_url=args.server_url, mailbox=args.mailbox, interval_minutes=args.interval)
    else:
        ingest_once(server_url=args.server_url, mailbox=args.mailbox)


if __name__ == "__main__":
    main()
