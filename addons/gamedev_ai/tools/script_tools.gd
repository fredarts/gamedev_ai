@tool
extends BaseToolHandler
class_name ScriptTools

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"create_script":
			_create_script(args.get("path"), args.get("content"))
			return true
		"attach_script":
			_attach_script(args.get("node_path"), args.get("script_path"))
			return true
		"edit_script":
			_edit_script(args.get("path"), args.get("content"))
			return true
		"patch_script":
			_patch_script(args.get("path"), args.get("search_content"), args.get("replace_content"))
			return true
		"replace_selection":
			_replace_selection(args.get("text"))
			return true
	return false

func _validate_script(path: String) -> String:
	if not path.ends_with(".gd"):
		return ""
	var script = load(path)
	if script == null:
		return "⚠️ Validation: Failed to load script. It may contain syntax errors."
	if script is GDScript:
		var err = script.reload()
		if err != OK:
			return "⚠️ Validation: Script has errors (reload error code: " + str(err) + "). Check for syntax issues."
	return "" 

func _create_script(path: String, content: String):
	if not path.begins_with("res://"):
		_emit_output("Error: Path must start with res://")
		return

	if executor.use_diff_preview:
		_request_diff_preview(path, "", content, "create_script", {"path": path, "content": content})
		return
	_apply_create_script(path, content)

func _attach_script(node_path: String, script_path: String):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		_emit_output("Error: No scene open.")
		return

	var node: Node = null
	if node_path == "." or node_path == "":
		node = root
	else:
		node = root.get_node_or_null(node_path)
		if not node:
			# Fallback: search by name
			var node_name = node_path.get_file()
			if node_name != "":
				node = root.find_child(node_name, true, false)
	if not node:
		_emit_output("Error: Node not found: '" + node_path + "'. Make sure the scene containing this node is open in the editor.")
		return
		
	if not FileAccess.file_exists(script_path):
		_emit_output("Error: Script file not found: " + script_path)
		return
		
	var script = load(script_path)
	if not script:
		_emit_output("Error: Failed to load script: " + script_path)
		return
		
	var ur = _get_undo_redo()
	if ur:
		if not _is_composite():
			ur.create_action("Attach Script to " + node.name, UndoRedo.MERGE_DISABLE, executor)
		
		ur.add_do_method(executor, "_proxy_set_script", node, script)
		ur.add_undo_method(executor, "_proxy_set_script", node, null) 
		
		if not _is_composite():
			ur.commit_action()
			_emit_output("Success: Attached " + script_path + " to " + node_path)
		else:
			_emit_output("Success: Attach script queued for " + node_path)
	else:
		node.set_script(script)
		_emit_output("Success: Attached " + script_path + " to " + node_path + " (No Undo)")

func _edit_script(path: String, new_content: String):
	if not FileAccess.file_exists(path):
		_emit_output("Error: File not found at " + path + ". Use find_file('" + path.get_file().get_basename() + "') to locate it, or create_script to create a new file.")
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	var old_content = file.get_as_text()
	file.close()

	if executor.use_diff_preview:
		_request_diff_preview(path, old_content, new_content, "edit_script", {"path": path, "content": new_content})
		return
	_apply_edit_script(path, old_content, new_content)

func _patch_script(path: String, search_content: String, replace_content: String):
	if not FileAccess.file_exists(path):
		_emit_output("Error: File not found at " + path + ". Use find_file('" + path.get_file().get_basename() + "') to locate it.")
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	if content.find(search_content) == -1:
		_emit_output("Error: Search block not found in " + path.get_file() + ". The search must be an EXACT match including whitespace and indentation. Use read_file first to get the exact current content.")
		return
		
	if content.count(search_content) > 1:
		_emit_output("Error: Search block matches multiple locations in " + path.get_file() + ". Provide more context to make it unique.")
		return
		
	var new_content = content.replace(search_content, replace_content)

	if executor.use_diff_preview:
		_request_diff_preview(path, search_content, replace_content, "patch_script", {"path": path, "search_content": search_content, "replace_content": replace_content})
		return

	_apply_patch_script(path, content, new_content)

