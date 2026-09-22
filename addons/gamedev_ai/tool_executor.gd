@tool
extends RefCounted

signal tool_output(output)
signal confirmation_needed(message: String, tool_name: String, args: Dictionary)
signal diff_preview_requested(path: String, old_content: String, new_content: String, tool_name: String, args: Dictionary)
signal image_captured(image_path: String)

var _undo_redo: EditorUndoRedoManager
var memory_manager
var debugger_plugin: RefCounted
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
	"analyze_node_children": ["node_path"],
	"audit_scene": [],
	"audit_script": ["path"],
	"get_lsp_diagnostics": ["path"],
	"generate_sfx": ["preset"],
	"play_sfx_preview": ["preset"],
	"generate_shader": ["preset"],
	"apply_shader_to_node": [],
	"get_shader_presets_list": [],
	"configure_tileset_atlas": ["texture_path"],
	"build_tilemap_layout": ["layout_matrix"],
	"paint_terrain_cells": ["terrain_set", "terrain_id", "cell_coordinates"],
	"read_tilemap_layout": [],
	"clear_tilemap_region": [],
	"create_animation": ["player_node_path", "animation_name"],
	"setup_spritesheet_animation": ["player_node_path", "animation_name", "start_frame", "frame_count"],
	"add_animation_event_track": ["player_node_path", "animation_name", "timestamp"],
	"inspect_animation_player": ["player_node_path"],
	"create_state_machine": ["tree_node_path", "states"],
	"create_blend_space_2d": ["tree_node_path", "state_name", "blend_points"],
	"connect_state_machine_transition": ["tree_node_path", "from_state", "to_state"],
	"inspect_animation_tree": ["tree_node_path"],
	"setup_character_animation_suite": ["parent_path", "sprite_node_path"],
	"generate_ui_theme": ["preset_or_name"],
	"create_responsive_ui_component": ["component_type"],
	"apply_theme_to_scene": ["theme_path"],
	"inspect_theme": [],
	"omni_eval": ["code"],
	"omni_manage": ["action"],
	"get_runtime_errors": [],
	"get_runtime_status": [],
	"generate_procedural_dungeon": [],
	"scaffold_autotile_bitmasks": ["tileset_path"],
	"get_atlas_image": []
}

var test_runner: RefCounted
var lsp_client: RefCounted

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
		if tool_name in ["create_script", "edit_script", "read_file", "patch_script", "remove_file", "list_dir", "create_resource", "get_lsp_diagnostics"]:
			if not path.begins_with("res://"):
				return {"valid": false, "error": "Parameter 'path' must start with 'res://'. Got: '" + path + "'"}
				
		var allowed_text_exts = [".gd", ".gdshader", ".md", ".txt", ".json", ".cfg", ".xml", ".csv"]
		if tool_name in ["create_script", "edit_script", "patch_script"]:
			var has_valid_ext = false
			for ext in allowed_text_exts:
				if path.ends_with(ext):
					has_valid_ext = true
					break
			if not has_valid_ext:
				return {"valid": false, "error": "Tool '" + tool_name + "' can only be used on text-based files (" + str(allowed_text_exts) + "). Got: '" + path + "'. To modify scenes, use add_node/set_property. To modify resources, use create_resource."}
		
		if tool_name == "create_scene" and (not path.begins_with("res://") or not path.ends_with(".tscn")):
			return {"valid": false, "error": "Parameter 'path' must start with 'res://' and end with '.tscn'. Got: '" + path + "'"}
		
		if tool_name == "create_resource" and not path.ends_with(".tres"):
			return {"valid": false, "error": "Parameter 'path' must end with '.tres'. Got: '" + path + "'"}
	
	return {"valid": true, "error": ""}

func _init():
	pass

