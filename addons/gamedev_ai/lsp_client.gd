@tool
extends RefCounted
class_name LSPClient

signal connected_to_lsp()
signal disconnected_from_lsp()
signal diagnostics_received(file_path: String, diagnostics: Array)

enum State {
	DISCONNECTED,
	CONNECTING,
	HANDSHAKE_SENT,
	INITIALIZED,
	READY
}

var state: int = State.DISCONNECTED
var _tcp: StreamPeerTCP
var _rx_buffer: PackedByteArray = PackedByteArray()
var _host: String = "127.0.0.1"
var _port: int = 6005
var _req_id_counter: int = 1
var _diagnostics_cache: Dictionary = {} # path -> Array of diagnostics
var _pending_requests: Dictionary = {}

func _init():
	_tcp = StreamPeerTCP.new()
	_detect_port_from_settings()

func _detect_port_from_settings():
	if Engine.is_editor_hint():
		var settings = EditorInterface.get_editor_settings()
		if settings:
			if settings.has_setting("network/language_server/remote_port"):
				_port = int(settings.get_setting("network/language_server/remote_port"))
			if settings.has_setting("network/language_server/remote_host"):
				_host = str(settings.get_setting("network/language_server/remote_host"))

func connect_to_lsp(host: String = "", port: int = -1) -> Error:
	if host != "":
		_host = host
	if port > 0:
		_port = port
		
	if _tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		return OK
		
	_rx_buffer.clear()
	state = State.CONNECTING
	var err = _tcp.connect_to_host(_host, _port)
	if err != OK:
		state = State.DISCONNECTED
		return err
	return OK

func disconnect_from_lsp():
	if _tcp.get_status() != StreamPeerTCP.STATUS_NONE:
		_tcp.disconnect_from_host()
	state = State.DISCONNECTED
	_rx_buffer.clear()
	disconnected_from_lsp.emit()

func is_ready() -> bool:
	return state == State.READY or state == State.INITIALIZED

func poll():
	_tcp.poll()
	var status = _tcp.get_status()
	
	if status == StreamPeerTCP.STATUS_CONNECTING:
		return
	elif status == StreamPeerTCP.STATUS_CONNECTED:
		if state == State.CONNECTING:
			state = State.HANDSHAKE_SENT
			_send_initialize()
		
		# Read incoming data
		var bytes_avail = _tcp.get_available_bytes()
		if bytes_avail > 0:
			var chunk = _tcp.get_data(bytes_avail)
			if chunk[0] == OK:
				_rx_buffer.append_array(chunk[1])
				_process_rx_buffer()
	else:
		if state != State.DISCONNECTED:
			state = State.DISCONNECTED
			disconnected_from_lsp.emit()

func _send_initialize():
	var root_uri = "file://" + ProjectSettings.globalize_path("res://").replace("\\", "/")
	var params = {
		"processId": OS.get_process_id(),
		"rootUri": root_uri,
		"capabilities": {
			"textDocument": {
				"publishDiagnostics": {
					"relatedInformation": true
				}
			}
		}
	}
	send_request("initialize", params, func(result):
		send_notification("initialized", {})
		state = State.READY
		connected_to_lsp.emit()
	)

func send_request(method: String, params: Dictionary, callback: Callable = Callable()) -> int:
	var req_id = _req_id_counter
	_req_id_counter += 1
	
	if callback.is_valid():
		_pending_requests[req_id] = callback
		
	var payload = {
		"jsonrpc": "2.0",
		"id": req_id,
		"method": method,
		"params": params
	}
	_send_payload(payload)
	return req_id

func send_notification(method: String, params: Dictionary):
	var payload = {
		"jsonrpc": "2.0",
		"method": method,
		"params": params
	}
	_send_payload(payload)

func _send_payload(dict: Dictionary):
	if _tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return
	var json_text = JSON.stringify(dict)
	var body = json_text.to_utf8_buffer()
	var header = "Content-Length: " + str(body.size()) + "\r\n\r\n"
	var header_bytes = header.to_utf8_buffer()
	
	_tcp.put_data(header_bytes)
	_tcp.put_data(body)

