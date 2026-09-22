#!/usr/bin/env python3
"""
Godot MCP Stdio Bridge
Zero-dependency bridge connecting stdio-based MCP clients (Antigravity, Claude Desktop, Cursor)
to the Godot Engine Gamedev AI MCP Server (127.0.0.1:6543).

Usage:
  python godot_mcp.py [--port 6543] [--host 127.0.0.1]
"""

import sys
import json
import urllib.request
import urllib.error
import argparse

def main():
    parser = argparse.ArgumentParser(description="Godot MCP Bridge")
    parser.add_argument("--port", type=int, default=6543, help="Godot MCP Server port (default: 6543)")
    parser.add_argument("--host", type=str, default="127.0.0.1", help="Godot MCP Server host (default: 127.0.0.1)")
    args = parser.parse_args()

    url = f"http://{args.host}:{args.port}"

    # Read JSON-RPC lines from stdin and forward to Godot MCP Server
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        # Parse the incoming JSON-RPC message
        req_id = None
        is_notification = True
        try:
            parsed_req = json.loads(line)
            if isinstance(parsed_req, dict) and "id" in parsed_req:
                req_id = parsed_req["id"]
                is_notification = False
        except Exception:
            pass

        try:
            req_data = line.encode("utf-8")
            req = urllib.request.Request(
                url,
                data=req_data,
                headers={"Content-Type": "application/json", "User-Agent": "Antigravity-MCP-Bridge/1.0"}
            )
            with urllib.request.urlopen(req, timeout=30) as response:
                # Notifications must NEVER yield a response on stdout (JSON-RPC 2.0 spec)
                if is_notification or response.status == 204:
                    continue

                res_body = response.read().decode("utf-8").strip()
                if not res_body or res_body == "{}":
                    continue

                # Ensure valid JSON-RPC 2.0 structure
                try:
                    res_dict = json.loads(res_body)
                    if isinstance(res_dict, dict):
                        if not res_dict or "error" not in res_dict and "result" not in res_dict:
                            # Not a valid response object
                            continue
                        if res_dict.get("jsonrpc") != "2.0":
                            res_dict["jsonrpc"] = "2.0"
                        if req_id is not None:
                            res_dict["id"] = req_id
                        res_body = json.dumps(res_dict)
                except Exception:
                    pass

                sys.stdout.write(res_body + "\n")
                sys.stdout.flush()

        except urllib.error.URLError as e:
            # If it's a notification, do not reply even on error
            if is_notification:
                continue

            err_response = {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {
                    "code": -32000,
                    "message": f"Could not connect to Godot Editor at {url}. Make sure Godot is open with Gamedev AI plugin enabled."
                }
            }
            sys.stdout.write(json.dumps(err_response) + "\n")
            sys.stdout.flush()

        except Exception as ex:
            if is_notification:
                continue

            err_response = {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {
                    "code": -32603,
                    "message": f"Internal Bridge Error: {str(ex)}"
                }
            }
            sys.stdout.write(json.dumps(err_response) + "\n")
            sys.stdout.flush()

if __name__ == "__main__":
    main()

