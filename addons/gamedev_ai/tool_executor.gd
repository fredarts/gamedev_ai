@tool
extends RefCounted

signal tool_output(output)

var _undo_redo: EditorUndoRedoManager
var _composite_action_name: String = ""

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
	# We will need to get the UndoRedo manager from the plugin or EditorInterface
	# But since this is RefCounted, we might need it passed in checks.
	pass

func setup(undo_redo: EditorUndoRedoManager):
	_undo_redo = undo_redo

func start_composite_action(name: String):
	if _undo_redo and _composite_action_name == "":
		_composite_action_name = name
		# Force history 0 (Global) by using self as context
		_undo_redo.create_action(name, UndoRedo.MERGE_DISABLE, self)

func commit_composite_action():
	if _undo_redo and _composite_action_name != "":
		_undo_redo.commit_action()
		_composite_action_name = ""

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
	# 1. Try to find if the script is already loaded in memory (open in editor or used by a node)
	var script = load(path) if FileAccess.file_exists(path) else null
	
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

	# 3. Always scan to ensure the filesystem is up to date
	_scan_fs()

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
		}
	]

func execute_tool(tool_name: String, args: Dictionary):
	tool_output.emit("[color=gray][i]Executing tool: " + tool_name + "...[/i][/color]")
	print("Executing tool: " + tool_name + " with args: " + str(args))
	
	# Validate arguments before executing
	var validation = _validate_args(tool_name, args)
	if not validation.valid:
		tool_output.emit("Error: " + validation.error)
		return
	
	match tool_name:
		"create_script":
			_create_script(args.get("path"), args.get("content"))
		"add_node":
			_add_node(args.get("parent_path"), args.get("type"), args.get("name"), args.get("script_path", ""))
		"attach_script":
			_attach_script(args.get("node_path"), args.get("script_path"))
		"create_scene":
			_create_scene(args.get("path"), args.get("root_type"), args.get("root_name"))
		"instance_scene":
			_instance_scene(args.get("parent_path"), args.get("scene_path"), args.get("name"))
		"edit_script":
			_edit_script(args.get("path"), args.get("content"))
		"remove_node":
			_remove_node(args.get("node_path"))
		"remove_file":
			_remove_file(args.get("path"))
		"set_property":
			_set_property(args.get("node_path"), args.get("property"), args.get("value"))
		"set_theme_override":
			_set_theme_override(args.get("node_path"), args.get("override_type"), args.get("name"), args.get("value"))
		"replace_selection":
			_replace_selection(args.get("text"))
		"list_dir":
			_list_dir(args.get("path"))
		"find_file":
			_find_file(args.get("pattern"))
		"read_file":
			_read_file(args.get("path"))
		"get_class_info":
			_get_class_info(args.get("class_name", ""))
		"patch_script":
			_patch_script(args.get("path"), args.get("search_content"), args.get("replace_content"))
		"connect_signal":
			_connect_signal(args.get("source_path"), args.get("signal_name"), args.get("target_path"), args.get("method_name"), args.get("binds", []), args.get("flags", 0))
		"disconnect_signal":
			_disconnect_signal(args.get("source_path"), args.get("signal_name"), args.get("target_path"), args.get("method_name"))
		"create_resource":
			_create_resource(args.get("path"), args.get("type"), args.get("properties", {}))
		"run_tests":
			_run_tests(args.get("test_script_path", ""))
		"grep_search":
			_grep_search(args.get("query"), args.get("include", ""), args.get("max_results", 20))
		"view_file_outline":
			_view_file_outline(args.get("path"))
		_:
			tool_output.emit("Error: Unknown tool '" + tool_name + "'. Available tools: " + str(_TOOL_REQUIRED_ARGS.keys()))

func _create_script(path: String, content: String):
	# Security check
	if not path.begins_with("res://"):
		tool_output.emit("Error: Path must start with res://")
		return

	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Create Script " + path.get_file(), UndoRedo.MERGE_DISABLE, self)

		_undo_redo.add_do_method(self, "_create_file_undoable", path, content)
		_undo_redo.add_undo_method(self, "_delete_file_undoable", path)
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			var msg = "Success: Script created at " + path
			var validation = _validate_script(path)
			if validation != "":
				msg += " | " + validation
			tool_output.emit(msg)
		else:
			tool_output.emit("Success: Script creation queued for " + path)
	else:
		# Fallback
		_create_file_undoable(path, content)
		var msg = "Success: Script created at " + path + " (No Undo)"
		var validation = _validate_script(path)
		if validation != "":
			msg += " | " + validation
		tool_output.emit(msg)

