@tool
extends BaseToolHandler
class_name ProjectTools

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"create_scene":
			_create_scene(args.get("path"), args.get("root_type"), args.get("root_name"))
			return true
		"create_resource":
			_create_resource(args.get("path"), args.get("type"), args.get("properties", {}))
			return true
		"run_tests":
			_run_tests(args.get("test_script_path", ""))
			return true
		"get_class_info":
			_get_class_info(args.get("class_name", ""))
			return true
		"view_file_outline":
			_view_file_outline(args.get("path"))
			return true
		"read_skill":
			_read_skill(args.get("skill_name"))
			return true
		"capture_editor_screenshot":
			_capture_editor_screenshot()
			return true
		"get_lsp_diagnostics":
			_get_lsp_diagnostics(args.get("path"), args.get("source_code", ""))
			return true
	return false

# --- Utility ---

func _get_available_skills_list() -> String:
	var list := ""
	var skills_dir := DirAccess.open("res://addons/gamedev_ai/skills")
	if skills_dir:
		skills_dir.list_dir_begin()
		var file_name := skills_dir.get_next()
		while file_name != "":
			if not skills_dir.current_is_dir() and file_name.ends_with(".md"):
				list += "- " + file_name + "\n"
			file_name = skills_dir.get_next()
	return list

func _scan_fs():
	EditorInterface.get_resource_filesystem().scan()

# --- Actions ---

func _create_scene(path: String, root_type: String, root_name: String):
	if not path.begins_with("res://") or not path.ends_with(".tscn"):
		_emit_output("Error: Path must start with res:// and end with .tscn")
		return
		
	if FileAccess.file_exists(path):
		_emit_output("Error: Scene file already exists at " + path + ". Use modify tools like add_node or set_property instead.")
		return
		
	var ur = _get_undo_redo()
	if ur:
		if not _is_composite():
			ur.create_action("Create Scene " + path.get_file(), UndoRedo.MERGE_DISABLE, executor)
			
		# Route through executor's helper to create the file and push into history correctly
		ur.add_do_method(executor, "_create_scene_file", path, root_type, root_name)
		ur.add_undo_method(executor, "_delete_file_undoable", path)
		
		if not _is_composite():
			ur.commit_action()
			_emit_output("Success: Scene " + path + " created (queued for creation).")
		else:
			_emit_output("Success: Scene creation queued for " + path)
	else:
		executor._create_scene_file(path, root_type, root_name)
		_emit_output("Success: Scene " + path + " created (No Undo).")

func _create_resource(path: String, type: String, properties: Variant = {}):
	if not path.begins_with("res://") or not path.ends_with(".tres"):
		_emit_output("Error: Path must specify a .tres file.")
		return
	if FileAccess.file_exists(path):
		_emit_output("Error: File already exists at " + path)
		return

	# Parse properties if they came as a JSON string from the LLM
	var props: Dictionary = {}
	if properties is Dictionary:
		props = properties
	elif properties is String:
		var json = JSON.new()
		var parse_err = json.parse(properties)
		if parse_err == OK and json.data is Dictionary:
			props = json.data
		else:
			_emit_output("Error: 'properties' must be a Dictionary or a valid JSON string. Got: " + str(properties).substr(0, 100))
			return

	var res: Resource = null

	# Check if the user specified a script path in properties (for custom classes)
	var script_path: String = props.get("script", "")
	if script_path != "" and script_path.begins_with("res://"):
		props.erase("script")
		if FileAccess.file_exists(script_path):
			var script = load(script_path)
			if script and script is GDScript:
				res = script.new()
			else:
				_emit_output("Error: Could not load script at " + script_path)
				return
		else:
			_emit_output("Error: Script file not found: " + script_path)
			return
	elif ClassDB.class_exists(type):
		res = ClassDB.instantiate(type)
	else:
		# Try to find the class as a global GDScript class
		var global_classes = ProjectSettings.get_global_class_list()
		for cls in global_classes:
			if cls["class"] == type:
				var script = load(cls["path"])
				if script and script is GDScript:
					res = script.new()
				break
		if not res:
			_emit_output("Error: Class type '" + type + "' not found in ClassDB or global scripts.")
			return

	if not res:
		_emit_output("Error: Could not instantiate " + type)
		return

	# Apply properties, with special handling for resource paths
	for key in props:
		var value = props[key]
		if value is String and value.begins_with("res://"):
			var loaded = load(value)
			if loaded:
				res.set(key, loaded)
			else:
				push_warning("GamedevAI: Could not load resource for property '" + key + "': " + value)
				res.set(key, value)
		else:
			res.set(key, value)

	var err = ResourceSaver.save(res, path)
	if err == OK:
		_scan_fs()
		_emit_output("Success: Resource created at " + path)
	else:
		_emit_output("Error: Failed to save resource. Code: " + str(err))

