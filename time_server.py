from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime

class TimeHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        self.send_response(200)
        self.send_header("Content-type", "text/plain; charset=utf-8")
        self.end_headers()

        self.wfile.write(current_time.encode("utf-8"))

def run(server_class=HTTPServer, handler_class=TimeHandler, port=8056):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Сервер времени запущен на http://localhost:{port}")
    httpd.serve_forever()

if __name__ == "__main__":
    run()
