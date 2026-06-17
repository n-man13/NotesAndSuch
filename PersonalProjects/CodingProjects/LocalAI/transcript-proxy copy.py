#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
import socketserver
import urllib.request
import urllib.error

class TranscriptProxyHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Suppress standard HTTP request logging to clean up launcher logs
        pass

    def do_POST(self):
        # Only proxy the standard OpenAI/llama.cpp completion endpoints
        if not (self.path.endswith('/v1/chat/completions') or self.path.endswith('/v1/completions') or self.path.endswith('/completion')):
            self.send_error(404, "Endpoint not handled by transcript proxy layer")
            return

        content_length = int(self.headers.get('Content-Length', 0))
        req_body = self.rfile.read(content_length)

        # Extract the user prompt for offline markdown logs
        prompt_text = "⚠️ [Unable to parse prompt string from request body]"
        try:
            req_json = json.loads(req_body.decode('utf-8'))
            if 'messages' in req_json and isinstance(req_json['messages'], list):
                user_msgs = [m['content'] for m in req_json['messages'] if m.get('role') == 'user']
                if user_msgs:
                    prompt_text = user_msgs[-1]
            elif 'prompt' in req_json:
                prompt_text = str(req_json['prompt'])
        except Exception:
            pass

        # Target address points to local hidden backend instance
        target_url = "http://{}:{}{}".format(self.server.upstream_host, self.server.upstream_port, self.path)
        
        headers = {k: v for k, v in self.headers.items() if k.lower() != 'host'}
        headers['Host'] = "{}:{}".format(self.server.upstream_host, self.server.upstream_port)

        downstream_req = urllib.request.Request(
            target_url, 
            data=req_body, 
            headers=headers, 
            method='POST'
        )

        try:
            with urllib.request.urlopen(downstream_req, timeout=self.server.timeout) as response:
                self.send_response(response.status)
                for k, v in response.getheaders():
                    self.send_header(k, v)
                self.end_headers()

                # Read and stream the tokens dynamically
                content_type = response.getheader('Content-Type', '')
                is_streaming = "text/event-stream" in content_type.lower()
                accumulated_chunks = []

                if is_streaming:
                    while True:
                        line = response.readline()
                        if not line:
                            break
                        self.wfile.write(line)
                        self.wfile.flush()

                        decoded_line = line.decode('utf-8').strip()
                        if decoded_line.startswith("data:"):
                            data_content = decoded_line[5:].strip()
                            if data_content == "[DONE]":
                                continue
                            try:
                                chunk_json = json.loads(data_content)
                                if 'choices' in chunk_json and len(chunk_json['choices']) > 0:
                                    delta = chunk_json['choices'][0].get('delta', {})
                                    if 'content' in delta:
                                        accumulated_chunks.append(delta['content'])
                                    elif 'text' in chunk_json['choices'][0]:
                                        accumulated_chunks.append(chunk_json['choices'][0]['text'])
                            except Exception:
                                pass
                else:
                    raw_res_body = response.read()
                    self.wfile.write(raw_res_body)
                    self.wfile.flush()
                    try:
                        res_json = json.loads(raw_res_body.decode('utf-8'))
                        if 'choices' in res_json and len(res_json['choices']) > 0:
                            if 'message' in res_json['choices'][0]:
                                accumulated_chunks.append(res_json['choices'][0]['message'].get('content', ''))
                            elif 'text' in res_json['choices'][0]:
                                accumulated_chunks.append(res_json['choices'][0]['text'])
                    except Exception:
                        pass

                # Safely save the complete text sequence to disk
                final_response = "".join(accumulated_chunks)
                self.server.save_exchanges(prompt_text, final_response)

        except urllib.error.HTTPError as e:
            self.send_error(e.code, e.reason)
        except Exception as e:
            self.send_error(502, "Bad Gateway to hidden core backend: {}".format(str(e)))

