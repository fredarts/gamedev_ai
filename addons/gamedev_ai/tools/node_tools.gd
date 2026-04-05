@tool
extends BaseToolHandler
class_name NodeTools

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"add_node":
			_add_node(args.get("parent_path"), args.get("type"), args.get("name"), args.get("script_path", ""))
			return true
		"remove_node":
			var node_path = args.get("node_path", "")
			_request_confirmation("Remove node '" + node_path + "' from the scene?", tool_name, args)
			return true
		"instance_scene":
			_instance_scene(args.get("parent_path"), args.get("scene_path"), args.get("name"))
			return true
		"set_property":
			_set_property(args.get("node_path"), args.get("property"), args.get("value"))
			return true
		"set_theme_override":
			_set_theme_override(args.get("node_path"), args.get("override_type"), args.get("name"), args.get("value"))
			return true
		"connect_signal":
			_connect_signal(args.get("source_path"), args.get("signal_name"), args.get("target_path"), args.get("method_name"), args.get("binds", []), args.get("flags", 0))
			return true
		"disconnect_signal":
			_disconnect_signal(args.get("source_path"), args.get("signal_name"), args.get("target_path"), args.get("method_name"))
			return true
		"analyze_node_children":
			_analyze_node_children(args.get("node_path"), args.get("max_depth", 5))
			return true
	return false

# --- Utility ---

func _save_scene():
	var current_scene = EditorInterface.get_edited_scene_root()
	if not current_scene or current_scene.scene_file_path.is_empty():
		return
	var err = EditorInterface.save_scene()
	if err != OK:
		print("GamedevAI: Auto-save failed with code " + str(err))

func _get_scene_tree_brief(root: Node) -> String:
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

func _suggest_class_name(invalid_name: String) -> String:
	var all_classes = ClassDB.get_class_list()
	var best_match = ""
	var best_score = 0
	var invalid_lower = invalid_name.to_lower()
	for cls in all_classes:
		var cls_lower = cls.to_lower()
		if cls_lower.contains(invalid_lower) or invalid_lower.contains(cls_lower):
			if best_match == "" or abs(cls.length() - invalid_name.length()) < abs(best_match.length() - invalid_name.length()):
				best_match = cls
				best_score = 100
		elif best_score < 50:
			var score = 0
			var j = 0
			for i in range(cls_lower.length()):
				if j < invalid_lower.length() and cls_lower[i] == invalid_lower[j]:
					score += 1
					j += 1
			var threshold = invalid_lower.length() * 0.6
			if score > threshold and score > best_score:
				best_score = score
				best_match = cls
	return best_match

func _get_property_type(node: Object, property: String) -> int:
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
			if expected_type == TYPE_COLOR:
				return Color(value[0], value[1], value[2])
			if expected_type == TYPE_VECTOR3:
				return Vector3(value[0], value[1], value[2])
			return Vector3(value[0], value[1], value[2])
		if value.size() == 4:
			if expected_type == TYPE_QUATERNION:
				return Quaternion(value[0], value[1], value[2], value[3])
			if expected_type == TYPE_VECTOR4:
				return Vector4(value[0], value[1], value[2], value[3])
			return Color(value[0], value[1], value[2], value[3])
	return value

func _find_scene_file_by_name(dir_path: String, target_name: String) -> String:
	var target_lower = target_name.to_lower() + ".tscn"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var dirs_to_search = []
		while file_name != "":
			if dir.current_is_dir():
				if not file_name.begins_with("."):
					dirs_to_search.append(dir_path.path_join(file_name))
			else:
				if file_name.ends_with(".tscn") and file_name.to_lower() == target_lower:
					return dir_path.path_join(file_name)
			file_name = dir.get_next()
		
		for sub_dir in dirs_to_search:
			var result = _find_scene_file_by_name(sub_dir, target_name)
			if result != "":
				return result
	return ""