func _create_scene(path: String, root_type: String, root_name: String):
	if not path.begins_with("res://") or not path.ends_with(".tscn"):
		tool_output.emit("Error: Path must start with res:// and end with .tscn")
		return
		
	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Create Scene " + path.get_file(), UndoRedo.MERGE_DISABLE, self)
			
		_undo_redo.add_do_method(self, "_create_scene_file", path, root_type, root_name)
		_undo_redo.add_undo_method(self, "_delete_file_undoable", path)
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			tool_output.emit("Success: Scene " + path + " created (queued for creation).")
		else:
			tool_output.emit("Success: Scene creation queued for " + path)
	else:
		_create_scene_file(path, root_type, root_name)
		tool_output.emit("Success: Scene " + path + " created (No Undo).")

func _create_scene_file(path: String, root_type: String, root_name: String):
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
			
			# If this scene is already open, reload it to reflect changes without popup
			var edited_root = EditorInterface.get_edited_scene_root()
			if edited_root and edited_root.scene_file_path == path:
				# Re-opening the same path usually refreshes the editor view
				EditorInterface.open_scene_from_path(path)
		else:
			tool_output.emit("Error: Could not save scene. Code: " + str(err))
	else:
		tool_output.emit("Error: Could not pack scene. Code: " + str(result))
		
	root.free() # Clean up the temporary node

func _instance_scene(parent_path: String, scene_path: String, name: String):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
		
	var parent = root.get_node(parent_path) if parent_path != "." else root
	if not parent:
		tool_output.emit("Error: Parent node not found: " + parent_path)
		return
		
	if not FileAccess.file_exists(scene_path):
		tool_output.emit("Error: Scene file not found: " + scene_path)
		return
		
	var scene = load(scene_path)
	if not scene or not scene is PackedScene:
		tool_output.emit("Error: Failed to load scene or invalid scene format: " + scene_path)
		return
		
	if _undo_redo:
		var instance = scene.instantiate()
		instance.name = name
		
		if _composite_action_name == "":
			_undo_redo.create_action("Instance Scene " + name, UndoRedo.MERGE_DISABLE, self)
		
		_undo_redo.add_do_method(self, "_proxy_add_child", parent, instance)
		_undo_redo.add_do_method(self, "_proxy_set_property", instance, "owner", root)
		_undo_redo.add_do_reference(instance)
		_undo_redo.add_undo_method(self, "_proxy_remove_child", parent, instance)
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			_save_scene()
			tool_output.emit("Success: Scene " + scene_path + " instanced as " + name + " under " + parent.name)
		else:
			tool_output.emit("Success: Scene instance queued: " + name)
	else:
		var instance = scene.instantiate()
		instance.name = name
		parent.add_child(instance)
		instance.owner = root
		_save_scene()
		tool_output.emit("Success: Scene " + scene_path + " instanced as " + name + " under " + parent.name + " (No Undo)")

func _add_node(parent_path: String, type: String, name: String, script_path: String = ""):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
		
	var parent = root.get_node(parent_path) if parent_path != "." else root
	if not parent:
		tool_output.emit("Error: Parent node not found: " + parent_path)
		return

	# Use UndoRedo for node creation
	if _undo_redo:
		var node = ClassDB.instantiate(type)
		if not node:
			var suggestion = _suggest_class_name(type)
			var msg = "Error: Invalid node type '" + type + "'."
			if suggestion != "":
				msg += " Did you mean '" + suggestion + "'?"
			msg += " Use get_class_info to check available classes."
			tool_output.emit(msg)
			return
			 
		node.name = name
		
		# Load script if provided
		var script = null
		if script_path != "":
			if FileAccess.file_exists(script_path):
				script = load(script_path)
			else:
				tool_output.emit("Warning: Script not found at " + script_path)
		
		if _composite_action_name == "":
			_undo_redo.create_action("Add Node " + name, UndoRedo.MERGE_DISABLE, self)
			
		_undo_redo.add_do_method(self, "_proxy_add_child", parent, node)
		_undo_redo.add_do_method(self, "_proxy_set_property", node, "owner", root) # Important for persistence
		if script:
			_undo_redo.add_do_method(self, "_proxy_set_script", node, script)
		_undo_redo.add_do_reference(node) # Keep reference so it's not freed immediately
		_undo_redo.add_undo_method(self, "_proxy_remove_child", parent, node)
		
		var msg = "Success: Node " + name + " (" + type + ") added to " + parent.name
		if script:
			msg += " with script " + script_path
			
		if _composite_action_name == "":
			_undo_redo.commit_action()
			_save_scene()
			tool_output.emit(msg)
		else:
			tool_output.emit(msg + " (Queued)")
	else:
		tool_output.emit("Error: UndoRedoManager not available.")

