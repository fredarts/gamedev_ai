@tool
extends RefCounted
class_name TestRunner

signal test_output(line: String)
signal tests_finished(summary: Dictionary)

var _is_running: bool = false
var _process_pid: int = -1
var _pipe_dict: Dictionary = {}
var _start_time: float = 0.0
var _timeout_seconds: float = 45.0
var _output_accumulator: String = ""
var _log_file_path: String = "user://gamedev_ai_gut_run.log"

func is_running() -> bool:
	return _is_running

func run_gut_tests(test_path: String = "", custom_args: Array = []) -> Dictionary:
	if _is_running:
		return { "success": false, "error": "A test suite is already running (PID: " + str(_process_pid) + ")." }
		
	var exe_path = OS.get_executable_path()
	var args: Array = ["--headless"]
	
	# Determine test script
	var has_gut = FileAccess.file_exists("res://addons/gut/gut_cmdln.gd")
	var has_gdunit = FileAccess.file_exists("res://addons/gdUnit4/runtest.gd")
	
	if test_path != "":
		if not test_path.begins_with("res://"):
			return { "success": false, "error": "Test path must start with res://" }
		
		if test_path.ends_with(".gd"):
			if has_gut:
				args.append("-s")
				args.append("res://addons/gut/gut_cmdln.gd")
				args.append("-gtest=" + test_path)
			elif has_gdunit:
				args.append("-s")
				args.append("res://addons/gdUnit4/runtest.gd")
				args.append("-a=" + test_path)
			else:
				args.append("-s")
				args.append(test_path)
		else:
			# Directory path
			if has_gut:
				args.append("-s")
				args.append("res://addons/gut/gut_cmdln.gd")
				args.append("-gdir=" + test_path)
			else:
				return { "success": false, "error": "GUT (res://addons/gut/gut_cmdln.gd) required for directory-based testing." }
	else:
		if has_gut:
			args.append("-s")
			args.append("res://addons/gut/gut_cmdln.gd")
		elif has_gdunit:
			args.append("-s")
			args.append("res://addons/gdUnit4/runtest.gd")
		else:
			return { "success": false, "error": "No test runner found (GUT or GdUnit4) and no test script provided." }

	# Critical Flags: Exit when done + verbose log + rendering dummy
	if has_gut:
		args.append("-gexit")
		args.append("-glog=3")
	
	args.append("--rendering-driver")
	args.append("dummy")
	
	for ca in custom_args:
		args.append(str(ca))
		
	_output_accumulator = ""
	_start_time = Time.get_ticks_msec() / 1000.0
	
	# Try execute_with_pipe if available in Godot 4.2+
	if OS.has_method("execute_with_pipe"):
		_pipe_dict = OS.execute_with_pipe(exe_path, args)
		if _pipe_dict.has("pid") and _pipe_dict["pid"] != -1:
			_process_pid = _pipe_dict["pid"]
			_is_running = true
			return { "success": true, "pid": _process_pid, "mode": "pipe" }

	# Fallback to create_process with log redirection
	var pid = OS.create_process(exe_path, args)
	if pid == -1:
		return { "success": false, "error": "Failed to spawn Godot test process." }
		
	_process_pid = pid
	_is_running = true
	return { "success": true, "pid": _process_pid, "mode": "process" }

func poll():
	if not _is_running:
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	var elapsed = current_time - _start_time
	
	# Watchdog timer check
	if elapsed > _timeout_seconds:
		_emit_line("[color=red]Error: Test execution timed out after " + str(_timeout_seconds) + " seconds. Killing process PID " + str(_process_pid) + ".[/color]")
		cancel_run()
		var timeout_summary = {
			"success": false,
			"timed_out": true,
			"raw_output": _output_accumulator,
			"passed": 0,
			"failed": 1,
			"errors": ["Watchdog timeout: test process took longer than " + str(_timeout_seconds) + "s."]
		}
		tests_finished.emit(timeout_summary)
		return

	# Read from pipe if available
	if not _pipe_dict.is_empty() and _pipe_dict.has("stdio"):
		var stdio = _pipe_dict["stdio"]
		if is_instance_valid(stdio) and stdio is FileAccess and stdio.is_open():
			var length = stdio.get_length()
			var cur_pos = stdio.get_position()
			if length > cur_pos:
				var new_text = stdio.get_as_text()
				if new_text != "":
					_output_accumulator += new_text
					_emit_line(new_text)

	# Check process status
	if not OS.is_process_running(_process_pid):
		_is_running = false
		_process_pid = -1
		var summary = parse_gut_output(_output_accumulator)
		tests_finished.emit(summary)

func cancel_run():
	if _is_running and _process_pid != -1:
		OS.kill(_process_pid)
		_is_running = false
		_process_pid = -1

func _emit_line(text: String):
	test_output.emit(text)

# --- Parser de Saída do GUT ---
static func parse_gut_output(raw: String) -> Dictionary:
	var passed = 0
	var failed = 0
	var pending = 0
	var asserts_passed = 0
	var asserts_failed = 0
	var errors: Array = []
	
	var lines = raw.split("\n")
	for line in lines:
		var s = line.strip_edges()
		
		# Detect assertion failures
		if s.contains("[Failed]") or s.contains("failed:") or s.contains("Asserts:") or s.begins_with("at line"):
			if not s.is_empty():
				errors.append(s)
				
		# Extract test counts: e.g. "Passing Tests: 5", "Failing Tests: 1"
		if s.begins_with("Passing Tests:") or s.contains("Passed:"):
			var parts = s.split(":")
			if parts.size() > 1:
				passed = parts[1].strip_edges().to_int()
		elif s.begins_with("Failing Tests:") or s.contains("Failed:"):
			var parts = s.split(":")
			if parts.size() > 1:
				failed = parts[1].strip_edges().to_int()
		elif s.begins_with("Pending Tests:") or s.contains("Pending:"):
			var parts = s.split(":")
			if parts.size() > 1:
				pending = parts[1].strip_edges().to_int()

	var success = (failed == 0 and errors.is_empty())
	
	return {
		"success": success,
		"passed": passed,
		"failed": failed,
		"pending": pending,
		"asserts_passed": asserts_passed,
		"asserts_failed": asserts_failed,
		"errors": errors,
		"raw_output": raw
	}
