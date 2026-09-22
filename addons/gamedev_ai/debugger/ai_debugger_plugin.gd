@tool
extends EditorDebuggerPlugin

## AIDebuggerPlugin
## Captures runtime errors, crashes, stack traces, and debug session events from Godot's runtime sessions.
## Exposes them to Gamedev AI tool executor, dock, and MCP clients.

signal runtime_error_captured(error_info: Dictionary)
signal session_state_changed(is_active: bool)

var is_session_active: bool = false
var is_paused: bool = false
var active_session_id: int = -1

const MAX_ERROR_HISTORY = 100
const MAX_LOG_HISTORY = 200

var _errors: Array = []
var _logs: Array = []

func _has_capture(prefix: String) -> bool:
	# Accept captures for standard godot debugger prefixes
	return true

func _capture(message: String, data: Array, session_id: int) -> bool:
	var timestamp = Time.get_datetime_string_from_system()
	var entry = {
		"timestamp": timestamp,
		"message": message,
		"data": data,
		"session_id": session_id
	}
	
	_logs.append(entry)
	if _logs.size() > MAX_LOG_HISTORY:
		_logs.pop_front()
		
	# Check if message is an error or warning
	if message.contains("error") or message.contains("crash") or message.contains("exception"):
		var err_dict = {
			"timestamp": timestamp,
			"session_id": session_id,
			"raw_message": message,
			"data": data,
			"type": "error"
		}
		_errors.append(err_dict)
		if _errors.size() > MAX_ERROR_HISTORY:
			_errors.pop_front()
		runtime_error_captured.emit(err_dict)
		
	return false

func _setup_session(session_id: int):
	var session = get_session(session_id)
	if not session:
		return
		
	active_session_id = session_id
	
	session.started.connect(func():
		is_session_active = true
		is_paused = false
		session_state_changed.emit(true)
		var start_entry = {
			"timestamp": Time.get_datetime_string_from_system(),
			"event": "session_started",
			"session_id": session_id
		}
		_logs.append(start_entry)
	)
	
	session.stopped.connect(func():
		is_session_active = false
		is_paused = false
		session_state_changed.emit(false)
		var stop_entry = {
			"timestamp": Time.get_datetime_string_from_system(),
			"event": "session_stopped",
			"session_id": session_id
		}
		_logs.append(stop_entry)
	)
	
	session.breaked.connect(func(can_debug: bool):
		is_paused = true
		var break_entry = {
			"timestamp": Time.get_datetime_string_from_system(),
			"event": "session_breaked",
			"can_debug": can_debug,
			"session_id": session_id
		}
		_logs.append(break_entry)
	)
	
	session.continued.connect(func():
		is_paused = false
	)

func get_runtime_errors() -> Array:
	return _errors.duplicate(true)

func clear_runtime_errors():
	_errors.clear()

func get_runtime_status() -> Dictionary:
	return {
		"is_active": is_session_active,
		"is_paused": is_paused,
		"active_session_id": active_session_id,
		"total_errors_recorded": _errors.size(),
		"total_logs_recorded": _logs.size(),
		"last_error": _errors.back() if not _errors.is_empty() else null
	}

func get_formatted_runtime_logs() -> String:
	if _logs.is_empty() and _errors.is_empty():
		return "No runtime debug logs recorded yet."
		
	var output: Array = []
	output.append("=== GODOT RUNTIME DEBUG LOGS ===")
	output.append("Session Active: " + str(is_session_active) + " | Paused: " + str(is_paused))
	output.append("Recorded Errors: " + str(_errors.size()))
	output.append("--------------------------------")
	
	for err in _errors:
		output.append("[" + err.get("timestamp", "") + "] ERROR: " + str(err.get("raw_message", "")) + " (Data: " + str(err.get("data", [])) + ")")
		
	return "\n".join(output)

# Simulated error injector for testing
func inject_simulated_error(message: String, data: Array = []):
	var err_dict = {
		"timestamp": Time.get_datetime_string_from_system(),
		"session_id": active_session_id if active_session_id != -1 else 0,
		"raw_message": message,
		"data": data,
		"type": "simulated_error"
	}
	_errors.append(err_dict)
	if _errors.size() > MAX_ERROR_HISTORY:
		_errors.pop_front()
	runtime_error_captured.emit(err_dict)