func _attach_script(node_path: String, script_path: String):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
	
	var node = root.get_node(node_path)
	if not node:
		tool_output.emit("Error: Node not found: " + node_path)
		return
		
	if not FileAccess.file_exists(script_path):
		tool_output.emit("Error: Script file not found: " + script_path)
		return
		
	var script = load(script_path)
	if not script:
		tool_output.emit("Error: Failed to load script: " + script_path)
		return
		
	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Attach Script to " + node.name, UndoRedo.MERGE_DISABLE, self)
		
		_undo_redo.add_do_method(self, "_proxy_set_script", node, script)
		_undo_redo.add_undo_method(self, "_proxy_set_script", node, null) # Ideally we'd restore previous script
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			tool_output.emit("Success: Attached " + script_path + " to " + node_path)
		else:
			tool_output.emit("Success: Attach script queued for " + node_path)
	else:
		node.set_script(script)
		tool_output.emit("Success: Attached " + script_path + " to " + node_path + " (No Undo)")

func _edit_script(path: String, new_content: String):
	if not FileAccess.file_exists(path):
		tool_output.emit("Error: File not found at " + path + ". Use find_file('" + path.get_file().get_basename() + "') to locate it, or create_script to create a new file.")
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	var old_content = file.get_as_text()
	file.close()

	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Edit Script " + path.get_file(), UndoRedo.MERGE_DISABLE, self)

		_undo_redo.add_do_method(self, "_create_file_undoable", path, new_content)
		_undo_redo.add_undo_method(self, "_create_file_undoable", path, old_content)
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			var msg = "Success: Script edited at " + path
			var validation = _validate_script(path)
			if validation != "":
				msg += " | " + validation
			msg += " | [color=yellow]Warning: edit_script is deprecated. Please prefer patch_script.[/color]"
			tool_output.emit(msg)
		else:
			tool_output.emit("Success: Script edit queued for " + path)
	else:
		_create_file_undoable(path, new_content)
		var msg = "Success: Script edited at " + path + " (No Undo)"
		var validation = _validate_script(path)
		if validation != "":
			msg += " | " + validation
		msg += " | [color=yellow]Warning: edit_script is deprecated. Please prefer patch_script.[/color]"
		tool_output.emit(msg)

func _remove_node(node_path: String):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
		
	var node = root.get_node(node_path)
	if not node:
		tool_output.emit("Error: Node not found at path: '" + node_path + "'. Current scene tree: " + _get_scene_tree_brief(root))
		return
		
	if node == root:
		tool_output.emit("Error: Cannot remove the scene root node via this tool.")
		return
		
	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Remove Node " + node.name, UndoRedo.MERGE_DISABLE, self)
			
		_undo_redo.add_do_method(self, "_proxy_remove_child", node.get_parent(), node)
		_undo_redo.add_undo_method(self, "_proxy_add_child", node.get_parent(), node)
		_undo_redo.add_undo_method(self, "_proxy_set_property", node, "owner", root)
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			_save_scene()
			tool_output.emit("Success: Node " + node_path + " removed.")
		else:
			tool_output.emit("Success: Node removal queued: " + node_path)
	else:
		node.get_parent().remove_child(node)
		node.queue_free()
		_save_scene()
		tool_output.emit("Success: Node " + node_path + " removed (No Undo).")

func _remove_file(path: String):
	if not path.begins_with("res://"):
		tool_output.emit("Error: Path must start with res://")
		return
		
	if path == "res://" or path == "res://addons/":
		tool_output.emit("Error: Safety block - Cannot delete project root or addons folder.")
		return
		
	if DirAccess.dir_exists_absolute(path):
		var err = DirAccess.remove_absolute(path)
		if err == OK:
			EditorInterface.get_resource_filesystem().scan()
			tool_output.emit("Success: Directory " + path + " deleted.")
		else:
			tool_output.emit("Error: Could not delete directory. Code: " + str(err))
	elif FileAccess.file_exists(path):
		var err = DirAccess.remove_absolute(path) # DirAccess removes files too in Godot 4
		if err == OK:
			EditorInterface.get_resource_filesystem().scan()
			tool_output.emit("Success: File " + path + " deleted.")
		else:
			tool_output.emit("Error: Could not delete file. Code: " + str(err))
	else:
		tool_output.emit("Error: Path not found: " + path)

