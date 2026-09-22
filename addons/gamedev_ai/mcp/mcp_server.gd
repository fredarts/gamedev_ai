@tool
extends Node

## Godot 4 Local MCP Server
## Listens on 127.0.0.1 (default port 6543) and processes MCP JSON-RPC requests from Antigravity & IDEs.

signal server_started(port: int)
signal server_stopped()
signal request_processed(method: String, is_error: bool)

var tcp_server: TCPServer
var is_running: bool = false
var port: int = 6543
var protocol: RefCounted

# List of active TCP peer connections being handled
var _clients: Array = []

func setup(_protocol: RefCounted, _port: int = 6543):
	protocol = _protocol
	port = _port

func start() -> bool:
	if is_running:
		return true
		
	tcp_server = TCPServer.new()
	var err = tcp_server.listen(port, "127.0.0.1")
	if err != OK:
		push_error("MCPServer: Failed to listen on 127.0.0.1:" + str(port) + " (Error code: " + str(err) + ")")
		return false
		
	is_running = true
	print_rich("[color=green][b]🟢 Godot MCP Server running at http://127.0.0.1:" + str(port) + "[/b][/color]")
	server_started.emit(port)
	return true

func stop():
	if not is_running:
		return
		
	for client in _clients:
		if is_instance_valid(client) and client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			client.disconnect_from_host()
	_clients.clear()
	
	if tcp_server:
		tcp_server.stop()
		tcp_server = null
		
	is_running = false
	print_rich("[color=yellow]🟡 Godot MCP Server stopped.[/color]")
	server_stopped.emit()

func _process(_delta: float):
	if not is_running or tcp_server == null:
		return
		
	# Accept new incoming connections
	if tcp_server.is_connection_available():
		var peer = tcp_server.take_connection()
		if peer:
			_clients.append(peer)
			
	# Process existing clients
	var to_remove = []
	for client in _clients:
		if not is_instance_valid(client):
			to_remove.append(client)
			continue
			
		var status = client.get_status()
		if status == StreamPeerTCP.STATUS_CONNECTED:
			var available_bytes = client.get_available_bytes()
			if available_bytes > 0:
				var data = client.get_utf8_string(available_bytes)
				if not data.is_empty():
					_handle_incoming_data(client, data)
		elif status != StreamPeerTCP.STATUS_CONNECTING:
			to_remove.append(client)
			
	for client in to_remove:
		_clients.erase(client)

func _handle_incoming_data(client: StreamPeerTCP, raw_data: String):
	# Handle HTTP POST or JSON-RPC directly
	if raw_data.begins_with("POST ") or raw_data.begins_with("GET "):
		_handle_http_request(client, raw_data)
	else:
		# Direct raw JSON-RPC over TCP (separated by newline or raw object)
		_handle_raw_jsonrpc(client, raw_data)

func _handle_http_request(client: StreamPeerTCP, http_data: String):
	var parts = http_data.split("\r\n\r\n", false, 2)
	if parts.is_empty():
		parts = http_data.split("\n\n", false, 2)
		
	var headers = parts[0]
	var body = parts[1] if parts.size() > 1 else ""
	
	# CORS Preflight OPTIONS
	if headers.begins_with("OPTIONS "):
		var cors_response = "HTTP/1.1 204 No Content\r\n" + \
			"Access-Control-Allow-Origin: *\r\n" + \
			"Access-Control-Allow-Methods: POST, GET, OPTIONS\r\n" + \
			"Access-Control-Allow-Headers: Content-Type\r\n\r\n"
		client.put_data(cors_response.to_utf8_buffer())
		client.disconnect_from_host()
		return
		
	# Server-Sent Events (SSE) endpoint or simple status GET
	if headers.begins_with("GET "):
		var status_json = JSON.stringify({
			"status": "online",
			"server": "gamedev-ai-godot",
			"version": "1.0.0",
			"active_scene": EditorInterface.get_edited_scene_root().name if Engine.is_editor_hint() and EditorInterface.get_edited_scene_root() else "none"
		})
		var get_response = "HTTP/1.1 200 OK\r\n" + \
			"Content-Type: application/json\r\n" + \
			"Access-Control-Allow-Origin: *\r\n" + \
			"Content-Length: " + str(status_json.to_utf8_buffer().size()) + "\r\n\r\n" + \
			status_json
		client.put_data(get_response.to_utf8_buffer())
		client.disconnect_from_host()
		return
		
	# POST JSON-RPC Request
	if body.is_empty():
		_send_http_error(client, 400, "Empty Body")
		return
		
	var json = JSON.new()
	var parse_err = json.parse(body)
	if parse_err != OK:
		_send_http_error(client, 400, "Invalid JSON: " + json.get_error_message())
		return
		
	var req_dict = json.data
	if req_dict is Dictionary:
		var response_dict = {}
		if protocol:
			response_dict = protocol.handle_request(req_dict)
			
		if response_dict.is_empty():
			var http_response = "HTTP/1.1 204 No Content\r\n" + \
				"Access-Control-Allow-Origin: *\r\n\r\n"
			client.put_data(http_response.to_utf8_buffer())
			client.disconnect_from_host()
			request_processed.emit(req_dict.get("method", "unknown"), false)
			return

		var res_json = JSON.stringify(response_dict)
		var res_bytes = res_json.to_utf8_buffer()
		var http_response = "HTTP/1.1 200 OK\r\n" + \
			"Content-Type: application/json\r\n" + \
			"Access-Control-Allow-Origin: *\r\n" + \
			"Content-Length: " + str(res_bytes.size()) + "\r\n\r\n" + \
			res_json
		client.put_data(http_response.to_utf8_buffer())
		request_processed.emit(req_dict.get("method", "unknown"), response_dict.has("error"))
	elif req_dict is Array:
		# Batch request
		var batch_res = []
		for item in req_dict:
			if item is Dictionary and protocol:
				batch_res.append(protocol.handle_request(item))
		var res_json = JSON.stringify(batch_res)
		var res_bytes = res_json.to_utf8_buffer()
		var http_response = "HTTP/1.1 200 OK\r\n" + \
			"Content-Type: application/json\r\n" + \
			"Access-Control-Allow-Origin: *\r\n" + \
			"Content-Length: " + str(res_bytes.size()) + "\r\n\r\n" + \
			res_json
		client.put_data(http_response.to_utf8_buffer())
	
	client.disconnect_from_host()

func _handle_raw_jsonrpc(client: StreamPeerTCP, raw_json: String):
	var lines = raw_json.split("\n", false)
	for line in lines:
		line = line.strip_edges()
		if line.is_empty():
			continue
			
		var json = JSON.new()
		if json.parse(line) == OK and json.data is Dictionary:
			var req_dict = json.data
			if protocol:
				var response_dict = protocol.handle_request(req_dict)
				if not response_dict.is_empty():
					var out_line = JSON.stringify(response_dict) + "\n"
					client.put_data(out_line.to_utf8_buffer())
					request_processed.emit(req_dict.get("method", "unknown"), response_dict.has("error"))

func _send_http_error(client: StreamPeerTCP, code: int, message: String):
	var res = JSON.stringify({"error": message})
	var http_res = "HTTP/1.1 " + str(code) + " Error\r\n" + \
		"Content-Type: application/json\r\n" + \
		"Content-Length: " + str(res.to_utf8_buffer().size()) + "\r\n\r\n" + \
		res
	client.put_data(http_res.to_utf8_buffer())
	client.disconnect_from_host()
