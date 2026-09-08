@tool
extends SceneTree

func _init():
	print("\n=======================================================")
	print("🎨 RUNNING SHADER & MATERIAL SYNTHESIZER TEST SUITE")
	print("=======================================================\n")
	
	var passed = 0
	var total = 0
	
	# Test 1: UniformParser
	total += 1
	var UniformParserScript = load("res://addons/gamedev_ai/shaders/uniform_parser.gd")
	if UniformParserScript:
		var test_code = """shader_type canvas_item;
uniform bool active = true;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float dissolve_amount : hint_range(0.0, 1.0, 0.01) = 0.35;
uniform vec2 scroll_speed = vec2(0.5, 0.0);
"""
		var parsed = UniformParserScript.parse_shader_code(test_code)
		if parsed.size() == 4:
			print("✅ Test 1 Passed: UniformParser correctly detected 4 uniforms with hints and types.")
			passed += 1
		else:
			print("❌ Test 1 Failed: Expected 4 uniforms, got " + str(parsed.size()))
	else:
		print("❌ Test 1 Failed: Could not load UniformParser")
		
	# Test 2: ShaderPresets
	total += 1
	var ShaderPresetsScript = load("res://addons/gamedev_ai/shaders/shader_presets.gd")
	if ShaderPresetsScript:
		var all_presets = ShaderPresetsScript.get_all_preset_names()
		var hit_flash = ShaderPresetsScript.get_preset("hit_flash")
		var toon_cel = ShaderPresetsScript.get_preset("toon_cel")
		if all_presets.size() >= 10 and not hit_flash.is_empty() and not toon_cel.is_empty():
			print("✅ Test 2 Passed: ShaderPresets loaded " + str(all_presets.size()) + " presets (2D & 3D).")
			passed += 1
		else:
			print("❌ Test 2 Failed: Preset catalog incomplete.")
	else:
		print("❌ Test 2 Failed: Could not load ShaderPresets")

	# Test 3: ShaderSynthesizer
	total += 1
	var ShaderSynthesizerScript = load("res://addons/gamedev_ai/shaders/shader_synthesizer.gd")
	if ShaderSynthesizerScript:
		var syn_res = ShaderSynthesizerScript.synthesize_from_preset("toon_cel")
		var mat = syn_res.get("material")
		if mat is ShaderMaterial and mat.shader != null:
			print("✅ Test 3 Passed: ShaderSynthesizer instantiated ShaderMaterial in memory successfully.")
			passed += 1
		else:
			print("❌ Test 3 Failed: ShaderSynthesizer did not produce valid ShaderMaterial.")
	else:
		print("❌ Test 3 Failed: Could not load ShaderSynthesizer")

	# Test 4: ShaderWriter
	total += 1
	var ShaderWriterScript = load("res://addons/gamedev_ai/shaders/shader_writer.gd")
	if ShaderWriterScript:
		var test_path = "user://test_synth_shader.gdshader"
		var test_code = "shader_type canvas_item;\nuniform float intensity : hint_range(0.0, 1.0) = 0.8;\nvoid fragment() { COLOR = vec4(1.0); }"
		var write_res = ShaderWriterScript.save_shader_and_material(test_path, test_code)
		if write_res.get("success", false) and FileAccess.file_exists(write_res.get("shader_path", "")) and FileAccess.file_exists(write_res.get("material_path", "")):
			print("✅ Test 4 Passed: ShaderWriter wrote .gdshader and .tres material files successfully.")
			passed += 1
		else:
			print("❌ Test 4 Failed: ShaderWriter failed to write files: " + write_res.get("error", ""))
	else:
		print("❌ Test 4 Failed: Could not load ShaderWriter")

	# Test 5: ToolExecutor Integration
	total += 1
	var ToolExecutorScript = load("res://addons/gamedev_ai/tool_executor.gd")
	if ToolExecutorScript:
		var executor = ToolExecutorScript.new()
		executor.setup(null)
		var val_res = executor._validate_args("generate_shader", {"preset": "hit_flash"})
		if val_res.get("valid", false):
			print("✅ Test 5 Passed: ToolExecutor registered generate_shader and validated arguments.")
			passed += 1
		else:
			print("❌ Test 5 Failed: ToolExecutor validation failed: " + val_res.get("error", ""))
	else:
		print("❌ Test 5 Failed: Could not load ToolExecutor")

	print("\n=======================================================")
	print("RESULTS: " + str(passed) + "/" + str(total) + " tests passed.")
	print("=======================================================\n")
	
	quit(0 if passed == total else 1)
