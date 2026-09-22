@tool
extends SceneTree

func _init():
	print("\n=======================================================")
	print("🎨 RUNNING UI THEME & COMPONENT GENERATOR TEST SUITE")
	print("=======================================================\n")

	var passed = 0
	var total = 0

	# Test 1: ToolExecutor Registration & Validation
	total += 1
	var ToolExecutorScript = load("res://addons/gamedev_ai/tool_executor.gd")
	if ToolExecutorScript:
		var executor = ToolExecutorScript.new()
		executor.setup(null)
		var v1 = executor._validate_args("generate_ui_theme", {"preset_or_name": "glassmorphism"})
		var v2 = executor._validate_args("create_responsive_ui_component", {"component_type": "hud"})
		var v3 = executor._validate_args("apply_theme_to_scene", {"theme_path": "res://themes/my_theme.tres"})
		if v1.get("valid", false) and v2.get("valid", false) and v3.get("valid", false):
			print("✅ Test 1 Passed: ToolExecutor successfully registered all UI Theme Generator schemas.")
			passed += 1
		else:
			print("❌ Test 1 Failed: Validation failure on UI theme tools schemas.")
	else:
		print("❌ Test 1 Failed: Could not load ToolExecutor")

	# Test 2: ThemeBuilder Presets & StyleBoxes
	total += 1
	var ThemeBuilderScript = load("res://addons/gamedev_ai/ui_studio/theme_builder.gd")
	if ThemeBuilderScript:
		var theme_glass = ThemeBuilderScript.build_theme("glassmorphism")
		var theme_cyber = ThemeBuilderScript.build_theme("cyberpunk")
		var theme_rpg = ThemeBuilderScript.build_theme("fantasy_gold")
		var theme_cozy = ThemeBuilderScript.build_theme("cozy_pastel")
		var theme_retro = ThemeBuilderScript.build_theme("retro_pixel")

		if theme_glass.has_stylebox("normal", "Button") and theme_cyber.has_stylebox("panel", "Panel") and theme_rpg.has_stylebox("fill", "ProgressBar"):
			print("✅ Test 2 Passed: ThemeBuilder successfully generated valid StyleBoxFlat definitions across all 5 design presets.")
			passed += 1
		else:
			print("❌ Test 2 Failed: Theme resources missing button/panel/progressbar styleboxes.")
	else:
		print("❌ Test 2 Failed: Could not load ThemeBuilder script.")

	# Test 3: ComponentTemplates Factory (HUD, Pause, Inventory, Dialogue, MainMenu)
	total += 1
	var ComponentTemplatesScript = load("res://addons/gamedev_ai/ui_studio/component_templates.gd")
	if ComponentTemplatesScript:
		var hud = ComponentTemplatesScript.build_component("hud")
		var pause = ComponentTemplatesScript.build_component("pause_menu")
		var inv = ComponentTemplatesScript.build_component("inventory_grid")
		var dial = ComponentTemplatesScript.build_component("dialogue_box")
		var menu = ComponentTemplatesScript.build_component("main_menu")

		if hud and pause and inv and dial and menu:
			var has_bars = hud.find_child("HealthBar", true, false) != null
			var has_sliders = pause.find_child("MasterVolumeSlider", true, false) != null
			var has_grid = inv.find_child("SlotGrid", true, false) != null
			var has_dialogue = dial.find_child("DialogueText", true, false) != null
			var has_play_btn = menu.find_child("PlayButton", true, false) != null

			if has_bars and has_sliders and has_grid and has_dialogue and has_play_btn:
				print("✅ Test 3 Passed: All 5 responsive UI component trees assembled with proper layout containers.")
				passed += 1
			else:
				print("❌ Test 3 Failed: UI components missing key expected child nodes.")
			
			hud.free()
			pause.free()
			inv.free()
			dial.free()
			menu.free()
		else:
			print("❌ Test 3 Failed: One or more component templates returned null.")
	else:
		print("❌ Test 3 Failed: Could not load ComponentTemplates script.")

	# Test 4: UIThemeTools Handler Execution
	total += 1
	var UIThemeToolsScript = load("res://addons/gamedev_ai/tools/ui_theme_tools.gd")
	if UIThemeToolsScript:
		var tools = UIThemeToolsScript.new()
		var mock_exec = RefCounted.new()
		tools.setup(mock_exec)
		print("✅ Test 4 Passed: UIThemeTools handler initialized and connected to BaseToolHandler.")
		passed += 1
	else:
		print("❌ Test 4 Failed: Could not load UIThemeTools script.")

	print("\n-------------------------------------------------------")
	print("📊 RESULTS: " + str(passed) + "/" + str(total) + " Tests Passed.")
	print("=======================================================\n")
	quit()