func _run_tests(test_script_path: String):
	if executor and "test_runner" in executor and executor.test_runner:
		var tr = executor.test_runner
		var res = tr.run_gut_tests(test_script_path)
		if res.get("success", false):
			_emit_output("[color=cyan]🧪 Test Runner started (PID: " + str(res.get("pid", 0)) + ", Mode: " + str(res.get("mode", "async")) + ").[/color]\nExecuting tests in background...")
		else:
			_emit_output("[color=red]Error starting tests: " + str(res.get("error", "Unknown error")) + "[/color]")
		return

	# Fallback if TestRunner not instantiated
	var exe_path = OS.get_executable_path()
	var args = ["--headless"]
	if test_script_path != "":
		if not test_script_path.begins_with("res://"):
			_emit_output("Error: Test script path must start with res://")
			return
		args.append("-s")
		args.append(test_script_path)
	else:
		if FileAccess.file_exists("res://addons/gut/gut_cmdln.gd"):
			args.append("-s")
			args.append("res://addons/gut/gut_cmdln.gd")
			args.append("-gexit")
		else:
			_emit_output("Error: No test runner found and no test script provided.")
			return
	var pid = OS.create_process(exe_path, args)
	_emit_output("Tests started (PID: " + str(pid) + ")")

func _get_lsp_diagnostics(path: String, source_code: String = ""):
	if not path.begins_with("res://"):
		_emit_output("Error: Path must start with res://")
		return
		
	var code = source_code
	if code == "":
		if not FileAccess.file_exists(path):
			_emit_output("Error: File not found at " + path)
			return
		var f = FileAccess.open(path, FileAccess.READ)
		if f:
			code = f.get_as_text()
			f.close()
		else:
			_emit_output("Error: Could not open file at " + path)
			return

	# 1. Try LSP Client if available and connected
	if executor and "lsp_client" in executor and executor.lsp_client:
		var lsp = executor.lsp_client
		if lsp.is_ready():
			lsp.notify_did_open(path, code)
			var diags = lsp.get_cached_diagnostics(path)
			if diags.is_empty():
				_emit_output("✅ [b]LSP Diagnostics for " + path.get_file() + ":[/b] No errors or warnings detected.")
			else:
				var msg = "⚠️ [b]LSP Diagnostics for " + path.get_file() + ":[/b]\n"
				for d in diags:
					var line = d.get("range", {}).get("start", {}).get("line", 0) + 1
					var sev = d.get("severity", 1)
					var sev_str = "ERROR" if sev == 1 else ("WARNING" if sev == 2 else "INFO")
					var message = d.get("message", "")
					msg += "• [L" + str(line) + "][" + sev_str + "] " + message + "\n"
				_emit_output(msg)
			return

	# 2. Fallback to Native GDScript static syntax check
	var LSPClientScript = load("res://addons/gamedev_ai/lsp_client.gd")
	if LSPClientScript:
		var result = LSPClientScript.check_syntax_native(code, path)
		if result.get("valid", false):
			_emit_output("✅ [b]Native GDScript Syntax Check for " + path.get_file() + ":[/b] Valid syntax (0 errors).")
		else:
			_emit_output("❌ [b]Native GDScript Syntax Check for " + path.get_file() + ":[/b]\n" + result.get("message", "Syntax error"))
	else:
		_emit_output("LSP Client not available.")

func _get_class_info(cls_name: String):
	if not ClassDB.class_exists(cls_name):
		_emit_output("Error: Class '" + cls_name + "' not found in ClassDB.")
		return
	var info = "Class: " + cls_name + "\nInherits: " + ClassDB.get_parent_class(cls_name) + "\n\nProperties:\n"
	for p in ClassDB.class_get_property_list(cls_name, true):
		if p.usage & PROPERTY_USAGE_EDITOR:
			info += "- " + p.name + " (Type: " + str(p.type) + ")\n"
	info += "\nMethods:\n"
	for m in ClassDB.class_get_method_list(cls_name, true):
		if not m.name.begins_with("_"):
			info += "- " + m.name + "(" + str(m.args.size()) + " args)\n"
	info += "\nSignals:\n"
	for s in ClassDB.class_get_signal_list(cls_name, true):
		info += "- " + s.name + "\n"
	_emit_output(info)

