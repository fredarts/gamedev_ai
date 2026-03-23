@tool
extends RefCounted

signal tool_output(output)
signal confirmation_needed(message: String, tool_name: String, args: Dictionary)
signal diff_preview_requested(path: String, old_content: String, new_content: String, tool_name: String, args: Dictionary)
signal image_captured(image_path: String)

var _undo_redo: EditorUndoRedoManager
var memory_manager
var _composite_action_name: String = ""
var _pending_confirm_tool: String = ""
var vector_db
var _pending_confirm_args: Dictionary = {}

var use_diff_preview: bool = true
var _pending_diff_new_content: String = ""
var _pending_diff_old_content: String = ""
var _pending_diff_path: String = ""
var _handlers: Array = []

# Required args per tool: { tool_name: ["arg1", "arg2", ...] }
const _TOOL_REQUIRED_ARGS = {
	"create_script": ["path", "content"],
	"add_node": ["parent_path", "type", "name"],
	"attach_script": ["node_path", "script_path"],
	"create_scene": ["path", "root_type", "root_name"],
	"instance_scene": ["parent_path", "scene_path", "name"],
	"edit_script": ["path", "content"],
	"remove_node": ["node_path"],
	"remove_file": ["path"],
	"list_dir": ["path"],
	"read_file": ["path"],
	"find_file": ["pattern"],
	"set_property": ["node_path", "property", "value"],
	"set_theme_override": ["node_path", "override_type", "name", "value"],
	"replace_selection": ["text"],
	"get_class_info": ["class_name"],
	"patch_script": ["path", "search_content", "replace_content"],
	"connect_signal": ["source_path", "signal_name", "target_path", "method_name"],
	"disconnect_signal": ["source_path", "signal_name", "target_path", "method_name"],
	"create_resource": ["path", "type"],
	"run_tests": [],
	"grep_search": ["query"],
	"view_file_outline": ["path"],
	"save_memory": ["category", "content"],
	"list_memories": [],
	"delete_memory": ["id"],
	"search_in_files": ["pattern"],
	"read_skill": ["skill_name"],
	"move_files_batch": ["moves"],
	"capture_editor_screenshot": [],
	"index_codebase": [],
	"semantic_search": ["query"],
	"analyze_node_children": ["node_path"]
}

func _validate_args(tool_name: String, args: Dictionary) -> Dictionary:
	if not _TOOL_REQUIRED_ARGS.has(tool_name):
		return {"valid": false, "error": "Unknown tool '" + tool_name + "'. Available tools: " + str(_TOOL_REQUIRED_ARGS.keys())}
	
	var required = _TOOL_REQUIRED_ARGS[tool_name]
	var missing = []
	for arg_name in required:
		if not args.has(arg_name) or args[arg_name] == null:
			missing.append(arg_name)
	
	if not missing.is_empty():
		return {"valid": false, "error": "Tool '" + tool_name + "' is missing required arguments: " + str(missing) + ". Please provide all required arguments and try again."}
	
	# Type-specific validations
	if args.has("path") and args["path"] is String:
		var path: String = args["path"]
		if tool_name in ["create_script", "edit_script", "read_file", "patch_script", "remove_file", "list_dir", "create_resource"]:
			if not path.begins_with("res://"):
				return {"valid": false, "error": "Parameter 'path' must start with 'res://'. Got: '" + path + "'"}
		
		if tool_name == "create_scene" and (not path.begins_with("res://") or not path.ends_with(".tscn")):
			return {"valid": false, "error": "Parameter 'path' must start with 'res://' and end with '.tscn'. Got: '" + path + "'"}
		
		if tool_name == "create_resource" and not path.ends_with(".tres"):
			return {"valid": false, "error": "Parameter 'path' must end with '.tres'. Got: '" + path + "'"}
	
	return {"valid": true, "error": ""}

func _init():
	pass

func setup(undo_redo: EditorUndoRedoManager):
	_undo_redo = undo_redo
	_handlers.clear()
	var ScriptTools = load("res://addons/gamedev_ai/tools/script_tools.gd")
	var NodeTools = load("res://addons/gamedev_ai/tools/node_tools.gd")
	var FileTools = load("res://addons/gamedev_ai/tools/file_tools.gd")
	var ProjectTools = load("res://addons/gamedev_ai/tools/project_tools.gd")
	var MemoryTools = load("res://addons/gamedev_ai/tools/memory_tools.gd")
	var DBTools = load("res://addons/gamedev_ai/tools/db_tools.gd")
	
	_handlers.append(ScriptTools.new())
	_handlers.append(NodeTools.new())
	_handlers.append(FileTools.new())
	_handlers.append(ProjectTools.new())
	_handlers.append(MemoryTools.new())
	_handlers.append(DBTools.new())
	
	for h in _handlers:
		h.setup(self)