func _set_property(node_path: String, property: String, value: Variant):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
		
	var node = root.get_node(node_path) if node_path != "." else root
	if not node:
		tool_output.emit("Error: Node not found: '" + node_path + "'. Current scene tree: " + _get_scene_tree_brief(root))
		return
		
	# Get expected type from the property to disambiguate arrays
	var expected_type := _get_property_type(node, property)
	var final_value = _parse_value(value, expected_type)
	
	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Set Property " + property + " on " + node.name, UndoRedo.MERGE_DISABLE, self)
			
		_undo_redo.add_do_method(self, "_proxy_set_property", node, property, final_value)
		_undo_redo.add_undo_method(self, "_proxy_set_property", node, property, node.get(property))
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			_save_scene()
			tool_output.emit("Success: Set " + property + " to " + str(final_value) + " on " + node_path)
		else:
			tool_output.emit("Success: Set property queued: " + property + " on " + node_path)
	else:
		node.set(property, final_value)
		_save_scene()
		tool_output.emit("Success: Set " + property + " to " + str(final_value) + " on " + node_path + " (No Undo)")

func _set_theme_override(node_path: String, override_type: String, name: String, value: Variant):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
		
	var node = root.get_node(node_path) if node_path != "." else root
	if not node or not node is Control:
		tool_output.emit("Error: Node not found or not a Control node: " + node_path)
		return

	var final_value = _parse_value(value)
	
	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Set Theme Override " + name + " on " + node.name, UndoRedo.MERGE_DISABLE, self)
			
		match override_type:
			"color": _undo_redo.add_do_method(self, "_proxy_call", node, "add_theme_color_override", name, final_value)
			"constant": _undo_redo.add_do_method(self, "_proxy_call", node, "add_theme_constant_override", name, int(final_value))
			"font_size": _undo_redo.add_do_method(self, "_proxy_call", node, "add_theme_font_size_override", name, int(final_value))
			"font": _undo_redo.add_do_method(self, "_proxy_call", node, "add_theme_font_override", name, final_value)
			"stylebox": _undo_redo.add_do_method(self, "_proxy_call", node, "add_theme_stylebox_override", name, final_value)
		# Undo is tricky for overrides as there's no clear "remove_theme_override" that's undoable easily without complex state
		# For now we'll just commit.
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			_save_scene()
			tool_output.emit("Success: Set theme override " + name + " on " + node_path)
		else:
			tool_output.emit("Success: Set theme override queued: " + name)
	else:
		match override_type:
			"color": node.add_theme_color_override(name, final_value)
			"constant": node.add_theme_constant_override(name, int(final_value))
			"font_size": node.add_theme_font_size_override(name, int(final_value))
			"font": node.add_theme_font_override(name, final_value)
			"stylebox": node.add_theme_stylebox_override(name, final_value)
		_save_scene()
		tool_output.emit("Success: Set theme override " + name + " on " + node_path)

func _get_property_type(node: Object, property: String) -> int:
	# Returns the Variant.Type for a node's property, or -1 if unknown
	var props = node.get_property_list()
	for p in props:
		if p.name == property:
			return p.type
	return -1

func _parse_value(value: Variant, expected_type: int = -1) -> Variant:
	if value is Array:
		if value.size() == 2:
			return Vector2(value[0], value[1])
		if value.size() == 3:
			# Disambiguate Vector3 vs Color using expected type
			if expected_type == TYPE_COLOR:
				return Color(value[0], value[1], value[2])
			if expected_type == TYPE_VECTOR3:
				return Vector3(value[0], value[1], value[2])
			# Default: Vector3 (more common in game dev than RGB without alpha)
			return Vector3(value[0], value[1], value[2])
		if value.size() == 4:
			# Disambiguate Color vs Quaternion/Vector4 using expected type
			if expected_type == TYPE_QUATERNION:
				return Quaternion(value[0], value[1], value[2], value[3])
			if expected_type == TYPE_VECTOR4:
				return Vector4(value[0], value[1], value[2], value[3])
			# Default: Color (most common 4-element type)
			return Color(value[0], value[1], value[2], value[3])
	return value

func _replace_selection(text: String):
	var script_editor = EditorInterface.get_script_editor()
	var current_editor = script_editor.get_current_editor()
	if not current_editor:
		tool_output.emit("Error: No script editor open.")
		return
		
	var code_edit = current_editor.get_base_editor()
	if not code_edit or not code_edit is CodeEdit:
		tool_output.emit("Error: Could not find CodeEdit in current editor.")
		return
		
	if not code_edit.has_selection():
		tool_output.emit("Error: No text selected in the editor.")
		return
		
	# In Godot 4, we should use UndoRedo for editor changes if possible
	# But EditorInterface doesn't give direct access to ScriptEditor's UndoRedo easily in some versions.
	# However, CodeEdit.insert_text_at_cursor handles its own internal undo stack.
	
	code_edit.begin_complex_operation()
	code_edit.insert_text_at_cursor(text)
	code_edit.end_complex_operation()
	
	tool_output.emit("Success: Selected text replaced.")

