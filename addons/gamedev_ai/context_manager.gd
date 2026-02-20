@tool
extends RefCounted

func get_project_settings_dump() -> String:
	var settings = ""
	settings += "Application Name: " + str(ProjectSettings.get_setting("application/config/name")) + "\n"
	# Add more relevant settings here
	return settings

func get_scene_tree_dump() -> String:
	# This function would traverse the current edited scene and return a text representation
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		return "No scene opened."
	return _node_to_string(root, 0)

func _node_to_string(node: Node, depth: int) -> String:
	if depth > 8: # Depth limit to prevent massive dumps
		return "  ... (max depth reached)\n"
		
	var s = ""
	for i in range(depth):
		s += "  "
	s += node.name + " (" + node.get_class() + ")"
	
	# Include key properties for better AI context
	var extras: Array = []
	if node.get_script():
		extras.append("script:" + node.get_script().resource_path.get_file())
	if node is Node2D:
		extras.append("pos:" + str(node.position))
	elif node is Node3D:
		extras.append("pos:" + str(node.position))
	if node is CanvasItem and not node.visible:
		extras.append("hidden")
	
	if not extras.is_empty():
		s += " [" + ", ".join(extras) + "]"
	s += "\n"
	
	for child in node.get_children():
		s += _node_to_string(child, depth + 1)
	return s

func get_current_script() -> String:
	var script_editor = EditorInterface.get_script_editor()
	var current_script = script_editor.get_current_script()
	if current_script:
		return "Current Script: " + current_script.resource_path + "\n\n" + current_script.source_code
	return "No script selected."

func get_editor_screenshot() -> Dictionary:
	# Attempt to capture the main editor window
	var viewport = EditorInterface.get_base_control().get_viewport()
	if not viewport:
		return {}
		
	var texture = viewport.get_texture()
	var image = texture.get_image()
	
	# Resize if too large to save tokens/bandwidth (optional but recommended)
	if image.get_width() > 1024:
		var scale = 1024.0 / image.get_width()
		image.resize(1024, int(image.get_height() * scale))
		
	var buffer = image.save_png_to_buffer()
	var base64 = Marshalls.raw_to_base64(buffer)
	
	return {
		"mime_type": "image/png",
		"data": base64
	}

func get_selection_info() -> Dictionary:
	var script_editor = EditorInterface.get_script_editor()
	var current_editor = script_editor.get_current_editor()
	if not current_editor:
		return {}
	
	# Current editor has a 'code_edit' property in Godot 4
	var code_edit = current_editor.get_base_editor()
	if code_edit and code_edit is CodeEdit and code_edit.has_selection():
		return {
			"text": code_edit.get_selected_text(),
			"path": script_editor.get_current_script().resource_path
		}
	return {}

func get_project_index() -> String:
	var index_str = "Project Structure Map:\n"
	index_str += _scan_directory("res://")
	return index_str

func _scan_directory(path: String) -> String:
	var result = ""
	var dir = DirAccess.open(path)
	if not dir:
		return ""
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."): 
			file_name = dir.get_next()
			continue
			
		var full_path = path + file_name
		if dir.current_is_dir():
			result += _scan_directory(full_path + "/")
		else:
			if file_name.ends_with(".tscn"):
				result += "- [Scene] " + full_path + "\n"
			elif file_name.ends_with(".gd"):
				var class_name_found = _extract_class_name(full_path)
				if class_name_found != "":
					result += "- [Class] " + class_name_found + " (" + full_path + ")\n"
				else:
					result += "- [Script] " + full_path + "\n"
		file_name = dir.get_next()
		
	return result

func _extract_class_name(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return ""
		
	# Look for 'class_name' in the first few lines
	var count = 0
	while not file.eof_reached() and count < 20:
		var line = file.get_line().strip_edges()
		if line.begins_with("class_name"):
			var parts = line.split(" ", false)
			if parts.size() >= 2:
				return parts[1].replace(":", "").strip_edges()
		count += 1
	return ""