func init_vector_db(node: Node):
	var VectorDB = preload("res://addons/gamedev_ai/vector_db.gd")
	vector_db = VectorDB.new()
	vector_db.setup(node)
	vector_db.db_output.connect(func(out): tool_output.emit(out))

func start_composite_action(name: String):
	if _undo_redo and _composite_action_name == "":
		_composite_action_name = name
		# Force history 0 (Global) by using self as context
		_undo_redo.create_action(name, UndoRedo.MERGE_DISABLE, self)

func commit_composite_action():
	if _undo_redo and _composite_action_name != "":
		_undo_redo.commit_action()
		_composite_action_name = ""

func cancel_pending_action():
	tool_output.emit("[color=orange]Action cancelled by user.[/color]")
	_pending_confirm_tool = ""
	_pending_confirm_args = {}

func undo():
	if _undo_redo:
		var history_id = _undo_redo.get_object_history_id(self)
		var undo_redo_obj = _undo_redo.get_history_undo_redo(history_id)
		if undo_redo_obj:
			undo_redo_obj.undo()

# Proxy methods to force actions into Global History (associated with this tool_executor)
func _proxy_add_child(parent: Node, child: Node):
	if is_instance_valid(parent) and is_instance_valid(child):
		parent.add_child(child)

func _proxy_remove_child(parent: Node, child: Node):
	if is_instance_valid(parent) and is_instance_valid(child):
		parent.remove_child(child)

func _proxy_set_property(obj: Object, property: String, value: Variant):
	if is_instance_valid(obj):
		obj.set(property, value)

func _proxy_set_script(obj: Object, script: Resource):
	if is_instance_valid(obj):
		obj.set_script(script)

func _proxy_call(obj: Object, method: String, arg1: Variant = null, arg2: Variant = null, arg3: Variant = null):
	# Simple generic proxy for up to 3 args
	if is_instance_valid(obj):
		if arg3 != null:
			obj.call(method, arg1, arg2, arg3)
		elif arg2 != null:
			obj.call(method, arg1, arg2)
		elif arg1 != null:
			obj.call(method, arg1)
		else:
			obj.call(method)

# File Undo Helpers (Static-like)
# File Undo Helpers (Static-like)
func _create_file_undoable(path: String, content: String):
	# Ensure directory exists
	var dir_path = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	# Special handling for project.godot: use ProjectSettings API to avoid "reload from disk" popup
	if path == "res://project.godot":
		_apply_project_settings_from_content(content)
		return

	# 1. Try to find if the script is already loaded in memory (open in editor or used by a node)
	# Only do this for script files to prevent loader errors for configs like project.godot
	var script = null
	if path.ends_with(".gd") and FileAccess.file_exists(path):
		script = load(path)
	
	if script and script is Script:
		# Update the source code in memory
		script.source_code = content
		# Trigger a reload to update tool scripts or live instances
		script.reload()
		
		# Save using ResourceSaver, which avoids the "modified outside" popup
		var err = ResourceSaver.save(script)
		if err != OK:
			tool_output.emit("Warning: Helper failed to save open script: " + str(err))
	else:
		# 2. File doesn't exist or isn't a loaded script, write to disk directly
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_string(content)
			file.close()
		else:
			tool_output.emit("Error: Could not open file for write: " + path)
		# Auto-dismiss any "reload" dialogs for non-script config files
		if path.ends_with(".cfg") or path.ends_with(".godot"):
			_auto_dismiss_reload_dialog.call_deferred()

	# 3. Always scan to ensure the filesystem is up to date
	_scan_fs()