func _list_dir(path: String):
	if not path.begins_with("res://"):
		tool_output.emit("Error: Path must start with res://")
		return
		
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var files = []
		while file_name != "":
			if dir.current_is_dir():
				files.append(file_name + "/")
			else:
				files.append(file_name)
			file_name = dir.get_next()
		
		tool_output.emit("Directory contents of " + path + ":\n" + str(files))
	else:
		tool_output.emit("Error: Could not open directory " + path)

func _read_file(path: String):
	if not path.begins_with("res://"):
		tool_output.emit("Error: Path must start with res://")
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		tool_output.emit("Content of " + path + ":\n" + content)
	else:
		var err = FileAccess.get_open_error()
		tool_output.emit("Error: Could not open file " + path + ". Code: " + str(err))

func _find_file(pattern: String):
	var contents = _recursive_find("res://", pattern)
	if contents.is_empty():
		tool_output.emit("No files found matching '" + pattern + "'")
	else:
		tool_output.emit("Found files:\n" + str(contents))

func _recursive_find(path: String, pattern: String) -> Array:
	var results = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					results.append_array(_recursive_find(path + file_name + "/", pattern))
			else:
				if pattern in file_name:
					results.append(path + file_name)
			file_name = dir.get_next()
	return results

func _proxy_connect(source: Node, signal_name: String, callable: Callable, flags: int = 0):
	if is_instance_valid(source) and not source.is_connected(signal_name, callable):
		source.connect(signal_name, callable, flags)

func _proxy_disconnect(source: Node, signal_name: String, callable: Callable):
	if is_instance_valid(source) and source.is_connected(signal_name, callable):
		source.disconnect(signal_name, callable)

func _patch_script(path: String, search_content: String, replace_content: String):
	if not FileAccess.file_exists(path):
		tool_output.emit("Error: File not found at " + path + ". Use find_file('" + path.get_file().get_basename() + "') to locate it.")
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	if content.find(search_content) == -1:
		tool_output.emit("Error: Search block not found in " + path.get_file() + ". The search must be an EXACT match including whitespace and indentation. Use read_file first to get the exact current content.")
		return
		
	if content.count(search_content) > 1:
		tool_output.emit("Error: Search block matches multiple locations in " + path.get_file() + ". Provide more context to make it unique.")
		return
		
	var new_content = content.replace(search_content, replace_content)
	
	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Patch Script " + path.get_file(), UndoRedo.MERGE_DISABLE, self)

		_undo_redo.add_do_method(self, "_create_file_undoable", path, new_content)
		_undo_redo.add_undo_method(self, "_create_file_undoable", path, content)
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			var msg = "Success: Patched " + path.get_file()
			var validation = _validate_script(path)
			if validation != "":
				msg += " | " + validation
			tool_output.emit(msg)
		else:
			tool_output.emit("Success: Patch queued for " + path)
	else:
		_create_file_undoable(path, new_content)
		var msg = "Success: Patched " + path.get_file() + " (No Undo)"
		var validation = _validate_script(path)
		if validation != "":
			msg += " | " + validation
		tool_output.emit(msg)

func _connect_signal(source_path: String, signal_name: String, target_path: String, method_name: String, binds: Array = [], flags: int = 0):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
		
	var source = root.get_node(source_path)
	var target = root.get_node(target_path)
	
	if not source:
		tool_output.emit("Error: Source node not found: " + source_path)
		return
	if not target:
		tool_output.emit("Error: Target node not found: " + target_path)
		return
		
	# In Godot, persistent connections (saved to .tscn) are done via add_user_signal? No, that's for custom signals.
	# Standard connections are just node.connect(), but to SAVE them, we must use the editor's system if possible?
	# Actually, simply calling connect() on a tool script might just work for runtime, but for Editor persistence (saving to .tscn),
	# we usually modify the "dependencies" or use UndoRedo on the scene.
	# But wait, `node.connect` with `CONNECT_PERSIST` flag exists? No.
	# The correct way to persist a connection in a scene is using `add_connection` on the scene state, OR
	# just `source.connect()` and set `owner` correctly? No.
	# 
	# Correct way for Editor Plugins:
	# UndoRedo operations on the generic "connect" method usually persist if the scene is saved.
	
	var callable = Callable(target, method_name)
	if not callable:
		tool_output.emit("Error: Invalid callable " + method_name + " on " + target.name)
		return

	if source.is_connected(signal_name, callable):
		tool_output.emit("Warning: Signal already connected.")
		return

	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Connect Signal " + signal_name, UndoRedo.MERGE_DISABLE, self)
			
		_undo_redo.add_do_method(self, "_proxy_connect", source, signal_name, callable, flags)
		_undo_redo.add_undo_method(self, "_proxy_disconnect", source, signal_name, callable)
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			_save_scene()
			tool_output.emit("Success: Connected " + signal_name + " to " + method_name)
		else:
			tool_output.emit("Success: Connection queued.")
	else:
		source.connect(signal_name, callable, flags)
		_save_scene()
		tool_output.emit("Success: Connected " + signal_name + " (No Undo)")

