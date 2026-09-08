@tool
extends RefCounted
class_name ShaderWriter

static func save_shader_and_material(shader_path: String, shader_code: String, custom_uniforms: Dictionary = {}) -> Dictionary:
	var result = {
		"success": false,
		"shader_path": "",
		"material_path": "",
		"error": ""
	}
	
	var clean_path = shader_path.strip_edges()
	if clean_path == "":
		var timestamp = str(Time.get_unix_time_from_system()).split(".")[0]
		clean_path = "res://shaders/shader_" + timestamp + ".gdshader"
	elif not clean_path.begins_with("res://"):
		clean_path = "res://" + clean_path
		
	if not clean_path.ends_with(".gdshader"):
		clean_path += ".gdshader"
		
	# 1. Ensure directory exists
	var dir_path = clean_path.get_base_dir()
	var da = DirAccess.open("res://")
	if da and not da.dir_exists(dir_path):
		var make_err = da.make_dir_recursive(dir_path)
		if make_err != OK:
			result["error"] = "Failed to create directory: " + dir_path
			return result
			
	# 2. Save .gdshader text file
	var file = FileAccess.open(clean_path, FileAccess.WRITE)
	if not file:
		result["error"] = "Failed to write shader file at " + clean_path + " (Error: " + str(FileAccess.get_open_error()) + ")"
		return result
		
	file.store_string(shader_code)
	file.close()
	result["shader_path"] = clean_path
	
	# 3. Create companion .tres ShaderMaterial
	var base_name = clean_path.get_basename()
	var mat_path = base_name + "_mat.tres"
	
	# Load the newly saved shader as a resource
	var shader_res = ResourceLoader.load(clean_path, "Shader", ResourceLoader.CACHE_MODE_REUSE)
	if not shader_res:
		# Fallback to direct memory resource
		shader_res = Shader.new()
		shader_res.code = shader_code
		
	var material = ShaderMaterial.new()
	material.shader = shader_res
	
	# Apply parsed default values first
	var UniformParserScript = load("res://addons/gamedev_ai/shaders/uniform_parser.gd")
	if UniformParserScript:
		var parsed = UniformParserScript.parse_shader_code(shader_code)
		for u in parsed:
			var u_name = u.get("name", "")
			var def_val = u.get("default_value")
			if def_val != null and u_name != "":
				material.set_shader_parameter(u_name, def_val)
				
	# Apply custom overrides
	for k in custom_uniforms:
		var val = custom_uniforms[k]
		if val is String and val.begins_with("#"):
			material.set_shader_parameter(k, Color.from_string(val, Color.WHITE))
		else:
			material.set_shader_parameter(k, val)
			
	var save_err = ResourceSaver.save(material, mat_path)
	if save_err == OK:
		result["material_path"] = mat_path
		result["success"] = true
	else:
		result["error"] = "Saved shader but failed to save material .tres (Code: " + str(save_err) + ")"
		return result
		
	# Notify Godot Editor FileSystem
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
		
	return result
