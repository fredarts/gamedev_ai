@tool
extends RefCounted
class_name ShaderSynthesizer

static func create_shader_material(shader_code: String, custom_uniforms: Dictionary = {}) -> ShaderMaterial:
	var UniformParserScript = load("res://addons/gamedev_ai/shaders/uniform_parser.gd")
	var shader = Shader.new()
	shader.code = shader_code
	
	var mat = ShaderMaterial.new()
	mat.shader = shader
	
	# Apply parsed default values first
	var parsed = UniformParserScript.parse_shader_code(shader_code)
	for u in parsed:
		var u_name = u.get("name", "")
		var def_val = u.get("default_value")
		if def_val != null and u_name != "":
			mat.set_shader_parameter(u_name, def_val)
			
	# Apply custom uniform overrides
	for k in custom_uniforms:
		var val = custom_uniforms[k]
		if val is String:
			# Convert string hex colors or floats if needed
			if val.begins_with("#"):
				mat.set_shader_parameter(k, Color.from_string(val, Color.WHITE))
			else:
				mat.set_shader_parameter(k, val)
		else:
			mat.set_shader_parameter(k, val)
			
	return mat

static func synthesize_from_preset(preset_or_query: String, custom_uniforms: Dictionary = {}) -> Dictionary:
	var ShaderPresetsScript = load("res://addons/gamedev_ai/shaders/shader_presets.gd")
	var preset_name = ShaderPresetsScript.resolve_preset(preset_or_query)
	var preset_data = ShaderPresetsScript.get_preset(preset_name)
	
	if preset_data.is_empty():
		return {}
		
	var code = preset_data.get("code", "")
	var uniforms = preset_data.get("default_uniforms", {}).duplicate()
	for k in custom_uniforms:
		uniforms[k] = custom_uniforms[k]
		
	var material = create_shader_material(code, uniforms)
	
	return {
		"preset_name": preset_name,
		"title": preset_data.get("name", preset_name.capitalize()),
		"type": preset_data.get("type", "canvas_item"),
		"description": preset_data.get("description", ""),
		"code": code,
		"uniforms": uniforms,
		"material": material
	}