func _apply_project_settings_from_content(content: String):
	# Parse .godot/.cfg INI-like format and apply via ProjectSettings API
	var current_section := ""
	var lines = content.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with(";"):
			continue
		
		# Section headers like [application], [display], [rendering], etc.
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			continue
		
		# Skip non-setting sections (metadata headers)
		if current_section in ["godot", "gd_resource"]:
			continue
		
		# Parse key=value pairs
		var eq_pos = line.find("=")
		if eq_pos == -1:
			continue
		
		var key = line.substr(0, eq_pos).strip_edges()
		var value_str = line.substr(eq_pos + 1).strip_edges()
		
		# Build the full setting path: section/key
		var setting_path = key
		if current_section != "":
			setting_path = current_section + "/" + key
		
		# Parse the value using Godot's expression evaluator
		var value = _parse_setting_value(value_str)
		if value != null:
			ProjectSettings.set_setting(setting_path, value)
	
	# Let Godot save it natively — no "reload from disk" popup
	var err = ProjectSettings.save()
	if err != OK:
		tool_output.emit("Warning: ProjectSettings.save() returned error: " + str(err))

func _parse_setting_value(value_str: String):
	# Try to evaluate the value string as a GDScript expression
	var expr = Expression.new()
	var error = expr.parse(value_str)
	if error == OK:
		var result = expr.execute()
		if not expr.has_execute_failed():
			return result
	
	# Fallback: return as raw string (strip surrounding quotes if present)
	if value_str.begins_with("\"") and value_str.ends_with("\""):
		return value_str.substr(1, value_str.length() - 2)
	
	return value_str

func _auto_dismiss_reload_dialog():
	# Search the editor's UI tree for any "reload" confirmation dialog and accept it
	var base = EditorInterface.get_base_control()
	if not base:
		return
	_find_and_accept_reload_dialogs(base)

func _find_and_accept_reload_dialogs(node: Node):
	if node is AcceptDialog and node.visible:
		var dialog_text = ""
		if node is ConfirmationDialog:
			dialog_text = node.dialog_text
		elif node.has_method("get_text"):
			dialog_text = node.get_text()
		# Detect reload/revert dialogs by common keywords
		if "reload" in dialog_text.to_lower() or "revert" in dialog_text.to_lower() or "modified" in dialog_text.to_lower() or "changed" in dialog_text.to_lower():
			node.get_ok_button().emit_signal("pressed")
			node.hide()
			return
	for child in node.get_children():
		_find_and_accept_reload_dialogs(child)

func _delete_file_undoable(path: String):
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		_scan_fs()

func _scan_fs():
	EditorInterface.get_resource_filesystem().scan()


