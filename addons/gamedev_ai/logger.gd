@tool
extends RefCounted

signal new_log_entry(entry)

func _init():
	pass

# We don't need to override _log_error from a parent class anymore since we are just a helper.
# But we can keep the signature if we want to call it manually, or simplify it.
# Let's keep it simple and just have a generic log function.

func log_error(message: String, source: String = ""):
	var entry = {
		"type": "error",
		"message": message,
		"source": {"file": source, "line": 0, "func": ""},
		"timestamp": Time.get_datetime_string_from_system()
	}
	_relay_log(entry)

func log_message(message: String):
	var entry = {
		"type": "message",
		"message": message,
		"timestamp": Time.get_datetime_string_from_system()
	}
	_relay_log(entry)

func _relay_log(entry):
	emit_signal("new_log_entry", entry)

func register_logger():
	# OS.add_logger is not a thing in Godot 4 GDScript for custom loggers
	# We rely on our own tool execution to log to us
	print("Gamedev AI Logger initialized")

func unregister_logger():
	pass
