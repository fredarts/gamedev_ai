@tool
extends RefCounted

signal tool_output(output)

var _undo_redo: EditorUndoRedoManager
var _composite_action_name: String = ""

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
func _create_file_undoable(path: String, content: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
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
			"description": "Edits an existing GDScript file. You should read the file first to ensure you have the full current content before providing the updated version.",
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
		}
	]

func execute_tool(tool_name: String, args: Dictionary):
	print("Executing tool: " + tool_name + " with args: " + str(args))
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
			_get_class_info(args.get("class_name"))
		_:
			tool_output.emit("Error: Unknown tool " + tool_name)

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
			tool_output.emit("Success: Script created at " + path)
		else:
			# If composite, we don't emit success yet or we do? 
			# Emitting success for each step is fine for the log.
			tool_output.emit("Success: Script creation queued for " + path)
	else:
		# Fallback
		_create_file_undoable(path, content)
		tool_output.emit("Success: Script created at " + path + " (No Undo)")

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
			# Small delay to ensure file is written
			await Engine.get_main_loop().create_timer(0.1).timeout
			
			EditorInterface.get_resource_filesystem().scan()
			EditorInterface.open_scene_from_path(path)
			# Only emit success if not part of a larger undo/redo chain calling this
			# But here we are inside the do_method.
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
			tool_output.emit("Success: Scene " + scene_path + " instanced as " + name + " under " + parent.name)
		else:
			tool_output.emit("Success: Scene instance queued: " + name)
	else:
		var instance = scene.instantiate()
		instance.name = name
		parent.add_child(instance)
		instance.owner = root
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
			tool_output.emit("Error: Invalid node type: " + type)
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
		tool_output.emit("Error: File not found at " + path + ". Use create_script if it's a new file.")
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
			tool_output.emit("Success: Script edited at " + path)
		else:
			tool_output.emit("Success: Script edit queued for " + path)
	else:
		_create_file_undoable(path, new_content)
		tool_output.emit("Success: Script edited at " + path + " (No Undo)")

func _remove_node(node_path: String):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		tool_output.emit("Error: No scene open.")
		return
		
	var node = root.get_node(node_path)
	if not node:
		tool_output.emit("Error: Node not found at path: " + node_path)
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
			tool_output.emit("Success: Node " + node_path + " removed.")
		else:
			tool_output.emit("Success: Node removal queued: " + node_path)
	else:
		node.get_parent().remove_child(node)
		node.queue_free()
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
		tool_output.emit("Error: Node not found: " + node_path)
		return
		
	var final_value = _parse_value(value)
	
	if _undo_redo:
		if _composite_action_name == "":
			_undo_redo.create_action("Set Property " + property + " on " + node.name, UndoRedo.MERGE_DISABLE, self)
			
		_undo_redo.add_do_method(self, "_proxy_set_property", node, property, final_value)
		_undo_redo.add_undo_method(self, "_proxy_set_property", node, property, node.get(property))
		
		if _composite_action_name == "":
			_undo_redo.commit_action()
			tool_output.emit("Success: Set " + property + " to " + str(final_value) + " on " + node_path)
		else:
			tool_output.emit("Success: Set property queued: " + property + " on " + node_path)
	else:
		node.set(property, final_value)
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
		tool_output.emit("Success: Set theme override " + name + " on " + node_path)

func _parse_value(value: Variant) -> Variant:
	if value is Array:
		if value.size() == 2:
			return Vector2(value[0], value[1])
		if value.size() == 3:
			return Color(value[0], value[1], value[2])
		if value.size() == 4:
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

func _get_class_info(class_name: String):
	if not ClassDB.class_exists(class_name):
		# Check if it's a custom class by scanning our index or project
		# For now, let's assume Engine classes first.
		tool_output.emit("Error: Class '" + class_name + "' not found in ClassDB.")
		return
		
	var info = "Class: " + class_name + "\n"
	info += "Inherits: " + ClassDB.get_parent_class(class_name) + "\n"
	
	var properties = ClassDB.class_get_property_list(class_name, true)
	info += "\nProperties:\n"
	for p in properties:
		# Filter for actual properties, not internal ones
		if p.usage & PROPERTY_USAGE_EDITOR:
			info += "- " + p.name + " (Type: " + str(p.type) + ")\n"
			
	var methods = ClassDB.class_get_method_list(class_name, true)
	info += "\nMethods:\n"
	for m in methods:
		if not m.name.begin_with("_"):
			info += "- " + m.name + "(" + str(m.args.size()) + " args)\n"
			
	var signals = ClassDB.class_get_signal_list(class_name, true)
	info += "\nSignals:\n"
	for s in signals:
		info += "- " + s.name + "\n"
		
	tool_output.emit(info)
