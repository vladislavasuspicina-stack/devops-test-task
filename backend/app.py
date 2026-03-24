#!/usr/bin/env python3
"""Simple HTTP server for testing."""

import http.server
import socketserver
import sys
from http import HTTPStatus

PORT = 8080


class SimpleHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
    """Handle HTTP requests."""

    def do_GET(self):
        """Handle GET requests."""
        if self.path == "/":
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"Hello from Effective Mobile!")
        else:
            self.send_response(HTTPStatus.NOT_FOUND)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Not Found")

    def log_message(self, format, *args):
        """Log HTTP requests."""
        print(f"[{self.log_date_time_string()}] {format % args}", file=sys.stderr)


if __name__ == "__main__":
    handler = SimpleHTTPRequestHandler
    with socketserver.TCPServer(("0.0.0.0", PORT), handler) as httpd:
        print(f"Server started at port {PORT}")
        sys.stdout.flush()
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("Server stopped")
            sys.exit(0)
