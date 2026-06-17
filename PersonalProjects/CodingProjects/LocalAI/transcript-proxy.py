#!/usr/bin/env python3

import argparse
import json
import threading
from datetime import datetime, timezone
from http.client import HTTPConnection
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from typing import Any
from socketserver import ThreadingMixIn

HOP_BY_HOP_HEADERS = {
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade",
}


try:
    from http.server import ThreadingHTTPServer
except ImportError:
    class ThreadingHTTPServer(ThreadingMixIn, HTTPServer):
        daemon_threads = True


def decode_payload(payload):
    if not payload:
        return None

    text = payload.decode("utf-8", errors="replace").strip()
    if not text:
        return None

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return text


class TranscriptStore:
    def __init__(self, transcript_file, max_entries):
        self.transcript_file = transcript_file
        self.max_entries = max_entries
        self.lock = threading.Lock()

    def append(self, entry):
        with self.lock:
            entries = self._load_entries()
            entries.append(entry)
            entries = entries[-self.max_entries :]
            self.transcript_file.parent.mkdir(parents=True, exist_ok=True)
            temp_file = self.transcript_file.with_suffix(self.transcript_file.suffix + ".tmp")
            temp_file.write_text(
                "\n".join(json.dumps(item, ensure_ascii=False) for item in entries) + ("\n" if entries else ""),
                encoding="utf-8",
            )
            temp_file.replace(self.transcript_file)

    def clear(self):
        with self.lock:
            self.transcript_file.parent.mkdir(parents=True, exist_ok=True)
            self.transcript_file.write_text("", encoding="utf-8")

    def _load_entries(self):
        if not self.transcript_file.exists():
            return []

        entries = []
        for line in self.transcript_file.read_text(encoding="utf-8").splitlines():
            stripped_line = line.strip()
            if not stripped_line:
                continue
            try:
                entries.append(json.loads(stripped_line))
            except json.JSONDecodeError:
                continue
        return entries


def make_handler(upstream_host, upstream_port, label, store):
    class ProxyHandler(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def _proxy(self):
            payload_length = int(self.headers.get("Content-Length", "0") or "0")
            request_body = self.rfile.read(payload_length) if payload_length else b""

            connection_headers = {
                key: value
                for key, value in self.headers.items()
                if key.lower() not in HOP_BY_HOP_HEADERS and key.lower() not in {"host", "content-length", "accept-encoding"}
            }
            connection_headers["Host"] = f"{upstream_host}:{upstream_port}"

            connection = HTTPConnection(upstream_host, upstream_port, timeout=600)
            connection.request(
                self.command,
                self.path,
                body=request_body if request_body else None,
                headers=connection_headers,
            )
            upstream_response = connection.getresponse()
            response_body = upstream_response.read()

            self.send_response(upstream_response.status, upstream_response.reason)
            for header_name, header_value in upstream_response.getheaders():
                lower_name = header_name.lower()
                if lower_name in HOP_BY_HOP_HEADERS or lower_name in {"content-length", "transfer-encoding"}:
                    continue
                self.send_header(header_name, header_value)
            self.send_header("Content-Length", str(len(response_body)))
            self.end_headers()
            self.wfile.write(response_body)

            if self.command in {"POST", "PUT", "PATCH"} or request_body:
                store.append(
                    {
                        "timestamp": datetime.now(timezone.utc).isoformat(),
                        "label": label,
                        "method": self.command,
                        "path": self.path,
                        "request": decode_payload(request_body),
                        "response_status": upstream_response.status,
                        "response": decode_payload(response_body),
                    }
                )

        def do_GET(self):
            self._proxy()

        def do_POST(self):
            self._proxy()

        def do_PUT(self):
            self._proxy()

        def do_PATCH(self):
            self._proxy()

        def do_DELETE(self):
            self._proxy()

        def log_message(self, format, *args):  # noqa: A003
            return

    return ProxyHandler


def main() -> int:
    parser = argparse.ArgumentParser(description="llama-server transcript proxy")
    parser.add_argument("--label", "--service-name", dest="label", required=True)
    parser.add_argument("--listen-host", required=True)
    parser.add_argument("--listen-port", required=True, type=int)
    parser.add_argument("--upstream-host", "--backend-host", dest="backend_host", required=True)
    parser.add_argument("--upstream-port", "--backend-port", dest="backend_port", required=True, type=int)
    parser.add_argument("--transcript-file", "--transcript-log", dest="transcript_log", required=True)
    parser.add_argument("--max-entries", type=int, default=5)
    args = parser.parse_args()

    store = TranscriptStore(Path(args.transcript_log), args.max_entries)
    server = ThreadingHTTPServer(
        (args.listen_host, args.listen_port),
        make_handler(args.backend_host, args.backend_port, args.label, store),
    )
    server.daemon_threads = True
    print(
        "Transcript proxy for {} listening on {}:{} -> {}:{}".format(
            args.label,
            args.listen_host,
            args.listen_port,
            args.backend_host,
            args.backend_port,
        ),
        flush=True,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())