func _disconnect_signal(source_path: String, signal_name: String, target_path: String, method_name: String):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
		
	var source = root.get_node(source_path)
	var target = root.get_node(target_path)
	
	if not source or not target:
		tool_output.emit("Error: Node not found.")
		return
		
	var callable = Callable(target, method_name)
	if not source.is_connected(signal_name, callable):
		tool_output.emit("Error: Connection not found.")
		return

	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Disconnect Signal " + signal_name, UndoRedo.MERGE_DISABLE, self)
			
		_undo_redo.add_do_method(self, "_proxy_disconnect", source, signal_name, callable)
		# Undo involves reconnecting. We'd need to know flags/binds. Simplified for now (no binds restored perfectly without checking).
		_undo_redo.add_undo_method(self, "_proxy_connect", source, signal_name, callable) 
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			_save_scene()
			tool_output.emit("Success: Disconnected " + signal_name)
		else:
			tool_output.emit("Success: Disconnection queued.")
	else:
		source.disconnect(signal_name, callable)
		_save_scene()
		tool_output.emit("Success: Disconnected " + signal_name + " (No Undo)")

func _create_resource(path: String, type: String, properties: Dictionary = {}):
	if not path.begins_with("res://") or not path.ends_with(".tres"):
		tool_output.emit("Error: Path must specify a .tres file.")
		return
		
	if FileAccess.file_exists(path):
		tool_output.emit("Error: File already exists at " + path)
		return
		
	if not ClassDB.class_exists(type) and not _scan_fs_for_custom_class(type):
		tool_output.emit("Error: Class type " + type + " not found.")
		return

	# Helper to instantiate
	var res = null
	if ClassDB.class_exists(type):
		res = ClassDB.instantiate(type)
	else:
		# Custom class loading... 
		# This is complex without a full class loader, but let's try strict types first.
		# If user passes a script path as type? No, type name.
		# We'll assume if it's not engine class, we search for a script with that class_name?
		# For now, let's Stick to Engine classes or Resources with scripts attached later.
		# Actually, Resource.new() + set_script is the way for custom resources.
		res = Resource.new()
		# This part is partial. Ideally we look up the script from class_name map (Project Index).
	
	if not res:
		tool_output.emit("Error: Could not instantiate " + type)
		return
		
	# Set properties
	for key in properties:
		res.set(key, _parse_value(properties[key]))
		
	var err = ResourceSaver.save(res, path)
	if err == OK:
		EditorInterface.get_resource_filesystem().scan()
		tool_output.emit("Success: Resource created at " + path)
	else:
		tool_output.emit("Error: Failed to save resource. Code: " + str(err))

func _scan_fs_for_custom_class(type: String) -> bool:
	# Placeholder. The Project Index logic in context_manager is better suited for this.
	# For now, we rely on Godot's internal cache if possible, or just fail for custom classes 
	# unless "type" is a script path.
	return false

func _run_tests(test_script_path: String):
	# This implementation tries to run Godot in command line mode to execute a script
	var exe_path = OS.get_executable_path()
	var args = []
	
	if test_script_path != "":
		if not test_script_path.begins_with("res://"):
			tool_output.emit("Error: Test script path must start with res://")
			return
		args.append("-s")
		args.append(test_script_path)
	else:
		if FileAccess.file_exists("res://addons/gut/gut_cmdln.gd"):
			args.append("-s")
			args.append("res://addons/gut/gut_cmdln.gd")
		elif FileAccess.file_exists("res://addons/gdUnit4/runtest.gd"):
			args.append("-s")
			args.append("res://addons/gdUnit4/runtest.gd")
		else:
			tool_output.emit("Error: No test script provided and no known test runner found (GUT/GdUnit4).")
			return
			
	args.append("--headless")
	
	tool_output.emit("Running tests with command: " + exe_path + " " + str(args))
	
	var output = []
	var exit_code = OS.execute(exe_path, args, output, true)
	
	var result_str = "Test Run Complete (Exit Code " + str(exit_code) + "):\n"
	if not output.is_empty():
		result_str += output[0]
	else:
		result_str += "(No output captured)"
		
	tool_output.emit(result_str)

