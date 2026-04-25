@tool
extends RefCounted
class_name AIProvider

signal response_received(response)
signal audio_received(audio_data: PackedByteArray)
signal error_occurred(error_msg)
signal tool_call_received(tool_calls)
signal status_changed(is_requesting)
signal token_usage_reported(usage: Dictionary)

var api_key: String = ""
var custom_instructions: String = ""
var screenshot_enabled: bool = false
var response_language_instruction: String = ""
var http_request: HTTPRequest
var history: Array = [] # Stores conversation history (Technical format)
var transcript: Array = [] # Stores user-friendly text for UI display
var is_requesting: bool = false : set = _set_is_requesting
var current_session_id: String = ""
var _timeout_timer: Timer
var _retry_count: int = 0

const MAX_HISTORY_TURNS = 100 
const HISTORY_DIR = "res://.gamedev_ai/history/"
const REQUEST_TIMEOUT_SECS = 360.0
const MAX_RETRIES = 2

func setup(node: Node):
	http_request = HTTPRequest.new()
	node.add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	http_request.use_threads = true
	
	_timeout_timer = Timer.new()
	_timeout_timer.one_shot = true
	_timeout_timer.wait_time = REQUEST_TIMEOUT_SECS
	_timeout_timer.timeout.connect(_on_timeout)
	node.add_child(_timeout_timer)

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

func list_sessions(offset: int = 0, limit: int = 15) -> Array:
	_ensure_history_dir()
	var files_info = []
	var dir = DirAccess.open(HISTORY_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var path = HISTORY_DIR + file_name
				var mtime = FileAccess.get_modified_time(path)
				files_info.append({"name": file_name, "mtime": mtime})
			file_name = dir.get_next()
			
	files_info.sort_custom(func(a, b): return a.mtime > b.mtime)
	
	var sessions = []
	var end_idx = files_info.size()
	if limit > 0:
		end_idx = min(offset + limit, files_info.size())
		
	for i in range(offset, end_idx):
		var session_data = _read_session_metadata(HISTORY_DIR + files_info[i].name)
		if not session_data.is_empty():
			sessions.append(session_data)
			
	return sessions

func _read_session_metadata(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	if data and data is Dictionary:
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
	if _timeout_timer:
		_timeout_timer.stop()
	if http_request and http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		http_request.cancel_request()
	_retry_count = 0
	is_requesting = false

func _start_timeout():
	if _timeout_timer:
		_timeout_timer.start()

func _stop_timeout():
	if _timeout_timer:
		_timeout_timer.stop()

func _on_timeout():
	if is_requesting:
		cancel_request()
		error_occurred.emit("⚠️ Request Timeout\n\nThe API did not respond within " + str(int(REQUEST_TIMEOUT_SECS)) + " seconds. Please try again.")

# Virtual methods to be overridden
func send_prompt(_prompt: String, _context: String = "", _tools: Array = [], _files: Array = []):
	pass

func request_tts(_text: String):
	pass

func send_tool_responses(_responses: Array, _tools: Array = []):
	pass

func generate_tool_response(_tool_name: String, _output: String, _tool_call_id: String = "") -> Dictionary:
	return {}

func _on_request_completed(_result, _response_code, _headers, _body):
	pass

func _format_api_error(code: int, json: Dictionary) -> String:
	return "API Error (" + str(code) + "): " + str(json)