# COMPATIBILITY FIX FOR PYTHON 3.6: Explicitly combine ThreadingMixIn and HTTPServer
class ThreadedHTTPServer(socketserver.ThreadingMixIn, HTTPServer):
    def __init__(self, server_address, RequestHandlerClass, label, upstream_host, upstream_port, transcript_file, max_entries, timeout=1800000):
        # Python 3.6 compatible explicit super call style
        HTTPServer.__init__(self, server_address, RequestHandlerClass)
        self.label = label
        self.upstream_host = upstream_host
        self.upstream_port = upstream_port
        self.transcript_file = transcript_file
        self.max_entries = max_entries
        self.timeout = timeout
        self.md_output_dir = os.path.join(os.path.dirname(os.path.abspath(transcript_file)), "ai_outputs")

    def save_exchanges(self, prompt, response):
        # 1. Update rolling trace history jsonl log
        existing_history = []
        if os.path.exists(self.transcript_file) and os.path.getsize(self.transcript_file) > 0:
            try:
                with open(self.transcript_file, 'r', encoding='utf-8') as f:
                    for line in f:
                        if line.strip():
                            existing_history.append(json.loads(line))
            except Exception:
                pass

        new_entry = {
            "timestamp": datetime.now().isoformat(),
            "engine": self.label,
            "prompt": prompt,
            "response": response
        }
        existing_history.append(new_entry)
        trimmed_history = existing_history[-self.max_entries:]
        
        try:
            with open(self.transcript_file, 'w', encoding='utf-8') as f:
                for entry in trimmed_history:
                    f.write(json.dumps(entry) + "\n")
        except Exception as e:
            print("[{}] Error writing JSONL log: {}".format(self.label, e), file=sys.stderr)

        # 2. Append markdown notebook logging blocks
        try:
            os.makedirs(self.md_output_dir, exist_ok=True)
            date_str = datetime.now().strftime("%Y-%m-%d")
            clean_label = re.sub(r'[^a-zA-Z0-9_-]', '_', self.label)
            md_file_path = os.path.join(self.md_output_dir, "{}_{}.md".format(date_str, clean_label))
            
            timestamp = datetime.now().strftime("%H:%M:%S")
            markdown_payload = """
## 🕒 [{}] Interactive Session Exchange
* **Engine Environment:** `{}`

### 👤 User Query
> {}

### 🤖 Assistant Response
{}

---
""".format(timestamp, self.label, prompt.strip(), response.strip())

            with open(md_file_path, "a", encoding="utf-8") as f:
                f.write(markdown_payload)
        except Exception as e:
            print("[{}] Error writing Markdown notebook: {}".format(self.label, e), file=sys.stderr)

def main():
    parser = argparse.ArgumentParser(description="Python 3.6 Backwards-Compatible Proxy Layer.")
    parser.add_argument('--label', required=True, help="Identity tracking tag")
    parser.add_argument('--listen-host', default='0.0.0.0', help="Public binding adapter ip")
    parser.add_argument('--listen-port', type=int, required=True, help="Public port configuration")
    parser.add_argument('--upstream-host', default='127.0.0.1', help="Internal interface layout loop")
    parser.add_argument('--upstream-port', type=int, required=True, help="Hidden backplane server instance execution port")
    parser.add_argument('--transcript-file', required=True, help="JSONL destination track")
    parser.add_argument('--max-entries', type=int, default=5, help="Rolling depth configuration thresholds")
    args = parser.parse_args()

    server_address = (args.listen_host, args.listen_port)
    proxy_daemon = ThreadedHTTPServer(
        server_address, 
        TranscriptProxyHandler,
        label=args.label,
        upstream_host=args.upstream_host,
        upstream_port=args.upstream_port,
        transcript_file=args.transcript_file,
        max_entries=args.max_entries
    )

    print("[{}] Proxy online listening on http://{}:{} -> pointing upstream to port {}".format(
        args.label, args.listen_host, args.listen_port, args.upstream_port
    ))
    
    try:
        proxy_daemon.serve_forever()
    except KeyboardInterrupt:
        print("\n[{}] Closing daemon paths safely.".format(args.label))
        proxy_daemon.server_close()

if __name__ == '__main__':
    main()