func setup(undo_redo: EditorUndoRedoManager):
	_undo_redo = undo_redo
	
	# Initialize LSP Client
	var LSPClientScript = load("res://addons/gamedev_ai/lsp_client.gd")
	if LSPClientScript:
		lsp_client = LSPClientScript.new()
		lsp_client.connect_to_lsp()
	
	# Initialize Test Runner
	var TestRunnerScript = load("res://addons/gamedev_ai/test_runner.gd")
	if TestRunnerScript:
		test_runner = TestRunnerScript.new()
	
	_handlers.clear()
	var ScriptToolsScript = load("res://addons/gamedev_ai/tools/script_tools.gd")
	var NodeToolsScript = load("res://addons/gamedev_ai/tools/node_tools.gd")
	var FileToolsScript = load("res://addons/gamedev_ai/tools/file_tools.gd")
	var ProjectToolsScript = load("res://addons/gamedev_ai/tools/project_tools.gd")
	var MemoryToolsScript = load("res://addons/gamedev_ai/tools/memory_tools.gd")
	var DBToolsScript = load("res://addons/gamedev_ai/tools/db_tools.gd")
	var AuditToolsScript = load("res://addons/gamedev_ai/tools/audit_tools.gd")
	var AudioToolsScript = load("res://addons/gamedev_ai/tools/audio_tools.gd")
	var ShaderToolsScript = load("res://addons/gamedev_ai/tools/shader_tools.gd")
	var TileMapToolsScript = load("res://addons/gamedev_ai/tools/tilemap_tools.gd")
	var AnimationToolsScript = load("res://addons/gamedev_ai/tools/animation_tools.gd")
	var UIThemeToolsScript = load("res://addons/gamedev_ai/tools/ui_theme_tools.gd")
	var OmniToolsScript = load("res://addons/gamedev_ai/tools/omni_tools.gd")
	
	if ScriptToolsScript: _handlers.append(ScriptToolsScript.new())
	if NodeToolsScript: _handlers.append(NodeToolsScript.new())
	if FileToolsScript: _handlers.append(FileToolsScript.new())
	if ProjectToolsScript: _handlers.append(ProjectToolsScript.new())
	if MemoryToolsScript: _handlers.append(MemoryToolsScript.new())
	if DBToolsScript: _handlers.append(DBToolsScript.new())
	if AuditToolsScript: _handlers.append(AuditToolsScript.new())
	if AudioToolsScript: _handlers.append(AudioToolsScript.new())
	if ShaderToolsScript: _handlers.append(ShaderToolsScript.new())
	if TileMapToolsScript: _handlers.append(TileMapToolsScript.new())
	if AnimationToolsScript: _handlers.append(AnimationToolsScript.new())
	if UIThemeToolsScript: _handlers.append(UIThemeToolsScript.new())
	if OmniToolsScript: _handlers.append(OmniToolsScript.new())
	
	for h in _handlers:
		h.setup(self)

func init_vector_db(node: Node):
	var VectorDB = preload("res://addons/gamedev_ai/vector_db.gd")
	vector_db = VectorDB.new()
	vector_db.setup(node)
	vector_db.db_output.connect(func(out): tool_output.emit(out))

func start_composite_action(name: String, custom_context: Object = null):
	begin_batch_transaction(name, custom_context)

func begin_batch_transaction(name: String, custom_context: Object = null):
	if _undo_redo and _composite_action_name == "":
		_composite_action_name = name
		var ctx = custom_context
		if ctx == null:
			if Engine.is_editor_hint():
				ctx = EditorInterface.get_edited_scene_root()
			if ctx == null:
				ctx = self
		_undo_redo.create_action(name, UndoRedo.MERGE_DISABLE, ctx)

func commit_composite_action():
	commit_batch_transaction()

func commit_batch_transaction():
	if _undo_redo and _composite_action_name != "":
		_undo_redo.commit_action()
		_composite_action_name = ""
		if Engine.is_editor_hint():
			var root = EditorInterface.get_edited_scene_root()
			if root and not root.scene_file_path.is_empty():
				EditorInterface.save_scene()

func abort_batch_transaction():
	if _undo_redo and _composite_action_name != "":
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
		if child.get_parent() != parent:
			if child.get_parent() != null:
				child.get_parent().remove_child(child)
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

func _proxy_connect(source: Object, signal_name: String, callable: Callable, flags: int = 0):
	if is_instance_valid(source) and callable.is_valid():
		if not source.is_connected(signal_name, callable):
			source.connect(signal_name, callable, flags)

func _proxy_disconnect(source: Object, signal_name: String, callable: Callable):
	if is_instance_valid(source) and callable.is_valid():
		if source.is_connected(signal_name, callable):
			source.disconnect(signal_name, callable)

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
		# Try to reload — this will fail if instances of the script exist in the scene tree.
		# In that case, we skip the reload and let ResourceSaver + filesystem scan handle it.
		var reload_err = script.reload()
		if reload_err != OK:
			# This is expected for scripts attached to active nodes (e.g. @tool scripts, open scenes).
			# The source_code is already updated in memory; saving will persist it to disk.
			pass
		
		# Save using ResourceSaver, which avoids the "modified outside" popup
		var err = ResourceSaver.save(script, path)
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
	var config = ConfigFile.new()
	var err = config.parse(content)
	if err != OK:
		tool_output.emit("Error: Could not parse project.godot content (Code " + str(err) + ").")
		return
		
	for section in config.get_sections():
		# Skip non-setting sections (metadata headers)
		if section in ["godot", "gd_resource"]:
			continue
			
		for key in config.get_section_keys(section):
			var setting_path = key
			if section != "":
				setting_path = section + "/" + key
				
			var value = config.get_value(section, key)
			ProjectSettings.set_setting(setting_path, value)
	
	# Let Godot save it natively — no "reload from disk" popup
	err = ProjectSettings.save()
	if err != OK:
		tool_output.emit("Warning: ProjectSettings.save() returned error: " + str(err))

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