func _get_class_info(cls_name: String):
	if not ClassDB.class_exists(cls_name):
		tool_output.emit("Error: Class '" + cls_name + "' not found in ClassDB.")
		return
		
	var info = "Class: " + cls_name + "\n"
	info += "Inherits: " + ClassDB.get_parent_class(cls_name) + "\n"
	
	var properties = ClassDB.class_get_property_list(cls_name, true)
	info += "\nProperties:\n"
	for p in properties:
		if p.usage & PROPERTY_USAGE_EDITOR:
			info += "- " + p.name + " (Type: " + str(p.type) + ")\n"
			
	var methods = ClassDB.class_get_method_list(cls_name, true)
	info += "\nMethods:\n"
	for m in methods:
		if not m.name.begins_with("_"):
			info += "- " + m.name + "(" + str(m.args.size()) + " args)\n"
			
	var signals_list = ClassDB.class_get_signal_list(cls_name, true)
	info += "\nSignals:\n"
	for s in signals_list:
		info += "- " + s.name + "\n"
		
	tool_output.emit(info)

# ============================================================
# Phase 2: New Tools & Helpers
# ============================================================

func _grep_search(query: String, include: String = "", max_results: int = 20):
	max_results = clampi(max_results, 1, 50)
	var results: Array = []
	var extensions: Array = []
	
	# Parse include filter
	if include != "":
		# Support formats: "*.gd", ".gd", "gd"
		var ext = include.replace("*", "").replace(".", "")
		extensions.append(ext)
	else:
		extensions = ["gd", "tscn", "tres", "cfg", "json", "txt", "md", "shader", "gdshader"]
	
	_grep_recursive("res://", query.to_lower(), extensions, results, max_results)
	
	if results.is_empty():
		tool_output.emit("No matches found for '" + query + "'" + (" in *." + extensions[0] if extensions.size() == 1 else "") + ".")
		return
	
	var output = "Found " + str(results.size()) + " match(es) for '" + query + "':\n\n"
	for r in results:
		output += r.path + ":" + str(r.line) + ": " + r.content.strip_edges() + "\n"
	
	if results.size() >= max_results:
		output += "\n(Results capped at " + str(max_results) + ". Narrow your query or use 'include' filter.)"
	
	tool_output.emit(output)

func _grep_recursive(dir_path: String, query_lower: String, extensions: Array, results: Array, max_results: int):
	if results.size() >= max_results:
		return
	
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "" and results.size() < max_results:
		if file_name.begins_with(".") or file_name == "addons" and dir_path == "res://":
			# Skip hidden files; skip addons at root level (except our own plugin)
			# Actually, let's include addons since user may want to search there
			pass
		
		var full_path = dir_path + file_name
		if dir.current_is_dir():
			_grep_recursive(full_path + "/", query_lower, extensions, results, max_results)
		else:
			var ext = file_name.get_extension()
			if ext in extensions:
				_grep_file(full_path, query_lower, results, max_results)
		
		file_name = dir.get_next()

func _grep_file(file_path: String, query_lower: String, results: Array, max_results: int):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return
	
	var line_num = 0
	while not file.eof_reached() and results.size() < max_results:
		line_num += 1
		var line = file.get_line()
		if line.to_lower().find(query_lower) != -1:
			results.append({
				"path": file_path,
				"line": line_num,
				"content": line
			})

