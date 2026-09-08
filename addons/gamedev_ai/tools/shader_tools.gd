@tool
extends BaseToolHandler
class_name ShaderTools

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"generate_shader":
			_generate_shader(
				args.get("preset", "hit_flash"),
				args.get("path", ""),
				args.get("custom_code", ""),
				args.get("uniforms", {})
			)
			return true
		"apply_shader_to_node":
			_apply_shader_to_node(
				args.get("node_path", ""),
				args.get("shader_path", ""),
				args.get("preset", ""),
				args.get("uniforms", {})
			)
			return true
		"get_shader_presets_list":
			_get_shader_presets_list()
			return true
	return false

func _generate_shader(preset_or_desc: String, path: String = "", custom_code: String = "", custom_uniforms: Dictionary = {}):
	var ShaderPresetsScript = load("res://addons/gamedev_ai/shaders/shader_presets.gd")
	var ShaderWriterScript = load("res://addons/gamedev_ai/shaders/shader_writer.gd")
	var UniformParserScript = load("res://addons/gamedev_ai/shaders/uniform_parser.gd")
	
	var code = custom_code
	var preset_name = ""
	var uniforms = custom_uniforms.duplicate()
	
	if code.strip_edges() == "":
		preset_name = ShaderPresetsScript.resolve_preset(preset_or_desc)
		var p_data = ShaderPresetsScript.get_preset(preset_name)
		if p_data.is_empty():
			_emit_output("[color=red]Error: Shader preset '" + preset_or_desc + "' not found.[/color]")
			return
		code = p_data.get("code", "")
		var def_uniforms = p_data.get("default_uniforms", {})
		for k in def_uniforms:
			if not uniforms.has(k):
				uniforms[k] = def_uniforms[k]
	else:
		preset_name = "custom"
		
	# Determine target path
	var target_path = path.strip_edges()
	if target_path == "":
		var timestamp = str(Time.get_unix_time_from_system()).split(".")[0]
		target_path = "res://shaders/" + preset_name + "_" + timestamp + ".gdshader"
	elif not target_path.begins_with("res://"):
		target_path = "res://" + target_path
	if not target_path.ends_with(".gdshader"):
		target_path += ".gdshader"
		
	var write_res = ShaderWriterScript.save_shader_and_material(target_path, code, uniforms)
	if write_res.get("success", false):
		var parsed = UniformParserScript.parse_shader_code(code)
		var msg = "✨ [b]Visual Shader & Material Generated Successfully![/b]\n"
		msg += "• [b]Preset/Name:[/b] " + preset_name.capitalize() + "\n"
		msg += "• [b]Shader File:[/b] `" + write_res.get("shader_path", "") + "`\n"
		msg += "• [b]Material (.tres):[/b] `" + write_res.get("material_path", "") + "`\n"
		msg += "• [b]Uniforms Detected (" + str(parsed.size()) + "):[/b]\n"
		for u in parsed:
			var u_name = u.get("name", "")
			var u_type = u.get("type", "")
			var u_hint = u.get("hint", "")
			msg += "  - `" + u_name + "` (" + u_type + (", " + u_hint if u_hint != "" else "") + ")\n"
		msg += "\n[i]The shader and companion ShaderMaterial are saved and ready to attach to nodes via `apply_shader_to_node` or the Inspector.[/i]"
		_emit_output(msg)
	else:
		_emit_output("[color=red]Error creating shader: " + write_res.get("error", "Unknown error") + "[/color]")

func _apply_shader_to_node(node_path: String, shader_path: String = "", preset: String = "", uniforms: Dictionary = {}):
	if not Engine.is_editor_hint():
		_emit_output("Error: apply_shader_to_node only works within the Godot Editor.")
		return
		
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		_emit_output("Error: No active scene open in the editor.")
		return
		
	var target_node: Node = null
	if node_path.strip_edges() == "" or node_path == ".":
		var selection = EditorInterface.get_selection().get_selected_nodes()
		if not selection.is_empty():
			target_node = selection[0]
		else:
			target_node = root
	else:
		target_node = root.get_node_or_null(node_path)
		
	if not target_node:
		_emit_output("Error: Target node '" + node_path + "' not found in current scene.")
		return
		
	# Obtain ShaderMaterial
	var mat: ShaderMaterial = null
	if shader_path != "":
		var clean_p = shader_path.strip_edges()
		if not clean_p.begins_with("res://"):
			clean_p = "res://" + clean_p
		if clean_p.ends_with(".tres"):
			mat = load(clean_p) as ShaderMaterial
		elif clean_p.ends_with(".gdshader"):
			var sh = load(clean_p) as Shader
			if sh:
				mat = ShaderMaterial.new()
				mat.shader = sh
	elif preset != "":
		var ShaderSynthesizerScript = load("res://addons/gamedev_ai/shaders/shader_synthesizer.gd")
		var syn = ShaderSynthesizerScript.synthesize_from_preset(preset, uniforms)
		mat = syn.get("material")
		
	if not mat:
		_emit_output("Error: Could not load or synthesize ShaderMaterial from specified arguments.")
		return
		
	# Apply uniforms overrides
	for k in uniforms:
		mat.set_shader_parameter(k, uniforms[k])
		
	var ur = _get_undo_redo()
	var action_name = "Apply Shader Material to " + target_node.name
	
	if target_node is CanvasItem:
		var old_mat = target_node.material
		if ur:
			if not _is_composite():
				ur.create_action(action_name, UndoRedo.MERGE_DISABLE, root)
			ur.add_do_property(target_node, "material", mat)
			ur.add_undo_property(target_node, "material", old_mat)
			if not _is_composite():
				ur.commit_action()
		else:
			target_node.material = mat
		_emit_output("✅ Shader Material applied to CanvasItem node [b]" + target_node.name + "[/b] (`" + str(target_node.get_path()) + "`).")
	elif target_node is GeometryInstance3D:
		var old_mat = target_node.material_override
		if ur:
			if not _is_composite():
				ur.create_action(action_name, UndoRedo.MERGE_DISABLE, root)
			ur.add_do_property(target_node, "material_override", mat)
			ur.add_undo_property(target_node, "material_override", old_mat)
			if not _is_composite():
				ur.commit_action()
		else:
			target_node.material_override = mat
		_emit_output("✅ Shader Material applied to 3D Geometry node [b]" + target_node.name + "[/b] (`" + str(target_node.get_path()) + "`).")
	else:
		# Generic fallback property attempt
		if "material" in target_node:
			target_node.material = mat
			_emit_output("✅ Shader Material set on node [b]" + target_node.name + "[/b].")
		else:
			_emit_output("[color=yellow]Warning: Node '" + target_node.name + "' (" + target_node.get_class() + ") does not standardly accept a CanvasItem or Geometry3D Material.[/color]")

func _get_shader_presets_list():
	var ShaderPresetsScript = load("res://addons/gamedev_ai/shaders/shader_presets.gd")
	var msg = "🎨 [b]Available Shader Presets & Categories:[/b]\n\n"
	for cat in ShaderPresetsScript.CATEGORIES:
		msg += "[b]" + cat + ":[/b]\n"
		for p_name in ShaderPresetsScript.CATEGORIES[cat]:
			var data = ShaderPresetsScript.get_preset(p_name)
			var title = data.get("name", p_name)
			var desc = data.get("description", "")
			var p_type = data.get("type", "")
			msg += "• [b]" + p_name + "[/b] (" + p_type + ") - " + title + ": " + desc + "\n"
		msg += "\n"
	msg += "[i]Use `generate_shader(preset: 'name')` to synthesize any of these shaders.[/i]"
	_emit_output(msg)