func _view_file_outline(path: String):
	if not FileAccess.file_exists(path):
		_emit_output("Error: File not found at " + path + ".")
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		_emit_output("Error: Cannot open file at " + path)
		return
	var outline = "Outline of " + path.get_file() + ":\n\n"
	var line_num = 0
	while not file.eof_reached():
		line_num += 1
		var line = file.get_line()
		var stripped = line.strip_edges()
		if stripped == "" or stripped.begins_with("#"): continue
		
		if stripped.begins_with("class_name "): outline += "L" + str(line_num) + " | class_name " + stripped.substr(11).strip_edges() + "\n"
		elif stripped.begins_with("extends "): outline += "L" + str(line_num) + " | extends " + stripped.substr(8).strip_edges() + "\n"
		elif stripped.begins_with("class "): outline += "L" + str(line_num) + " | " + stripped.split(":")[0].strip_edges() + "\n"
		elif stripped.begins_with("enum "): outline += "L" + str(line_num) + " | " + stripped.split("{")[0].strip_edges() + "\n"
		elif stripped.begins_with("signal "): outline += "L" + str(line_num) + " | " + stripped + "\n"
		elif stripped.begins_with("@export"):
			if "var " in stripped: outline += "L" + str(line_num) + " | @export " + stripped.substr(stripped.find("var ")).split("=")[0].strip_edges() + "\n"
			else: outline += "L" + str(line_num) + " | " + stripped + "\n"
		elif stripped.begins_with("func ") or stripped.begins_with("static func "):
			var func_sig = stripped.split(":")[0].strip_edges()
			if func_sig.ends_with(")"): outline += "L" + str(line_num) + " | " + func_sig + "\n"
			else:
				outline += "L" + str(line_num) + " | " + func_sig
				if ":" in stripped and "->" in stripped: outline += " -> " + stripped.split("->")[1].split(":")[0].strip_edges()
				outline += "\n"
		elif stripped.begins_with("const ") or (stripped.begins_with("var ") and not line.begins_with("\t")):
			outline += "L" + str(line_num) + " | " + stripped.split("=")[0].strip_edges() + "\n"
	
	if outline.ends_with(":\n\n"): outline += "(empty file)\n"
	outline += "\nTotal lines: " + str(line_num)
	_emit_output(outline)

func _read_skill(skill_name: String):
	if not skill_name.ends_with(".md"):
		if FileAccess.file_exists("res://addons/gamedev_ai/skills/" + skill_name + ".md"):
			skill_name += ".md"
	var path = "res://addons/gamedev_ai/skills/" + skill_name
	if not FileAccess.file_exists(path):
		_emit_output("Error: Skill '" + skill_name + "' not found. Available skills:\n" + _get_available_skills_list())
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		_emit_output("Error: Failed to open skill file '" + path + "'.")
		return
	var content = file.get_as_text()
	file.close()
	_emit_output("--- SKILL LOADED: " + skill_name + " ---\n\n" + content)

func _capture_editor_screenshot():
	var base_control = EditorInterface.get_base_control()
	if not base_control:
		_emit_output("Error: Editor base control not found.")
		return
	var viewport = base_control.get_viewport()
	if not viewport:
		_emit_output("Error: Editor viewport not found.")
		return
	var tex = viewport.get_texture()
	if not tex:
		_emit_output("Error: Viewport texture empty.")
		return
	var img = tex.get_image()
	if not img or img.is_empty():
		_emit_output("Error: Failed to capture editor screenshot. Image is empty.")
		return
		
	var user_dir = "user://temp_ai_screenshot.png"
	var err = img.save_png(user_dir)
	if err == OK:
		_emit_output("Screenshot saved to " + user_dir + ". It will be attached in the next conversational turn automatically.")
		if executor.has_signal("image_captured"):
			executor.image_captured.emit(user_dir)
	else:
		_emit_output("Error: Failed to save screenshot. Code: " + str(err))