func _ensure_node(path: String) -> Node:
	var root = EditorInterface.get_edited_scene_root()
		
	if root:
		if path == "." or path == "":
			return root
		
		# Tentativa 1: Caminho exato.
		var node = root.get_node_or_null(path)
		if node:
			return node
			
		# Tentativa 2: Busca recursiva pelo nome do nó em toda a árvore (Fallback inteligente)
		var node_name = path.get_file()
		if node_name != "":
			node = root.find_child(node_name, true, false)
			if node:
				return node
			
	# Tentativa 3: Procura a cena no diretório res:// e a abre automaticamente!
	var target_name = path.get_file()
	if target_name != "":
		var scene_path = _find_scene_file_by_name("res://", target_name)
		if scene_path != "":
			_emit_output("Auto-opening scene: " + scene_path + " mapped to " + target_name)
			EditorInterface.open_scene_from_path(scene_path)
			
			# Atualiza o root após o Godot abrir a cena
			root = EditorInterface.get_edited_scene_root()
			if root:
				if root.name.to_lower() == target_name.to_lower() or path == ".":
					return root
				
				# Tenta achar o nó dentro da nova cena recém-aberta
				var node = root.get_node_or_null(path)
				if node: return node
				
				node = root.find_child(target_name, true, false)
				if node: return node
			
	return null

# --- Action Implementations ---

func _add_node(parent_path: String, type: String, name: String, script_path: String = ""):
	var parent = _ensure_node(parent_path)
	if not parent:
		_emit_output("Error: Parent node not found: " + parent_path)
		return
		
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		return

	var ur = _get_undo_redo()
	if ur:
		var node = ClassDB.instantiate(type)
		if not node:
			var suggestion = _suggest_class_name(type)
			var msg = "Error: Invalid node type '" + type + "'."
			if suggestion != "":
				msg += " Did you mean '" + suggestion + "'?"
			msg += " Use get_class_info to check available classes."
			_emit_output(msg)
			return
			 
		node.name = name
		var script = null
		var add_msg := ""
		if script_path != "":
			if FileAccess.file_exists(script_path):
				script = load(script_path)
			else:
				add_msg = " | Warning: Script not found at " + script_path
		
		if not _is_composite():
			ur.create_action("Add Node " + name, UndoRedo.MERGE_DISABLE, executor)
			
		ur.add_do_method(executor, "_proxy_add_child", parent, node)
		ur.add_do_method(executor, "_proxy_set_property", node, "owner", root)
		if script:
			ur.add_do_method(executor, "_proxy_set_script", node, script)
		ur.add_do_reference(node)
		ur.add_undo_method(executor, "_proxy_remove_child", parent, node)
		
		if _is_composite():
			executor._proxy_add_child(parent, node)
			executor._proxy_set_property(node, "owner", root)
			if script:
				executor._proxy_set_script(node, script)
		
		var msg = "Success: Node " + name + " (" + type + ") added to " + parent.name
		if script:
			msg += " with script " + script_path
			
		if not _is_composite():
			ur.commit_action()
			_save_scene()
			_emit_output(msg + add_msg)
		else:
			_emit_output(msg + " (Queued)" + add_msg)
	else:
		_emit_output("Error: UndoRedoManager not available.")

func _instance_scene(parent_path: String, scene_path: String, name: String):
	var parent = _ensure_node(parent_path)
	if not parent:
		_emit_output("Error: Parent node not found: " + parent_path)
		return
		
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		return
		
	if not FileAccess.file_exists(scene_path):
		_emit_output("Error: Scene file not found: " + scene_path)
		return
		
	var scene = load(scene_path)
	if not scene or not scene is PackedScene:
		_emit_output("Error: Failed to load scene or invalid scene format: " + scene_path)
		return
		
	var ur = _get_undo_redo()
	if ur:
		var instance = scene.instantiate()
		instance.name = name
		
		if not _is_composite():
			ur.create_action("Instance Scene " + name, UndoRedo.MERGE_DISABLE, executor)
		
		ur.add_do_method(executor, "_proxy_add_child", parent, instance)
		ur.add_do_method(executor, "_proxy_set_property", instance, "owner", root)
		ur.add_do_reference(instance)
		ur.add_undo_method(executor, "_proxy_remove_child", parent, instance)
		
		if _is_composite():
			executor._proxy_add_child(parent, instance)
			executor._proxy_set_property(instance, "owner", root)
		
		if not _is_composite():
			ur.commit_action()
			_save_scene()
			_emit_output("Success: Scene " + scene_path + " instanced as " + name + " under " + parent.name)
		else:
			_emit_output("Success: Scene instance queued: " + name)
	else:
		var instance = scene.instantiate()
		instance.name = name
		parent.add_child(instance)
		instance.owner = root
		_save_scene()
		_emit_output("Success: Scene " + scene_path + " instanced as " + name + " under " + parent.name + " (No Undo)")