func _view_file_outline(path: String):
	if not FileAccess.file_exists(path):
		tool_output.emit("Error: File not found at " + path + ". Use find_file('" + path.get_file().get_basename() + "') to locate it.")
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		tool_output.emit("Error: Cannot open file at " + path)
		return
	
	var outline = "Outline of " + path.get_file() + ":\n\n"
	var line_num = 0
	var current_class = ""
	
	while not file.eof_reached():
		line_num += 1
		var line = file.get_line()
		var stripped = line.strip_edges()
		
		# Skip empty lines and comments
		if stripped == "" or stripped.begins_with("#"):
			continue
		
		# class_name
		if stripped.begins_with("class_name "):
			outline += "L" + str(line_num) + " | class_name " + stripped.substr(11).strip_edges() + "\n"
		# extends
		elif stripped.begins_with("extends "):
			outline += "L" + str(line_num) + " | extends " + stripped.substr(8).strip_edges() + "\n"
		# Inner class
		elif stripped.begins_with("class "):
			var cls = stripped.split(":")[0].strip_edges()
			current_class = cls.substr(6).strip_edges()
			outline += "L" + str(line_num) + " | " + cls + "\n"
		# Enum
		elif stripped.begins_with("enum "):
			outline += "L" + str(line_num) + " | " + stripped.split("{")[0].strip_edges() + "\n"
		# Signal
		elif stripped.begins_with("signal "):
			outline += "L" + str(line_num) + " | " + stripped + "\n"
		# @export var
		elif stripped.begins_with("@export"):
			# Read next line if this is just the annotation
			if "var " in stripped:
				var var_part = stripped.substr(stripped.find("var "))
				outline += "L" + str(line_num) + " | @export " + var_part.split("=")[0].strip_edges() + "\n"
			else:
				outline += "L" + str(line_num) + " | " + stripped + "\n"
		# Functions
		elif stripped.begins_with("func ") or stripped.begins_with("static func "):
			var func_sig = stripped.split(":")[0].strip_edges()
			if func_sig.ends_with(")"):
				outline += "L" + str(line_num) + " | " + func_sig + "\n"
			else:
				# Include return type
				outline += "L" + str(line_num) + " | " + stripped.split(":")[0].strip_edges()
				if ":" in stripped and "->" in stripped:
					outline += " -> " + stripped.split("->")[1].split(":")[0].strip_edges()
				outline += "\n"
		# Constants
		elif stripped.begins_with("const "):
			var const_part = stripped.split("=")[0].strip_edges()
			outline += "L" + str(line_num) + " | " + const_part + "\n"
		# Top-level var (not indented)
		elif stripped.begins_with("var ") and not line.begins_with("\t"):
			var var_part = stripped.split("=")[0].strip_edges()
			outline += "L" + str(line_num) + " | " + var_part + "\n"
	
	if outline.ends_with(":\n\n"):
		outline += "(empty file)\n"
	
	outline += "\nTotal lines: " + str(line_num)
	tool_output.emit(outline)

func _validate_script(path: String) -> String:
	# Only validate .gd files
	if not path.ends_with(".gd"):
		return ""
	
	# Try to load the script and check for errors
	var script = load(path)
	if script == null:
		return "⚠️ Validation: Failed to load script. It may contain syntax errors."
	
	if script is GDScript:
		var err = script.reload()
		if err != OK:
			return "⚠️ Validation: Script has errors (reload error code: " + str(err) + "). Check for syntax issues."
	
	return ""  # No errors

func _suggest_class_name(invalid_name: String) -> String:
	# Find the closest matching class name in ClassDB
	var all_classes = ClassDB.get_class_list()
	var best_match = ""
	var best_score = 0
	var invalid_lower = invalid_name.to_lower()
	
	for cls in all_classes:
		var cls_lower = cls.to_lower()
		
		# Exact substring match (strongest signal)
		if cls_lower.contains(invalid_lower) or invalid_lower.contains(cls_lower):
			if best_match == "" or abs(cls.length() - invalid_name.length()) < abs(best_match.length() - invalid_name.length()):
				best_match = cls
				best_score = 100
		
		# Simple similarity: count matching characters in order
		elif best_score < 50:
			var score = 0
			var j = 0
			for i in range(cls_lower.length()):
				if j < invalid_lower.length() and cls_lower[i] == invalid_lower[j]:
					score += 1
					j += 1
			
			# Require at least 60% character match
			var threshold = invalid_lower.length() * 0.6
			if score > threshold and score > best_score:
				best_score = score
				best_match = cls
	
	return best_match

func _get_scene_tree_brief(root: Node) -> String:
	# Return a compact, one-line-ish scene tree for error messages
	var result = root.name + "(" + root.get_class() + ")"
	var children = root.get_children()
	if children.is_empty():
		return result
	
	result += " > ["
	var names: Array = []
	for child in children:
		names.append(child.name)
		if names.size() >= 10:
			names.append("... +" + str(children.size() - 10) + " more")
			break
	result += ", ".join(names) + "]"
	return result

func _save_scene():
	var current_scene = EditorInterface.get_edited_scene_root()
	if not current_scene or current_scene.scene_file_path.is_empty():
		return
	
	var err = EditorInterface.save_scene()
	if err != OK:
		print("GamedevAI: Auto-save failed with code " + str(err))
