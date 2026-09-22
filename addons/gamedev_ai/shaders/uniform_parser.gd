@tool
extends RefCounted

# Struct / Dictionary representation of a parsed Uniform:
# {
#   "name": "dissolve_amount",
#   "type": "float", # "float", "int", "bool", "vec2", "vec3", "vec4", "sampler2D", "Color"
#   "hint": "hint_range", # or "source_color", "hint_default_white", etc.
#   "hint_string": "0.0, 1.0, 0.01",
#   "hint_range": [0.0, 1.0, 0.01],
#   "default_value": 0.5,
#   "raw_line": "uniform float dissolve_amount : hint_range(0.0, 1.0, 0.01) = 0.5;"
# }

static func parse_shader_code(code: String) -> Array[Dictionary]:
	var uniforms: Array[Dictionary] = []
	var lines = code.split("\n")
	
	# Regex for uniform pattern:
	# uniform <type> <name> (: <hint>)? (= <default>)?;
	var regex = RegEx.new()
	# Pattern: uniform\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)(?:\s*:\s*([^;=]+))?(?:\s*=\s*([^;]+))?\s*;
	regex.compile("uniform\\s+([a-zA-Z0-9_]+)\\s+([a-zA-Z0-9_]+)(?:\\s*:\\s*([^;=]+))?(?:\\s*=\\s*([^;]+))?\\s*;")
	
	for line in lines:
		var trimmed = line.strip_edges()
		if trimmed.begins_with("//") or trimmed.begins_with("/*"):
			continue
		
		var match_result = regex.search(trimmed)
		if match_result:
			var type_str = match_result.get_string(1).strip_edges()
			var name_str = match_result.get_string(2).strip_edges()
			var hint_raw = match_result.get_string(3).strip_edges()
			var default_raw = match_result.get_string(4).strip_edges()
			
			var u_data = _create_uniform_data(type_str, name_str, hint_raw, default_raw, trimmed)
			uniforms.append(u_data)
			
	return uniforms

static func _create_uniform_data(type_str: String, name_str: String, hint_raw: String, default_raw: String, raw_line: String) -> Dictionary:
	var data: Dictionary = {
		"name": name_str,
		"type": type_str,
		"hint": "",
		"hint_string": "",
		"hint_range": [],
		"default_value": null,
		"raw_line": raw_line
	}
	
	# Parse hints
	if hint_raw != "":
		data["hint_string"] = hint_raw
		if "source_color" in hint_raw:
			data["hint"] = "source_color"
		elif "hint_range" in hint_raw:
			data["hint"] = "hint_range"
			var start = hint_raw.find("(")
			var end = hint_raw.rfind(")")
			if start != -1 and end != -1 and end > start:
				var params_str = hint_raw.substr(start + 1, end - start - 1)
				var parts = params_str.split(",")
				var range_vals: Array[float] = []
				for p in parts:
					range_vals.append(p.strip_edges().to_float())
				data["hint_range"] = range_vals
		else:
			data["hint"] = hint_raw
	
	# Parse default values based on type
	data["default_value"] = _parse_default_value(type_str, default_raw, data["hint"])
	return data

static func _parse_default_value(type_str: String, default_raw: String, hint: String) -> Variant:
	if default_raw == "":
		match type_str:
			"float": return 0.0
			"int": return 0
			"bool": return false
			"vec2": return Vector2.ZERO
			"vec3": return Vector3.ZERO
			"vec4": return Color(1, 1, 1, 1) if hint == "source_color" else Vector4.ZERO
			"sampler2D": return null
		return null
		
	var clean = default_raw.strip_edges()
	match type_str:
		"float":
			return clean.to_float()
		"int":
			return clean.to_int()
		"bool":
			return clean.to_lower() == "true"
		"vec2":
			# e.g. vec2(1.0, 2.0)
			return _parse_vector(clean, 2)
		"vec3":
			if hint == "source_color":
				var v = _parse_vector(clean, 3)
				return Color(v.x, v.y, v.z, 1.0)
			return _parse_vector(clean, 3)
		"vec4":
			if hint == "source_color" or clean.begins_with("vec4"):
				var v = _parse_vector4(clean)
				return Color(v.x, v.y, v.z, v.w)
			var v4 = _parse_vector4(clean)
			return v4
		"sampler2D":
			return null
	
	return clean

static func _parse_vector(raw: String, dimensions: int) -> Variant:
	var start = raw.find("(")
	var end = raw.rfind(")")
	if start != -1 and end != -1 and end > start:
		var inner = raw.substr(start + 1, end - start - 1)
		var parts = inner.split(",")
		var nums: Array[float] = []
		for p in parts:
			nums.append(p.strip_edges().to_float())
		if dimensions == 2:
			return Vector2(nums[0] if nums.size() > 0 else 0.0, nums[1] if nums.size() > 1 else 0.0)
		elif dimensions == 3:
			return Vector3(nums[0] if nums.size() > 0 else 0.0, nums[1] if nums.size() > 1 else 0.0, nums[2] if nums.size() > 2 else 0.0)
	return Vector2.ZERO if dimensions == 2 else Vector3.ZERO

static func _parse_vector4(raw: String) -> Vector4:
	var start = raw.find("(")
	var end = raw.rfind(")")
	if start != -1 and end != -1 and end > start:
		var inner = raw.substr(start + 1, end - start - 1)
		var parts = inner.split(",")
		var nums: Array[float] = []
		for p in parts:
			nums.append(p.strip_edges().to_float())
		return Vector4(
			nums[0] if nums.size() > 0 else 0.0,
			nums[1] if nums.size() > 1 else 0.0,
			nums[2] if nums.size() > 2 else 0.0,
			nums[3] if nums.size() > 3 else 1.0
		)
	return Vector4.ZERO