func get_tool_definitions() -> Array:
	return [
		{
			"name": "create_script",
			"description": "Creates a new GDScript file at the specified path with the given content.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The resource path (res://...) for the script."},
					"content": {"type": "STRING", "description": "The GDScript code content."}
				},
				"required": ["path", "content"]
			}
		},
		{
			"name": "add_node",
			"description": "Adds a new node to the currently open scene in the Godot Editor. Use this to visually build levels, scenes, and UI hierarchies.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"parent_path": {"type": "STRING", "description": "Path to the parent node (use '.' for root)."},
					"type": {"type": "STRING", "description": "The class name of the node (e.g., 'Node2D', 'Label')."},
					"name": {"type": "STRING", "description": "The name of the new node."},
					"script_path": {"type": "STRING", "description": "Optional: Path to a GDScript (res://...) to attach to the node."}
				},
				"required": ["parent_path", "type", "name"]
			}
		},
		{
			"name": "attach_script",
			"description": "Attaches an existing GDScript to a node in the current scene.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"node_path": {"type": "STRING", "description": "Path to the node in the scene (e.g., 'Player' or 'Level/Enemy')."},
					"script_path": {"type": "STRING", "description": "Path to the GDScript (res://...)."}
				},
				"required": ["node_path", "script_path"]
			}
		},
		{
			"name": "create_scene",
			"description": "Creates a new scene (.tscn) file and opens it in the editor. Use this to start a new scene or project element from scratch.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The resource path for the scene file (res://...). MUST end in .tscn"},
					"root_type": {"type": "STRING", "description": "The class name of the root node (e.g. 'Node2D', 'CharacterBody2D')."},
					"root_name": {"type": "STRING", "description": "The name of the root node."}
				},
				"required": ["path", "root_type", "root_name"]
			}
		},
		{
			"name": "instance_scene",
			"description": "Instantiates an existing .tscn scene file as a child of another node in the current scene. Use this to place pre-made scenes (like an Enemy) into a level.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"parent_path": {"type": "STRING", "description": "Path to the parent node in the current scene (use '.' for root)."},
					"scene_path": {"type": "STRING", "description": "The resource path to the .tscn file to instantiate."},
					"name": {"type": "STRING", "description": "The name for the new instance node."}
				},
				"required": ["parent_path", "scene_path", "name"]
			}
		},
		{
			"name": "edit_script",
			"description": "(DEPRECATED: Use patch_script) Edits an existing GDScript file. You should read the file first to ensure you have the full current content before providing the updated version.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The resource path (res://...) for the script."},
					"content": {"type": "STRING", "description": "The full updated GDScript code content."}
				},
				"required": ["path", "content"]
			}
		},
		{
			"name": "remove_node",
			"description": "Removes a node from the current scene.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"node_path": {"type": "STRING", "description": "Path to the node in the scene tree to remove."}
				},
				"required": ["node_path"]
			}
		},
		{
			"name": "remove_file",
			"description": "Deletes a file or directory from the project. Use with caution.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The resource path (res://...) to the file or directory to delete."}
				},
				"required": ["path"]
			}
		},
		{
			"name": "list_dir",
			"description": "Lists the contents of a directory.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The directory path (res://...)."}
				},
				"required": ["path"]
			}
		},
		{
			"name": "read_file",
			"description": "Reads the content of a file.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The file path (res://...)."}
				},
				"required": ["path"]
			}
		},
		{
			"name": "find_file",
			"description": "Searches for a file in the project by name (partial match).",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"pattern": {"type": "STRING", "description": "The file name pattern to search for."}
				},
				"required": ["pattern"]
			}
		},
		{
			"name": "set_property",
			"description": "Sets a property on a node in the current scene (e.g., position, size, text, color). Can handle numbers, vectors, colors, and strings.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"node_path": {"type": "STRING", "description": "Path to the node in the scene tree."},
					"property": {"type": "STRING", "description": "The name of the property to set (e.g., 'text', 'size', 'position')."},
					"value": {"description": "The value to set. Can be string, number, or array for vectors [x, y] / colors [r, g, b, a]."}
				},
				"required": ["node_path", "property", "value"]
			}
		},
		{
			"name": "set_theme_override",
			"description": "Sets a theme override on a Control node (e.g., fontSize, fontColor).",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"node_path": {"type": "STRING", "description": "Path to the control node."},
					"override_type": {"type": "STRING", "enum": ["color", "constant", "font", "font_size", "stylebox"], "description": "The type of override."},
					"name": {"type": "STRING", "description": "The name of the theme property (e.g., 'font_color')."},
					"value": {"description": "The value to set (e.g., color array [1, 0, 0] or font size number)."}
				},
				"required": ["node_path", "override_type", "name", "value"]
			}
		},
		{
			"name": "replace_selection",
			"description": "Replaces the currently selected text in the active Godot Script Editor. Use this to refactor or fix code that the user has selected.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"text": {"type": "STRING", "description": "The new code content to replace the selection with."}
				},
				"required": ["text"]
			}
		},
		{
			"name": "get_class_info",
			"description": "Returns detailed information about a Godot class (Engine or Custom), including its base class, properties, methods, and signals. Use this if you are unsure about available properties or methods for a specific node type.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"class_name": {"type": "STRING", "description": "The name of the class to inspect (e.g., 'CharacterBody2D', 'Button')."}
				},
				"required": ["class_name"]
			}
		},
		{
			"name": "patch_script",
			"description": "Surgically edits a script by replacing a specific block of code with new content. Use this for small changes to avoid overwriting the entire file.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The resource path (res://...) of the script."},
					"search_content": {"type": "STRING", "description": "The exact block of code to find and replace. Must be unique in the file."},
					"replace_content": {"type": "STRING", "description": "The new code to insert in place of search_content."}
				},
				"required": ["path", "search_content", "replace_content"]
			}
		},
		{
			"name": "connect_signal",
			"description": "Connects a signal from a source node to a target node's method in the current scene.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"source_path": {"type": "STRING", "description": "Path to the source node emitting the signal."},
					"signal_name": {"type": "STRING", "description": "Name of the signal (e.g., 'pressed', 'body_entered')."},
					"target_path": {"type": "STRING", "description": "Path to the target node receiving the signal."},
					"method_name": {"type": "STRING", "description": "Name of the function to call on the target node."},
					"binds": {"type": "ARRAY", "description": "Optional array of arguments to bind.", "items": {"type": "STRING"}},
					"flags": {"type": "INTEGER", "description": "Optional connection flags (usually 0)."}
				},
				"required": ["source_path", "signal_name", "target_path", "method_name"]
			}
		},
		{
			"name": "disconnect_signal",
			"description": "Disconnects a signal between nodes in the current scene.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"source_path": {"type": "STRING", "description": "Path to the source node."},
					"signal_name": {"type": "STRING", "description": "Name of the signal."},
					"target_path": {"type": "STRING", "description": "Path to the target node."},
					"method_name": {"type": "STRING", "description": "Name of the connected method."}
				},
				"required": ["source_path", "signal_name", "target_path", "method_name"]
			}
		},
		{
			"name": "create_resource",
			"description": "Creates a new Resource file (.tres). Useful for data-driven assets like Items, Stats, or custom configurations.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "Save path (res://.../file.tres)."},
					"type": {"type": "STRING", "description": "The class name of the resource (e.g., 'Resource', 'StandardMaterial3D', or a custom class)."},
					"properties": {"type": "OBJECT", "description": "Dictionary of initial property values { 'prop_name': value }."}
				},
				"required": ["path", "type"]
			}
		},
		{
			"name": "run_tests",
			"description": "Runs a test script or command. Use this to verify your changes if the user has a test suite (GUT, GdUnit4) or a custom test script.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"test_script_path": {"type": "STRING", "description": "Optional: Path to a specific test script to run (res://tests/test_...gd). If omitted, tries to run the project's default test configuration."}
				}
			}
		},
		{
			"name": "grep_search",
			"description": "Searches for text content inside project files. Use this to find references to functions, variables, classes, or any text pattern across the codebase. Returns matching lines with file path and line number.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"query": {"type": "STRING", "description": "The text pattern to search for (case-insensitive)."},
					"include": {"type": "STRING", "description": "Optional file extension filter (e.g., '*.gd', '*.tscn'). Defaults to all text files."},
					"max_results": {"type": "INTEGER", "description": "Maximum number of results to return (default: 20, max: 50)."}
				},
				"required": ["query"]
			}
		},
		{
			"name": "view_file_outline",
			"description": "Shows the structure of a GDScript file without returning the full content: class_name, extends, functions, signals, exports, enums, inner classes, and constants with line numbers. Use this to understand a script's structure before editing it.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The resource path (res://...) to the script file."}
				},
				"required": ["path"]
			}
		},
		{
			"name": "save_memory",
			"description": "Saves a persistent project memory fact that will be available across all future chat sessions. Use this to remember important architectural decisions, code conventions, user preferences, bug fixes, and project info.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"category": {"type": "STRING", "enum": ["architecture", "convention", "preference", "bug_fix", "project_info"], "description": "The category of the memory fact."},
					"content": {"type": "STRING", "description": "A concise description of the fact to remember (e.g., 'Player uses StateMachine pattern with State nodes as children')."}
				},
				"required": ["category", "content"]
			}
		},
		{
			"name": "list_memories",
			"description": "Lists all persistent project memory facts stored for this project."
		},
		{
			"name": "delete_memory",
			"description": "Deletes a specific project memory fact by its ID.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"id": {"type": "STRING", "description": "The ID of the memory fact to delete (e.g., 'fact_1740500000')."}
				},
				"required": ["id"]
			}
		},
		{
			"name": "search_in_files",
			"description": "Searches for a regex pattern in all .gd files in the project to find usages of variables, functions, or specific logic. Returns path, line number, and match context (up to 20 results).",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"pattern": {"type": "STRING", "description": "The regular expression pattern to search for."}
				},
				"required": ["pattern"]
			}
		},
		{
			"name": "read_skill",
			"description": "Reads a specific skill documentation file from the AI's skills library. Use this to learn Godot 4 best practices, modern GDScript patterns, or how to implement specific features before you start coding.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"skill_name": {"type": "STRING", "description": "The exact name of the skill file to read (e.g. 'gdscript_style_guide.md', 'gdscript_signals_and_tweens.md')."}
				},
				"required": ["skill_name"]
			}
		},
		{
			"name": "capture_editor_screenshot",
			"description": "Takes a screenshot of the entire Godot Editor window and automatically attaches it to your next prompt so you can analyze the UI, layout, or scene visually."
		},
		{
			"name": "index_codebase",
			"description": "Indexes the entire Godot project (.gd files) into a local Vector Database for semantic search. Run this when you need deep codebase context. MUST NOT have any arguments."
		},
		{
			"name": "semantic_search",
			"description": "Performs a semantic vector search across the indexed codebase to find highly relevant code snippets based on meaning, rather than exact text matches. Run index_codebase first if the project is not indexed.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"query": {"type": "STRING", "description": "The concept or feature to search for (e.g. 'Player jumping logic')."}
				},
				"required": ["query"]
			}
		},
		{
			"name": "move_files_batch",
			"description": "Moves or renames multiple files/directories in a single batch operation. It safely updates all internal Godot resource dependencies (like .tscn and .tres references) to prevent corruption. Use this to reorganize project structures.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"moves": {
						"type": "OBJECT",
						"description": "A dictionary mapping old paths to new paths. e.g. {'res://old/file.gd': 'res://new/file.gd', 'res://old_dir/': 'res://new_dir/'}"
					}
				},
				"required": ["moves"]
			}
		},
		{
			"name": "analyze_node_children",
			"description": "Returns a detailed dump of a specific node's sub-tree in the current edited scene. Use this to explore deep hierarchies when the main context manager truncates the tree.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"node_path": {"type": "STRING", "description": "The path to the node to inspect (e.g., 'Player/Sprite' or '.')."},
					"max_depth": {"type": "INTEGER", "description": "Optional: How deep to recursively dump children (default 5)."}
				},
				"required": ["node_path"]
			}
		}
	]
	

