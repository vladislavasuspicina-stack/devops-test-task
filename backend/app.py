#!/usr/bin/env python3
# Simple backend server for the proxy
# я думал про Flask но решил держать все простым - только stdlib

import http.server
import socketserver
import sys
from http import HTTPStatus

PORT = 8080  # не менять - указано в задании


class SimpleHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
    # обработчик HTTP запросов - ловит GET на / и отвечает нужным текстом

    def do_GET(self):
        if self.path == "/":
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"Hello from Effective Mobile!")
        else:
            # все остальное = 404
            self.send_response(HTTPStatus.NOT_FOUND)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Not Found")

    def log_message(self, format, *args):
        # логируем в stderr - так видно что происходит
        print(f"[{self.log_date_time_string()}] {format % args}", file=sys.stderr)


if __name__ == "__main__":
    handler = SimpleHTTPRequestHandler
    # 0.0.0.0 - нужно в контейнере чтобы все интерфейсы слушать
    with socketserver.TCPServer(("0.0.0.0", PORT), handler) as httpd:
        print(f"Server started at port {PORT}")
        sys.stdout.flush()
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("Server stopped")
            sys.exit(0)
