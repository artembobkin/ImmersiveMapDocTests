import http.server,sys
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(s):
        print("REQ",s.path,"| Authorization:",s.headers.get("Authorization"),"| Range:",s.headers.get("Range"),flush=True)
        b=b"not a pmtiles file"*50
        s.send_response(206); s.send_header("Content-Range","bytes 0-%d/%d"%(len(b)-1,len(b))); s.send_header("Content-Length",str(len(b))); s.end_headers(); s.wfile.write(b)
    def log_message(s,*a): pass
http.server.ThreadingHTTPServer(("127.0.0.1",8765),H).serve_forever()
