@tool
extends RefCounted
class_name AIProvider

signal response_received(response)
signal error_occurred(error_msg)
signal tool_call_received(tool_calls)
signal status_changed(is_requesting)

var api_key: String = ""
var http_request: HTTPRequest
var history: Array = [] # Stores conversation history (Technical format)
var transcript: Array = [] # Stores user-friendly text for UI display
var is_requesting: bool = false : set = _set_is_requesting
var current_session_id: String = ""

const MAX_HISTORY_TURNS = 100 
const HISTORY_DIR = "res://.gamedev_ai/history/"

func setup(node: Node):
	http_request = HTTPRequest.new()
	node.add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	http_request.use_threads = true

func set_api_key(key: String):
	api_key = key

func clear_history():
	history.clear()
	transcript.clear()
	current_session_id = ""
	is_requesting = false

func new_session():
	clear_history()
	current_session_id = str(Time.get_unix_time_from_system()).replace(".", "_")
	save_session()

func _ensure_history_dir():
	if not DirAccess.dir_exists_absolute(HISTORY_DIR):
		DirAccess.make_dir_recursive_absolute(HISTORY_DIR)

func save_session():
	if current_session_id == "": return
	_ensure_history_dir()
	
	var data = {
		"id": current_session_id,
		"history": history,
		"transcript": transcript,
		"last_modified": Time.get_datetime_dict_from_system()
	}
	
	var file = FileAccess.open(HISTORY_DIR + current_session_id + ".json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_session(session_id: String) -> bool:
	var path = HISTORY_DIR + session_id + ".json"
	if not FileAccess.file_exists(path): return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data:
		history = data.get("history", [])
		transcript = data.get("transcript", [])
		current_session_id = data.get("id", session_id)
		return true
	return false

func list_sessions() -> Array:
	_ensure_history_dir()
	var sessions = []
	var dir = DirAccess.open(HISTORY_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var session_data = _read_session_metadata(HISTORY_DIR + file_name)
				if not session_data.is_empty():
					sessions.append(session_data)
			file_name = dir.get_next()
	sessions.sort_custom(func(a, b): return _datetime_to_unix(a.last_modified) > _datetime_to_unix(b.last_modified))
	return sessions

func _read_session_metadata(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	if data:
		var title = "New Chat"
		var t = data.get("transcript", [])
		if not t.is_empty():
			title = t[0].get("text", "New Chat").left(40).strip_edges() + "..."
		return {
			"id": data.get("id"),
			"title": title,
			"last_modified": data.get("last_modified")
		}
	return {}

func _datetime_to_unix(dt: Dictionary) -> int:
	return Time.get_unix_time_from_datetime_dict(dt)

func _set_is_requesting(value: bool):
	is_requesting = value
	status_changed.emit(is_requesting)

func cancel_request():
	if http_request and http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		http_request.cancel_request()
	is_requesting = false

# Virtual methods to be overridden
func send_prompt(_prompt: String, _context: String = "", _tools: Array = [], _image_data: Dictionary = {}):
	pass

func send_tool_responses(_responses: Array, _tools: Array = []):
	pass

func generate_tool_response(_tool_name: String, _output: String, _tool_call_id: String = "") -> Dictionary:
	return {}

func _on_request_completed(_result, _response_code, _headers, _body):
	pass

func _format_api_error(code: int, json: Dictionary) -> String:
	return "API Error (" + str(code) + "): " + str(json)