func _set_property(node_path: String, property: String, value: Variant):
	var node = _ensure_node(node_path)
	if not node:
		_emit_output("Error: Node not found: '" + node_path + "'")
		return
		
	var root = EditorInterface.get_edited_scene_root()
		
	var expected_type := _get_property_type(node, property)
	var final_value = _parse_value(value, expected_type)
	
	var ur = _get_undo_redo()
	if ur:
		if not _is_composite():
			ur.create_action("Set Property " + property + " on " + node.name, UndoRedo.MERGE_DISABLE, executor)
			
		ur.add_do_method(executor, "_proxy_set_property", node, property, final_value)
		ur.add_undo_method(executor, "_proxy_set_property", node, property, node.get(property))
		
		if not _is_composite():
			ur.commit_action()
			_save_scene()
			_emit_output("Success: Set " + property + " to " + str(final_value) + " on " + node_path)
		else:
			_emit_output("Success: Set property queued: " + property + " on " + node_path)
	else:
		node.set(property, final_value)
		_save_scene()
		_emit_output("Success: Set " + property + " to " + str(final_value) + " on " + node_path + " (No Undo)")

func _set_theme_override(node_path: String, override_type: String, name: String, value: Variant):
	var node = _ensure_node(node_path)
	if not node or not node is Control:
		_emit_output("Error: Node not found or not a Control node: " + node_path)
		return
		
	var root = EditorInterface.get_edited_scene_root()

	var final_value = _parse_value(value)
	var ur = _get_undo_redo()
	
	if ur:
		if not _is_composite():
			ur.create_action("Set Theme Override " + name + " on " + node.name, UndoRedo.MERGE_DISABLE, executor)
			
		match override_type:
			"color": ur.add_do_method(executor, "_proxy_call", node, "add_theme_color_override", name, final_value)
			"constant": ur.add_do_method(executor, "_proxy_call", node, "add_theme_constant_override", name, int(final_value))
			"font_size": ur.add_do_method(executor, "_proxy_call", node, "add_theme_font_size_override", name, int(final_value))
			"font": ur.add_do_method(executor, "_proxy_call", node, "add_theme_font_override", name, final_value)
			"stylebox": ur.add_do_method(executor, "_proxy_call", node, "add_theme_stylebox_override", name, final_value)
		
		if not _is_composite():
			ur.commit_action()
			_save_scene()
			_emit_output("Success: Set theme override " + name + " on " + node_path)
		else:
			_emit_output("Success: Set theme override queued: " + name)
	else:
		match override_type:
			"color": node.add_theme_color_override(name, final_value)
			"constant": node.add_theme_constant_override(name, int(final_value))
			"font_size": node.add_theme_font_size_override(name, int(final_value))
			"font": node.add_theme_font_override(name, final_value)
			"stylebox": node.add_theme_stylebox_override(name, final_value)
		_save_scene()
		_emit_output("Success: Set theme override " + name + " on " + node_path)

func _connect_signal(source_path: String, signal_name: String, target_path: String, method_name: String, binds: Array = [], flags: int = 0):
	var source = _ensure_node(source_path)
	var target = _ensure_node(target_path)
	var root = EditorInterface.get_edited_scene_root()
	
	if not source:
		_emit_output("Error: Source node not found: " + source_path)
		return
	if not target:
		_emit_output("Error: Target node not found: " + target_path)
		return
		
	var callable = Callable(target, method_name)
	if not callable:
		_emit_output("Error: Invalid callable " + method_name + " on " + target.name)
		return

	if source.is_connected(signal_name, callable):
		_emit_output("Warning: Signal already connected.")
		return

	var ur = _get_undo_redo()
	if ur:
		if not _is_composite():
			ur.create_action("Connect Signal " + signal_name, UndoRedo.MERGE_DISABLE, executor)
			
		ur.add_do_method(executor, "_proxy_connect", source, signal_name, callable, flags)
		ur.add_undo_method(executor, "_proxy_disconnect", source, signal_name, callable)
		
		if not _is_composite():
			ur.commit_action()
			_save_scene()
			_emit_output("Success: Connected " + signal_name + " to " + method_name)
		else:
			_emit_output("Success: Connection queued.")
	else:
		source.connect(signal_name, callable, flags)
		_save_scene()
		_emit_output("Success: Connected " + signal_name + " (No Undo)")