func _process_rx_buffer():
	while true:
		var buf_str = _rx_buffer.get_string_from_utf8()
		var header_idx = buf_str.find("Content-Length: ")
		if header_idx == -1:
			break
			
		var delimiter_idx = buf_str.find("\r\n\r\n", header_idx)
		if delimiter_idx == -1:
			break
			
		var len_str = buf_str.substr(header_idx + 16, delimiter_idx - (header_idx + 16))
		var content_len = len_str.to_int()
		var body_start_idx = delimiter_idx + 4
		
		# Check if the complete body is in the buffer
		var body_start_bytes = buf_str.substr(0, body_start_idx).to_utf8_buffer().size()
		if _rx_buffer.size() < body_start_bytes + content_len:
			break # Wait for more bytes
			
		var body_bytes = _rx_buffer.slice(body_start_bytes, body_start_bytes + content_len)
		_rx_buffer = _rx_buffer.slice(body_start_bytes + content_len)
		
		var json = JSON.new()
		var parse_err = json.parse(body_bytes.get_string_from_utf8())
		if parse_err == OK and json.data is Dictionary:
			_handle_message(json.data)

func _handle_message(msg: Dictionary):
	# 1. Handle Response to Request
	if msg.has("id") and msg.has("result"):
		var req_id = msg["id"]
		if _pending_requests.has(req_id):
			var cb = _pending_requests[req_id]
			_pending_requests.erase(req_id)
			if cb.is_valid():
				cb.call(msg["result"])
		return

	# 2. Handle Notifications
	var method = msg.get("method", "")
	var params = msg.get("params", {})
	if method == "textDocument/publishDiagnostics":
		var uri: String = params.get("uri", "")
		var diagnostics: Array = params.get("diagnostics", [])
		var clean_path = _uri_to_res_path(uri)
		_diagnostics_cache[clean_path] = diagnostics
		diagnostics_received.emit(clean_path, diagnostics)

func _uri_to_res_path(uri: String) -> String:
	var path = uri.replace("file:///", "res://").replace("file://", "res://")
	var project_root = ProjectSettings.globalize_path("res://").replace("\\", "/").trim_suffix("/")
	if uri.begins_with("file://" + project_root):
		path = "res://" + uri.trim_prefix("file://" + project_root).trim_prefix("/")
	return path

func _res_path_to_uri(res_path: String) -> String:
	var global = ProjectSettings.globalize_path(res_path).replace("\\", "/")
	return "file:///" + global.trim_prefix("/")

func notify_did_open(path: String, text: String):
	if not is_ready():
		return
	var uri = _res_path_to_uri(path)
	send_notification("textDocument/didOpen", {
		"textDocument": {
			"uri": uri,
			"languageId": "gdscript",
			"version": 1,
			"text": text
		}
	})

func notify_did_change(path: String, text: String, version: int = 2):
	if not is_ready():
		return
	var uri = _res_path_to_uri(path)
	send_notification("textDocument/didChange", {
		"textDocument": {
			"uri": uri,
			"version": version
		},
		"contentChanges": [
			{ "text": text }
		]
	})

func get_cached_diagnostics(path: String) -> Array:
	if _diagnostics_cache.has(path):
		return _diagnostics_cache[path]
	return []

# --- Native Static Fallback (When LSP is offline) ---
static func check_syntax_native(code: String, path: String = "") -> Dictionary:
	var script = GDScript.new()
	script.source_code = code
	var err = script.reload()
	if err == OK:
		return { "valid": true, "errors": [], "message": "Syntax valid." }
	else:
		return {
			"valid": false,
			"errors": [{
				"line": 0,
				"message": "Script syntax check failed with error code: " + str(err)
			}],
			"message": "Error code " + str(err) + " during GDScript parse/reload."
		}