func _replace_selection(text: String):
	var script_editor = EditorInterface.get_script_editor()
	var current_editor = script_editor.get_current_editor()
	if not current_editor:
		_emit_output("Error: No script editor open.")
		return
		
	var code_edit = current_editor.get_base_editor()
	if not code_edit or not code_edit is CodeEdit:
		_emit_output("Error: Could not find CodeEdit in current editor.")
		return
		
	if not code_edit.has_selection():
		_emit_output("Error: No text selected in the editor.")
		return
		
	var old_text = code_edit.get_selected_text()
	var path = "Unknown"
	var current_script = script_editor.get_current_script()
	if current_script:
		path = current_script.resource_path

	if executor.use_diff_preview:
		_request_diff_preview(path, old_text, text, "replace_selection", {"text": text})
		return

	_apply_replace_selection(text)

func _apply_create_script(path: String, content: String):
	if _get_undo_redo():
		if not _is_composite():
			_get_undo_redo().create_action("Create Script " + path.get_file(), UndoRedo.MERGE_DISABLE, executor)

		_get_undo_redo().add_do_method(executor, "_create_file_undoable", path, content)
		_get_undo_redo().add_undo_method(executor, "_delete_file_undoable", path)
		
		if not _is_composite():
			_get_undo_redo().commit_action()
			var msg = "Success: Script created at " + path
			var validation = _validate_script(path)
			if validation != "":
				msg += " | " + validation
			_emit_output(msg)
		else:
			_emit_output("Success: Script creation queued for " + path)
	else:
		# Fallback
		executor._create_file_undoable(path, content)
		var msg = "Success: Script created at " + path + " (No Undo)"
		var validation = _validate_script(path)
		if validation != "":
			msg += " | " + validation
		_emit_output(msg)


func _apply_edit_script(path: String, old_content: String, new_content: String):
	if _get_undo_redo():
		if not _is_composite():
			_get_undo_redo().create_action("Edit Script " + path.get_file(), UndoRedo.MERGE_DISABLE, executor)

		_get_undo_redo().add_do_method(executor, "_create_file_undoable", path, new_content)
		_get_undo_redo().add_undo_method(executor, "_create_file_undoable", path, old_content)
		
		if not _is_composite():
			_get_undo_redo().commit_action()
			var msg = "Success: Script edited at " + path
			var validation = _validate_script(path)
			if validation != "":
				msg += " | " + validation
			msg += " | [color=yellow]Warning: edit_script is deprecated. Please prefer patch_script.[/color]"
			_emit_output(msg)
		else:
			_emit_output("Success: Script edit queued for " + path)
	else:
		executor._create_file_undoable(path, new_content)
		var msg = "Success: Script edited at " + path + " (No Undo)"
		var validation = _validate_script(path)
		if validation != "":
			msg += " | " + validation
		msg += " | [color=yellow]Warning: edit_script is deprecated. Please prefer patch_script.[/color]"
		_emit_output(msg)


func _apply_patch_script(path: String, old_content: String, new_content: String):
	if _get_undo_redo():
		if not _is_composite():
			_get_undo_redo().create_action("Patch Script " + path.get_file(), UndoRedo.MERGE_DISABLE, executor)

		_get_undo_redo().add_do_method(executor, "_create_file_undoable", path, new_content)
		_get_undo_redo().add_undo_method(executor, "_create_file_undoable", path, old_content)
		
		if not _is_composite():
			_get_undo_redo().commit_action()
			var msg = "Success: Patched " + path.get_file()
			var validation = _validate_script(path)
			if validation != "":
				msg += " | " + validation
			_emit_output(msg)
		else:
			_emit_output("Success: Patch queued for " + path)
	else:
		executor._create_file_undoable(path, new_content)
		var msg = "Success: Patched " + path.get_file() + " (No Undo)"
		var validation = _validate_script(path)
		if validation != "":
			msg += " | " + validation
		_emit_output(msg)


func _apply_replace_selection(text: String):
	var script_editor = EditorInterface.get_script_editor()
	var current_editor = script_editor.get_current_editor()
	if not current_editor: return
	var code_edit = current_editor.get_base_editor()
	if not code_edit: return

	code_edit.begin_complex_operation()
	code_edit.insert_text_at_caret(text)
	code_edit.end_complex_operation()
	
	_emit_output("Success: Selected text replaced.")