func _disconnect_signal(source_path: String, signal_name: String, target_path: String, method_name: String):
	var source = _ensure_node(source_path)
	var target = _ensure_node(target_path)
	var root = EditorInterface.get_edited_scene_root()
	
	if not source or not target:
		_emit_output("Error: Node not found.")
		return
		
	var callable = Callable(target, method_name)
	if not source.is_connected(signal_name, callable):
		_emit_output("Error: Connection not found.")
		return

	var ur = _get_undo_redo()
	if ur:
		if not _is_composite():
			ur.create_action("Disconnect Signal " + signal_name, UndoRedo.MERGE_DISABLE, executor)
			
		ur.add_do_method(executor, "_proxy_disconnect", source, signal_name, callable)
		ur.add_undo_method(executor, "_proxy_connect", source, signal_name, callable) 
		
		if not _is_composite():
			ur.commit_action()
			_save_scene()
			_emit_output("Success: Disconnected " + signal_name)
		else:
			_emit_output("Success: Disconnection queued.")
	else:
		source.disconnect(signal_name, callable)
		_save_scene()
		_emit_output("Success: Disconnected " + signal_name + " (No Undo)")

func _remove_node(node_path: String):
	var node = _ensure_node(node_path)
	if not node:
		_emit_output("Error: Node not found at path: '" + node_path + "'")
		return
		
	var root = EditorInterface.get_edited_scene_root()
		
	if node == root:
		_emit_output("Error: Cannot remove the scene root node via this tool.")
		return
		
	if _get_undo_redo():
		if not _is_composite():
			_get_undo_redo().create_action("Remove Node " + node.name, UndoRedo.MERGE_DISABLE, executor)
			
		_get_undo_redo().add_do_method(executor, "_proxy_remove_child", node.get_parent(), node)
		_get_undo_redo().add_undo_method(executor, "_proxy_add_child", node.get_parent(), node)
		_get_undo_redo().add_undo_method(executor, "_proxy_set_property", node, "owner", root)
		
		if not _is_composite():
			_get_undo_redo().commit_action()
			_save_scene()
			_emit_output("Success: Node " + node_path + " removed.")
		else:
			_emit_output("Success: Node removal queued: " + node_path)
	else:
		node.get_parent().remove_child(node)
		node.queue_free()
		_save_scene()
		_emit_output("Success: Node " + node_path + " removed (No Undo).")



func _analyze_node_children(node_path: String, max_depth: int = 5):
	var node = _ensure_node(node_path)
	if not node:
		_emit_output("Error: Node not found: '" + node_path + "'")
		return
		
	var dump = "Analysis of '" + node.name + "' tree (Max Depth: " + str(max_depth) + "):\n"
	dump += _node_to_string_detailed(node, 0, max_depth)
	_emit_output(dump)

func _node_to_string_detailed(node: Node, current_depth: int, max_depth: int) -> String:
	if current_depth > max_depth:
		return "  ".repeat(current_depth) + "... (max depth reached, " + str(node.get_child_count()) + " children hidden)\n"
		
	var s = "  ".repeat(current_depth)
	s += node.name + " (" + node.get_class() + ")"
	
	var extras: Array = []
	if node.get_script(): extras.append("script:" + node.get_script().resource_path.get_file())
	if "position" in node: extras.append("pos:" + str(node.get("position")))
	if node is Control: extras.append("size:" + str(node.size))
	if node is CanvasItem and not node.visible: extras.append("hidden")
	if "text" in node and node.get("text") != null and str(node.get("text")) != "": 
		var text = str(node.get("text"))
		if text.length() > 15: text = text.substr(0, 15) + "..."
		extras.append("text:'" + text.replace("\n", " ").replace("\r", "") + "'")
	
	if not extras.is_empty():
		s += " [" + ", ".join(extras) + "]"
	s += "\n"
	
	for child in node.get_children():
		s += _node_to_string_detailed(child, current_depth + 1, max_depth)
	return s
