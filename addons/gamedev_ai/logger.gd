@tool
extends RefCounted
## Simple logger that relays formatted entries to the dock UI via signal.

signal new_log_entry(entry: Dictionary)

func log_error(message: String, source: String = ""):
	_relay({
		"type": "error",
		"message": message,
		"source": source,
		"timestamp": Time.get_datetime_string_from_system()
	})

func log_warning(message: String, source: String = ""):
	_relay({
		"type": "warning",
		"message": message,
		"source": source,
		"timestamp": Time.get_datetime_string_from_system()
	})

func log_message(message: String):
	_relay({
		"type": "info",
		"message": message,
		"timestamp": Time.get_datetime_string_from_system()
	})

func _relay(entry: Dictionary):
	new_log_entry.emit(entry)

func register_logger():
	print("Gamedev AI Logger ready.")

func unregister_logger():
	pass