func get_tools() -> Array:
	return get_tool_definitions()

func get_tool_definitions() -> Array:
	return [
		{
			"name": "create_script",
			"description": "Creates a new text file (GDScript, Shader, Markdown, JSON, etc.) at the specified path with the given content.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The resource path (res://...) for the file (e.g. .gd, .gdshader, .md, .json)."},
					"content": {"type": "STRING", "description": "The code content."}
				},
				"required": ["path", "content"]
			}
		},
		{
			"name": "add_node",
			"description": "Adds a new node to a scene. If the target scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes. Use this to visually build levels, scenes, and UI hierarchies.",
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
			"description": "Attaches an existing GDScript to a node. If the target scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes.",
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
			"description": "Instantiates an existing .tscn scene file as a child of another node. If the parent scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes. Use this to place pre-made scenes (like an Enemy) into a level.",
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
			"description": "(DEPRECATED: Use patch_script) Edits an existing text file (GDScript, Shader, Markdown, etc.). You should read the file first to ensure you have the full current content before providing the updated version.",
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
			"description": "Removes a node from a scene. If the target scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes.",
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
			"description": "Reads the content of a file. Supports optional line slice reading via start_line and end_line for large files.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The file path (res://...)."},
					"start_line": {"type": "INTEGER", "description": "Optional starting line number (1-indexed). Defaults to 1."},
					"end_line": {"type": "INTEGER", "description": "Optional ending line number (1-indexed, inclusive). Defaults to -1 (end of file)."}
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
			"description": "Sets a standard property on a node (e.g., position, size, text, color). DO NOT use this for theme overrides like constants or font colors! If the target scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes. Can handle numbers, vectors, colors, and strings.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"node_path": {"type": "STRING", "description": "Path to the node in the scene tree."},
					"property": {"type": "STRING", "description": "The name of the standard property to set (e.g., 'text', 'size', 'position'). DO NOT use theme methods here (like 'add_theme_constant_override')."},
					"value": {"description": "The value to set. Can be string, number, or array for vectors [x, y] / colors [r, g, b, a]."}
				},
				"required": ["node_path", "property", "value"]
			}
		},
		{
			"name": "set_theme_override",
			"description": "Sets a theme override on a Control node (e.g., separation, margin, font_size, font_color). ALWAYS use this instead of set_property for theme-related visual changes. If the target scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes.",
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
			"description": "Surgically edits a text file (GDScript, Markdown, JSON, etc.) by replacing a specific block of code or text with new content. Use this for small changes to avoid overwriting the entire file.",
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
			"description": "Connects a signal from a source node to a target node's method. If the target scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes.",
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
			"description": "Disconnects a signal between nodes. If the target scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes.",
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
			"description": "Creates a new Resource file (.tres). Useful for data-driven assets like Items, Stats, Materials, etc.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "Save path (res://.../file.tres)."},
					"type": {"type": "STRING", "description": "The class name of the resource (e.g., 'Resource', 'ShaderMaterial')."},
					"properties": {"type": "OBJECT", "description": "Dictionary of initial property values. IMPORTANT: For resource-type properties (like 'shader', 'texture'), pass the string path ('res://...') directly, DO NOT pass a dictionary with uid/path! Example: {'shader': 'res://my_shader.gdshader', 'shader_parameter/intensity': 1.0}"}
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
			"description": "Returns a detailed dump of a specific node's sub-tree. If the target scene is not open, the plugin will automatically find and open it for you. DO NOT ask the user to open scenes. Use this to explore deep hierarchies when the main context manager truncates the tree.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"node_path": {"type": "STRING", "description": "The path to the node to inspect (e.g., 'Player/Sprite' or '.')."},
					"max_depth": {"type": "INTEGER", "description": "Optional: How deep to recursively dump children (default 5)."}
				},
				"required": ["node_path"]
			}
		},
		{
			"name": "audit_scene",
			"description": "Performs an architectural audit on the currently open scene, looking for orphan nodes, missing scripts, or warnings."
		},
		{
			"name": "audit_script",
			"description": "Performs a static analysis audit on a specific GDScript file to catch bad practices or syntax warnings.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The path to the script to audit (res://...)."}
				},
				"required": ["path"]
			}
		},
		{
			"name": "get_lsp_diagnostics",
			"description": "Inspects a GDScript file via Godot's built-in LSP server to detect compilation errors, type mismatches, and syntax warnings.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"path": {"type": "STRING", "description": "The resource path (res://...) to the GDScript file."}
				},
				"required": ["path"]
			}
		},
		{
			"name": "generate_sfx",
			"description": "Synthesizes a retro procedural sound effect (16-bit 44.1kHz WAV) using the sfxr synthesis engine and saves it to res://.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"preset": {"type": "STRING", "description": "Sound preset name (e.g. 'laser', 'coin', 'jump', 'explosion', 'powerup', 'hit', 'blip', 'select')."},
					"path": {"type": "STRING", "description": "Optional destination path (e.g. 'res://audio/sfx/laser.wav')."},
					"params": {"type": "OBJECT", "description": "Optional dictionary of custom synthesis parameters to override preset defaults."}
				},
				"required": ["preset"]
			}
		},
		{
			"name": "play_sfx_preview",
			"description": "Synthesizes and plays an immediate in-editor audio preview of a procedural sound effect without saving to disk.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"preset": {"type": "STRING", "description": "Sound preset name (e.g. 'laser', 'coin', 'jump', 'explosion', 'powerup', 'hit', 'blip', 'select')."},
					"params": {"type": "OBJECT", "description": "Optional dictionary of custom synthesis parameters to override preset defaults."}
				},
				"required": ["preset"]
			}
		},
		{
			"name": "generate_shader",
			"description": "Generates a .gdshader file with uniforms, visual effects, and helper code based on a preset or custom GLSL/Godot shading language code.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"preset": {"type": "STRING", "description": "Shader preset name (e.g. 'hit_flash', 'dissolve', 'outline', 'water_2d', 'chromatic_aberration', 'vignette', 'pixelate', 'glitch')."},
					"path": {"type": "STRING", "description": "Optional save path (res://.../shader.gdshader)."},
					"custom_code": {"type": "STRING", "description": "Optional custom shader source code."},
					"uniforms": {"type": "OBJECT", "description": "Optional dictionary of default uniform values."}
				},
				"required": ["preset"]
			}
		},
		{
			"name": "apply_shader_to_node",
			"description": "Creates or updates a ShaderMaterial with the specified shader and applies it to a CanvasItem or GeometryInstance3D node in the active scene.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"node_path": {"type": "STRING", "description": "Path to the target node in the scene tree."},
					"shader_path": {"type": "STRING", "description": "Path to the .gdshader resource file."},
					"preset": {"type": "STRING", "description": "Optional shader preset name if creating on the fly."},
					"uniforms": {"type": "OBJECT", "description": "Optional dictionary of uniform parameters to assign to the material."}
				}
			}
		},
		{
			"name": "get_shader_presets_list",
			"description": "Returns the complete list of available built-in 2D and 3D shader presets and their configurable uniforms."
		},
		{
			"name": "configure_tileset_atlas",
			"description": "Creates and configures a new TileSet resource (.tres) from a spritesheet texture, setting up tile size, atlas source, terrain sets, peering bits, and physics collision polygons.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"texture_path": {"type": "STRING", "description": "Resource path to the spritesheet texture (res://...)."},
					"tile_size": {"type": "ARRAY", "description": "Tile width and height in pixels as [width, height], e.g. [16, 16].", "items": {"type": "INTEGER"}},
					"save_path": {"type": "STRING", "description": "Save path for the .tres file (e.g. 'res://tilesets/dungeon_tileset.tres')."},
					"terrain_set_config": {"type": "OBJECT", "description": "Optional configuration for autotile terrain sets and peering bits."},
					"physics_config": {"type": "OBJECT", "description": "Optional physics collision layers and polygon vertices."}
				},
				"required": ["texture_path"]
			}
		},
		{
			"name": "build_tilemap_layout",
			"description": "Paints a layout matrix of tiles onto a TileMapLayer node in the active scene. (Godot 4.3+ standard)",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"layer_node_path": {"type": "STRING", "description": "Path to the TileMapLayer node in the scene tree (e.g. 'GroundLayer' or '.')."},
					"layout_matrix": {"type": "ARRAY", "description": "Array of tile entries, either dictionaries {'pos': [x,y], 'atlas': [ax,ay], 'source_id': 0} or arrays [x, y, ax, ay]."},
					"source_id": {"type": "INTEGER", "description": "Default TileSet atlas source ID (usually 0)."}
				},
				"required": ["layout_matrix"]
			}
		},
		{
			"name": "paint_terrain_cells",
			"description": "Paints autotile terrain connecting cells on a TileMapLayer using Godot's terrain system.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"layer_node_path": {"type": "STRING", "description": "Path to the TileMapLayer node."},
					"terrain_set": {"type": "INTEGER", "description": "The terrain set index (usually 0)."},
					"terrain_id": {"type": "INTEGER", "description": "The terrain ID within the set to paint with."},
					"cell_coordinates": {"type": "ARRAY", "description": "Array of [x, y] cell coordinates to paint with terrain."},
					"ignore_empty_terrains": {"type": "BOOLEAN", "description": "Whether to ignore empty surrounding terrain bits (default true)."}
				},
				"required": ["terrain_set", "terrain_id", "cell_coordinates"]
			}
		},
		{
			"name": "read_tilemap_layout",
			"description": "Inspects and reads existing placed tiles, bounding box, and cell coordinates from a TileMapLayer node.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"layer_node_path": {"type": "STRING", "description": "Path to the TileMapLayer node (e.g. 'GroundLayer' or '.')."},
					"bounding_box": {"type": "ARRAY", "description": "Optional region filter as [min_x, min_y, max_x, max_y]."}
				}
			}
		},
		{
			"name": "clear_tilemap_region",
			"description": "Clears all tiles or a specific rectangular region / array of coordinates from a TileMapLayer node.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"layer_node_path": {"type": "STRING", "description": "Path to the TileMapLayer node."},
					"rect": {"type": "ARRAY", "description": "Optional bounding rectangle [x, y, width, height] to clear."},
					"cell_coordinates": {"type": "ARRAY", "description": "Optional array of specific [x, y] coordinates to erase."}
				}
			}
		},
		{
			"name": "create_animation",
			"description": "Creates or updates an animation in an AnimationPlayer node with track keys (values, properties, methods, transforms), snapping, and loop modes.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"player_node_path": {"type": "STRING", "description": "Path to the AnimationPlayer node (e.g. 'AnimationPlayer' or 'Player/AnimationPlayer')."},
					"animation_name": {"type": "STRING", "description": "Name of the animation (e.g. 'walk_down', 'attack', 'jump')."},
					"library_name": {"type": "STRING", "description": "Optional animation library name. Leave empty for default library."},
					"length": {"type": "NUMBER", "description": "Duration in seconds (e.g. 0.8)."},
					"loop_mode": {"type": "STRING", "description": "Loop mode: 'none', 'linear', or 'pingpong'."},
					"tracks": {"type": "ARRAY", "description": "Array of track dictionaries containing 'node_path', 'property', 'track_type', 'update_mode', and 'keys'."}
				},
				"required": ["player_node_path", "animation_name"]
			}
		},
		{
			"name": "setup_spritesheet_animation",
			"description": "Automatically generates a 2D spritesheet animation for a Sprite2D node with discrete frame index tracks, configurable FPS, and auto-generated RESET track.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"player_node_path": {"type": "STRING", "description": "Path to the AnimationPlayer node."},
					"sprite_node_path": {"type": "STRING", "description": "Path to the Sprite2D node (e.g. 'Sprite2D')."},
					"animation_name": {"type": "STRING", "description": "Name of the animation (e.g. 'idle', 'run', 'attack')."},
					"start_frame": {"type": "INTEGER", "description": "Starting frame index on the spritesheet."},
					"frame_count": {"type": "INTEGER", "description": "Number of sequential frames in the animation."},
					"fps": {"type": "NUMBER", "description": "Playback frames per second (default: 10.0)."},
					"loop_mode": {"type": "STRING", "description": "Loop mode: 'linear', 'none', or 'pingpong'."},
					"auto_create_reset": {"type": "BOOLEAN", "description": "Whether to auto-create the essential RESET track (default: true)."}
				},
				"required": ["player_node_path", "animation_name", "start_frame", "frame_count"]
			}
		},
		{
			"name": "add_animation_event_track",
			"description": "Inserts method call events (e.g. _enable_hitbox()) or discrete property changes into an existing animation at a specific timestamp.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"player_node_path": {"type": "STRING", "description": "Path to the AnimationPlayer node."},
					"animation_name": {"type": "STRING", "description": "Target animation name."},
					"library_name": {"type": "STRING", "description": "Optional library name."},
					"event_type": {"type": "STRING", "description": "'method' or 'property'."},
					"target_node_path": {"type": "STRING", "description": "Relative path to the node receiving the call or property change."},
					"timestamp": {"type": "NUMBER", "description": "Timeline position in seconds (e.g. 0.35)."},
					"method_name_or_property": {"type": "STRING", "description": "Method name to call or property to set."},
					"method_args_or_value": {"type": "STRING", "description": "Arguments array for method or value for property."}
				},
				"required": ["player_node_path", "animation_name", "timestamp"]
			}
		},
		{
			"name": "inspect_animation_player",
			"description": "Inspects an AnimationPlayer node, returning a detailed list of all libraries, animations, tracks, durations, and key counts.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"player_node_path": {"type": "STRING", "description": "Path to the AnimationPlayer node."}
				},
				"required": ["player_node_path"]
			}
		},
		{
			"name": "create_state_machine",
			"description": "Creates or updates an AnimationTree node with an AnimationNodeStateMachine root, arranging state nodes with clean visual graph layout.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"tree_node_path": {"type": "STRING", "description": "Path to the AnimationTree node (e.g. 'AnimationTree')."},
					"anim_player_path": {"type": "STRING", "description": "Relative path to the AnimationPlayer (default: '../AnimationPlayer')."},
					"states": {"type": "ARRAY", "description": "Array of state dictionaries: [{'name': 'idle', 'animation': 'idle'}, {'name': 'walk', 'animation': 'walk'}]."},
					"transitions": {"type": "ARRAY", "description": "Array of transition dictionaries with 'from', 'to', 'advance_mode', 'advance_condition', 'advance_expression', 'xfade_time'."},
					"start_state": {"type": "STRING", "description": "Initial state name (e.g. 'idle')."},
					"set_active": {"type": "BOOLEAN", "description": "Whether to activate the AnimationTree (default: true)."}
				},
				"required": ["tree_node_path", "states"]
			}
		},
		{
			"name": "create_blend_space_2d",
			"description": "Creates an AnimationNodeBlendSpace2D for multi-directional movement (4D/8D) and adds it to an AnimationTree StateMachine.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"tree_node_path": {"type": "STRING", "description": "Path to the AnimationTree node."},
					"state_name": {"type": "STRING", "description": "Name for the BlendSpace2D state (e.g. 'MoveSpace')."},
					"blend_points": {"type": "ARRAY", "description": "Array of points: [{'pos': [0, 1], 'animation': 'walk_down'}, {'pos': [0, -1], 'animation': 'walk_up'}]."},
					"blend_mode": {"type": "STRING", "description": "'interpolated' or 'discrete'."},
					"min_space": {"type": "ARRAY", "description": "[min_x, min_y] (default: [-1, -1])."},
					"max_space": {"type": "ARRAY", "description": "[max_x, max_y] (default: [1, 1])."}
				},
				"required": ["tree_node_path", "state_name", "blend_points"]
			}
		},
		{
			"name": "connect_state_machine_transition",
			"description": "Connects or updates a transition between two states in an AnimationTree StateMachine with crossfade, switch mode, and GDScript advance_expression / advance_condition.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"tree_node_path": {"type": "STRING", "description": "Path to the AnimationTree node."},
					"from_state": {"type": "STRING", "description": "Origin state name."},
					"to_state": {"type": "STRING", "description": "Destination state name."},
					"advance_condition": {"type": "STRING", "description": "Optional boolean condition parameter name (e.g. 'is_moving')."},
					"advance_expression": {"type": "STRING", "description": "Optional GDScript expression evaluated in real-time (e.g. 'velocity.length() > 5.0')."},
					"advance_mode": {"type": "STRING", "description": "'auto', 'enabled', or 'disabled'."},
					"xfade_time": {"type": "NUMBER", "description": "Smooth crossfade time in seconds (default: 0.15)."},
					"switch_mode": {"type": "STRING", "description": "'immediate', 'at_end', or 'sync'."}
				},
				"required": ["tree_node_path", "from_state", "to_state"]
			}
		},
		{
			"name": "inspect_animation_tree",
			"description": "Inspects an AnimationTree node, returning its StateMachine nodes, graph layout positions, blend spaces, and active transitions.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"tree_node_path": {"type": "STRING", "description": "Path to the AnimationTree node."}
				},
				"required": ["tree_node_path"]
			}
		},
		{
			"name": "setup_character_animation_suite",
			"description": "Constructs a complete character animation suite in a single command: AnimationPlayer, RESET track, all spritesheet animations (idle, walk, run, jump, attack, hurt, death), AnimationTree with StateMachine, and fully wired transitions.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"parent_path": {"type": "STRING", "description": "Path to character root node (e.g. '.' or 'Player')."},
					"sprite_node_path": {"type": "STRING", "description": "Relative path to Sprite2D node."},
					"animations_config": {"type": "OBJECT", "description": "Optional custom dictionary mapping animation names to start_frame, frame_count, fps, and loop."},
					"state_machine_config": {"type": "OBJECT", "description": "Optional custom transitions configuration."},
					"auto_create_tree": {"type": "BOOLEAN", "description": "Whether to create and link the AnimationTree (default: true)."},
					"generate_helper_script": {"type": "BOOLEAN", "description": "Whether to generate helper playback control boilerplate (default: false)."}
				},
				"required": ["parent_path", "sprite_node_path"]
			}
		},
		{
			"name": "generate_ui_theme",
			"description": "Generates a complete production-grade Godot Theme resource (.tres) with curated color palettes, StyleBoxFlat styles (Button, Panel, LineEdit, ProgressBar, HSlider, TabContainer), corner radiuses, and shadows.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"preset_or_name": {"type": "STRING", "description": "Preset name: 'glassmorphism', 'cyberpunk', 'fantasy_gold', 'cozy_pastel', 'retro_pixel', or 'custom'."},
					"save_path": {"type": "STRING", "description": "Optional save path (e.g. 'res://themes/my_theme.tres')."},
					"colors": {"type": "OBJECT", "description": "Optional custom color overrides: {'primary_color': '#3B82F6', 'bg_color': '#0F172A', 'accent_color': '#10B981', 'text_color': '#FFFFFF'}."},
					"metrics": {"type": "OBJECT", "description": "Optional custom metrics: {'corner_radius': 10, 'border_width': 1, 'shadow_size': 8}."},
					"set_as_project_theme": {"type": "BOOLEAN", "description": "Whether to set as global game theme in ProjectSettings.gui/theme/custom (default: true)."}
				},
				"required": ["preset_or_name"]
			}
		},
		{
			"name": "create_responsive_ui_component",
			"description": "Generates or instantiates a fully responsive production UI component scene (.tscn) with proper layout containers and anchor presets: 'hud', 'pause_menu', 'inventory_grid', 'dialogue_box', or 'main_menu'.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"component_type": {"type": "STRING", "description": "Component type: 'hud', 'pause_menu', 'inventory_grid', 'dialogue_box', or 'main_menu'."},
					"save_path": {"type": "STRING", "description": "Optional save path for the .tscn scene file."},
					"theme_path": {"type": "STRING", "description": "Optional path to the .tres theme to bind to the root component."},
					"parent_node_path": {"type": "STRING", "description": "Optional parent node path if instantiating directly into the active scene."}
				},
				"required": ["component_type"]
			}
		},
		{
			"name": "apply_theme_to_scene",
			"description": "Applies a Theme (.tres) resource to a specific Control node tree in the active scene.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"theme_path": {"type": "STRING", "description": "Resource path to the Theme (.tres) file."},
					"node_path": {"type": "STRING", "description": "Path to the target Control node (default: '.')."}
				},
				"required": ["theme_path"]
			}
		},
		{
			"name": "inspect_theme",
			"description": "Inspects a Theme resource (.tres), reporting all configured Control types and custom style overrides.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"theme_path": {"type": "STRING", "description": "Optional path to Theme file. If omitted, checks ProjectSettings global theme."}
				}
			}
		},
		{
			"name": "omni_eval",
			"description": "Dynamically evaluates a snippet of GDScript or a mathematical/logical expression in real-time, executing safely in the context of the active scene or a specified target node.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"code": {"type": "STRING", "description": "The GDScript code block or expression to evaluate dynamically."},
					"context_node_path": {"type": "STRING", "description": "Optional node path to bind as the execution context/self (default: active scene root)."}
				},
				"required": ["code"]
			}
		},
		{
			"name": "omni_manage",
			"description": "Universal Godot reflection and invocation tool. Directly call any method on any node, inspect ClassDB APIs (methods, properties, signals, enums), or read/write properties dynamically without predefined tool limits.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"action": {"type": "STRING", "description": "Action to perform: 'call_method', 'get_property', 'set_property', 'inspect_class', 'list_methods', or 'list_properties'."},
					"target_path": {"type": "STRING", "description": "Path to the target node in the active scene tree (required for call_method, get_property, set_property)."},
					"method_name": {"type": "STRING", "description": "Method name to invoke when action is 'call_method'."},
					"args": {"type": "ARRAY", "description": "Arguments array to pass to the method."},
					"property": {"type": "STRING", "description": "Property name when action is 'get_property' or 'set_property'."},
					"value": {"type": "STRING", "description": "Value to assign when action is 'set_property'."},
					"class_name": {"type": "STRING", "description": "Godot class name to inspect when action is 'inspect_class' (e.g. 'CharacterBody2D', 'TileMapLayer', 'RigidBody3D')."}
				},
				"required": ["action"]
			}
		},
		{
			"name": "get_runtime_errors",
			"description": "Fetches recent runtime errors, exceptions, and stack traces recorded by the Godot Debugger while the game is running (F5/F6).",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"clear_after_read": {"type": "BOOLEAN", "description": "If true, clears the error buffer after retrieving."}
				}
			}
		},
		{
			"name": "get_runtime_status",
			"description": "Queries Godot's runtime execution status (is game running, paused at breakpoint, or stopped, plus debug statistics).",
			"parameters": {
				"type": "OBJECT",
				"properties": {}
			}
		},
		{
			"name": "generate_procedural_dungeon",
			"description": "Generates a complete procedural dungeon or cave level on a TileMapLayer in a single call. Algorithms: 'bsp' (rooms & binary space split), 'rooms_and_corridors' (classic roguelike), 'cellular' (natural organic caverns), or 'drunkard_walk' (winding catacombs). Supports direct tile placement or Godot 4 autotile terrain connection.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"layer_node_path": {"type": "STRING", "description": "Path to the target TileMapLayer node (default: '.')."},
					"algorithm": {"type": "STRING", "description": "Algorithm to use: 'bsp', 'rooms_and_corridors', 'cellular', or 'drunkard_walk' (default: 'bsp')."},
					"width": {"type": "INTEGER", "description": "Dungeon width in tiles (default: 40)."},
					"height": {"type": "INTEGER", "description": "Dungeon height in tiles (default: 30)."},
					"room_min_size": {"type": "INTEGER", "description": "Minimum room dimension in tiles (default: 5)."},
					"room_max_size": {"type": "INTEGER", "description": "Maximum room dimension in tiles (default: 10)."},
					"max_rooms": {"type": "INTEGER", "description": "Maximum number of rooms to generate (default: 8)."},
					"seed": {"type": "INTEGER", "description": "Optional RNG seed for deterministic generation (-1 for random)."},
					"source_id": {"type": "INTEGER", "description": "TileSet source ID (default: 0)."},
					"floor_tile": {"type": "ARRAY", "description": "Atlas coordinate for floor tiles [col, row] (default: [0, 0])."},
					"wall_tile": {"type": "ARRAY", "description": "Atlas coordinate for wall tiles [col, row] (default: [1, 0])."},
					"use_terrain_autotile": {"type": "BOOLEAN", "description": "If true, connects tiles using Godot 4's set_cells_terrain_connect instead of static atlas IDs."},
					"terrain_set": {"type": "INTEGER", "description": "Terrain set index if use_terrain_autotile is true (default: 0)."},
					"terrain_id": {"type": "INTEGER", "description": "Terrain ID index if use_terrain_autotile is true (default: 0)."}
				}
			}
		},
		{
			"name": "scaffold_autotile_bitmasks",
			"description": "Scaffolds standard terrain autotile 8-bit peering bitmasks across an atlas region in a TileSet (.tres) resource. Templates: 'simple_box' (3x3 - 9 tiles), 'kenney_3x3_minimal' (4x4 - 16 tiles), or 'rpgmaker_47' (full Wang 47 autotile format).",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"tileset_path": {"type": "STRING", "description": "Path to the TileSet (.tres) file."},
					"source_id": {"type": "INTEGER", "description": "TileSetAtlasSource ID (default: 0)."},
					"terrain_set": {"type": "INTEGER", "description": "Terrain set index (default: 0)."},
					"terrain_id": {"type": "INTEGER", "description": "Terrain index ID (default: 0)."},
					"template": {"type": "STRING", "description": "Template layout: 'simple_box', 'kenney_3x3_minimal', or 'rpgmaker_47'."},
					"offset_col": {"type": "INTEGER", "description": "Starting column offset in the atlas (default: 0)."},
					"offset_row": {"type": "INTEGER", "description": "Starting row offset in the atlas (default: 0)."}
				},
				"required": ["tileset_path"]
			}
		},
		{
			"name": "get_atlas_image",
			"description": "Inspects a spritesheet or TileSet atlas texture, returning a Base64-encoded PNG with an optional grid overlay showing tile coordinate lines (col, row), enabling multimodal LLMs to visually inspect sprites.",
			"parameters": {
				"type": "OBJECT",
				"properties": {
					"texture_path": {"type": "STRING", "description": "Path to the image/spritesheet texture file (e.g. res://assets/dungeon.png)."},
					"tileset_path": {"type": "STRING", "description": "Alternative: path to a TileSet resource (.tres) to inspect."},
					"source_id": {"type": "INTEGER", "description": "TileSet source ID when using tileset_path (default: 0)."},
					"tile_width": {"type": "INTEGER", "description": "Tile width for grid overlay (default: 16)."},
					"tile_height": {"type": "INTEGER", "description": "Tile height for grid overlay (default: 16)."},
					"max_size": {"type": "INTEGER", "description": "Maximum dimension for image scaling to reduce token size (default: 512)."},
					"grid_overlay": {"type": "BOOLEAN", "description": "Whether to draw red tile grid lines over the image (default: true)."}
				}
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

