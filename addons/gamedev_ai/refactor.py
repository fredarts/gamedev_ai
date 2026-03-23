import re

GD_PATH = r"c:\Users\Fred\Documents\game-dev\Gamedev Ai\addons\gamedev_ai\tool_executor.gd"

with open(GD_PATH, "r", encoding="utf-8") as f:
    text = f.read()

parts = text.split("func _read_skill(skill_name: String):")
if len(parts) < 2:
    print("Could not find func _read_skill!")
    exit(1)

top_part = parts[0]

# Now, top_part has everything up to and including get_tool_definitions()
# But wait, confirm_pending_action and setup are in top_part (they are before get_tool_definitions)

# Remove confirm_pending_action from top_part
top_part = re.sub(r'func confirm_pending_action\(\):.*?(?=func cancel_pending_action\(\):)', '', top_part, flags=re.DOTALL)

# Remove setup from top_part 
top_part = re.sub(r'func setup\(undo_redo: EditorUndoRedoManager\):.*?(?=func init_vector_db)', '', top_part, flags=re.DOTALL)

# Insert new setup
new_setup = """func setup(undo_redo: EditorUndoRedoManager):
	_undo_redo = undo_redo
	
	var NodeTools = load("res://addons/gamedev_ai/tools/node_tools.gd")
	var ScriptTools = load("res://addons/gamedev_ai/tools/script_tools.gd")
	var FileTools = load("res://addons/gamedev_ai/tools/file_tools.gd")
	var ProjectTools = load("res://addons/gamedev_ai/tools/project_tools.gd")
	var MemoryTools = load("res://addons/gamedev_ai/tools/memory_tools.gd")
	var DBTools = load("res://addons/gamedev_ai/tools/db_tools.gd")
	
	_handlers.append(NodeTools.new())
	_handlers.append(ScriptTools.new())
	_handlers.append(FileTools.new())
	_handlers.append(ProjectTools.new())
	_handlers.append(MemoryTools.new())
	_handlers.append(DBTools.new())
	
	for h in _handlers:
		h.setup(self)

"""
top_part = top_part.replace("func _init():\n\tpass\n\n", "func _init():\n\tpass\n\n" + new_setup)


# Inject _handlers variable near the top
top_part = top_part.replace("var _pending_diff_path: String = \"\"\n", "var _pending_diff_path: String = \"\"\nvar _handlers: Array = []\n")

new_bottom = """
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
			pass # In gdscript this requires opening the file, replacing, etc. We'll reconstruct this carefully.
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

"""

final_content = top_part + new_bottom

with open(GD_PATH, "w", encoding="utf-8") as f:
    f.write(final_content)
print("Done!")