func confirm_pending_action():
	if _pending_confirm_tool == "": return
	
	if _pending_confirm_tool == "remove_node":
		for h in _handlers:
			if h.has_method("_remove_node"): h._remove_node(_pending_confirm_args.get("node_path")); break
	elif _pending_confirm_tool == "remove_file":
		for h in _handlers:
			if h.has_method("_remove_file"): h._remove_file(_pending_confirm_args.get("path")); break
	elif _pending_confirm_tool == "create_script":
		for h in _handlers:
			if h.has_method("_apply_create_script"): h._apply_create_script(_pending_confirm_args.get("path"), _pending_confirm_args.get("content")); break
	elif _pending_confirm_tool == "edit_script":
		for h in _handlers:
			if h.has_method("_apply_edit_script"): h._apply_edit_script(_pending_confirm_args.get("path"), _pending_diff_old_content, _pending_confirm_args.get("content")); break
	elif _pending_confirm_tool == "patch_script":
		var path = _pending_confirm_args.get("path")
		var script_tools_h = null
		for h in _handlers:
			if h.has_method("_apply_patch_script"): script_tools_h = h
		if script_tools_h:
			var f = FileAccess.open(path, FileAccess.READ)
			if f:
				var old_full = f.get_as_text()
				f.close()
				var new_full = old_full.replace(_pending_confirm_args.get("search_content"), _pending_confirm_args.get("replace_content"))
				script_tools_h._apply_patch_script(path, old_full, new_full)
	elif _pending_confirm_tool == "replace_selection":
		for h in _handlers:
			if h.has_method("_apply_replace_selection"): h._apply_replace_selection(_pending_confirm_args.get("text")); break
	elif _pending_confirm_tool == "move_files_batch":
		for h in _handlers:
			if h.has_method("_move_files_batch"): h._move_files_batch(_pending_confirm_args.get("moves")); break
			
	_pending_confirm_tool = ""
	_pending_confirm_args = {}
	_pending_diff_path = ""
	_pending_diff_old_content = ""
	_pending_diff_new_content = ""

func execute_tool(tool_name: String, args: Dictionary):
	print("Executing tool: " + tool_name + " with args: " + str(args))
	
	var validation = _validate_args(tool_name, args)
	if not validation.valid:
		tool_output.emit("Error: " + validation.error)
		return
	
	var handled = false
	for h in _handlers:
		if h.execute(tool_name, args):
			handled = true
			break
			
	if not handled:
		tool_output.emit("Error: Unknown tool '" + tool_name + "'. Available tools: " + str(_TOOL_REQUIRED_ARGS.keys()))

func _create_scene_file(path: String, root_type: String, root_name: String):
	var dir_path = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var root = ClassDB.instantiate(root_type)
	if not root:
		tool_output.emit("Error: Invalid root type: " + root_type)
		return
		
	root.name = root_name
	
	var scene = PackedScene.new()
	var result = scene.pack(root)
	if result == OK:
		var err = ResourceSaver.save(scene, path)
		if err == OK:
			_scan_fs()
			EditorInterface.open_scene_from_path(path)
		else:
			tool_output.emit("Error: Could not save scene. Code: " + str(err))
	else:
		tool_output.emit("Error: Could not pack scene. Code: " + str(result))
		
	root.free()

