@tool
extends RefCounted

var executor: RefCounted

func setup(_executor: RefCounted):
	executor = _executor

func execute(tool_name: String, args: Dictionary) -> bool:
	# Override this method
	return false

# --- Helper Methods ---

func _emit_output(msg: String):
	if executor:
		executor.tool_output.emit(msg)

func _request_confirmation(msg: String, tool_name: String, args: Dictionary):
	if executor:
		executor._pending_confirm_tool = tool_name
		executor._pending_confirm_args = args
		executor.confirmation_needed.emit(msg, tool_name, args)

func _request_diff_preview(path: String, old_content: String, new_content: String, tool_name: String, args: Dictionary):
	if executor:
		executor._pending_diff_path = path
		executor._pending_diff_old_content = old_content
		executor._pending_diff_new_content = new_content
		executor._pending_confirm_tool = tool_name
		executor._pending_confirm_args = args
		executor.diff_preview_requested.emit(path, old_content, new_content, tool_name, args)

func _get_undo_redo() -> EditorUndoRedoManager:
	if executor and "_undo_redo" in executor:
		return executor._undo_redo
	return null

func _get_scene_context() -> Object:
	if Engine.is_editor_hint():
		var root = EditorInterface.get_edited_scene_root()
		if is_instance_valid(root):
			return root
	return executor

func _is_composite() -> bool:
	if executor and "_composite_action_name" in executor:
		return executor._composite_action_name != ""
	return false

func _has_undo() -> bool:
	return _get_undo_redo() != null

func _duplicate_value(val: Variant) -> Variant:
	if val is Dictionary:
		return val.duplicate(true)
	elif val is Array:
		return val.duplicate(true)
	elif val is Resource and val.has_method("duplicate"):
		return val.duplicate(true)
	return val

func _create_undo_action(action_name: String, custom_context: Object = null):
	var ur = _get_undo_redo()
	if ur:
		var ctx = custom_context if custom_context else _get_scene_context()
		ur.create_action(action_name, UndoRedo.MERGE_DISABLE, ctx)

func _commit_undo_action():
	var ur = _get_undo_redo()
	if ur:
		ur.commit_action()
		_mark_scene_dirty()

func _mark_scene_dirty():
	if Engine.is_editor_hint():
		var root = EditorInterface.get_edited_scene_root()
		if root and not root.scene_file_path.is_empty():
			EditorInterface.mark_scene_as_unsaved()

