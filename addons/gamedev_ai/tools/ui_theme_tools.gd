@tool
extends "res://addons/gamedev_ai/tools/base_tool_handler.gd"

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"generate_ui_theme":
			_generate_ui_theme(
				String(args.get("preset_or_name", "glassmorphism")),
				String(args.get("save_path", "")),
				args.get("colors", {}),
				args.get("metrics", {}),
				bool(args.get("set_as_project_theme", true))
			)
			return true
		"create_responsive_ui_component":
			_create_responsive_ui_component(
				String(args.get("component_type", "hud")),
				String(args.get("save_path", "")),
				String(args.get("theme_path", "")),
				String(args.get("parent_node_path", ""))
			)
			return true
		"apply_theme_to_scene":
			_apply_theme_to_scene(
				String(args.get("theme_path", "")),
				String(args.get("node_path", "."))
			)
			return true
		"inspect_theme":
			_inspect_theme(String(args.get("theme_path", "")))
			return true
	return false

# ==============================================================================
# --- Tool Implementations ---
# ==============================================================================

func _generate_ui_theme(preset_name: String, save_path: String, custom_colors: Dictionary, custom_metrics: Dictionary, set_global: bool):
	var ThemeBuilderScript = load("res://addons/gamedev_ai/ui_studio/theme_builder.gd")
	if not ThemeBuilderScript:
		_emit_output("[color=red]Error: Could not load ThemeBuilder module.[/color]")
		return

	var theme_res = ThemeBuilderScript.build_theme(preset_name, custom_colors, custom_metrics)
	if not theme_res:
		_emit_output("[color=red]Error: Failed to generate Theme resource.[/color]")
		return

	# Determine Target Path
	var target_path = save_path.strip_edges()
	if target_path == "":
		target_path = "res://themes/theme_" + preset_name.to_lower() + ".tres"
	elif not target_path.begins_with("res://"):
		target_path = "res://" + target_path
	if not target_path.ends_with(".tres"):
		target_path += ".tres"

	var dir_path = target_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var err = ResourceSaver.save(theme_res, target_path)
	if err != OK:
		_emit_output("[color=red]Error saving Theme resource to '" + target_path + "'. Code: " + str(err) + "[/color]")
		return

	_scan_fs()

	var msg = "🎨 [b]UI Theme Generated Successfully![/b]\n"
	msg += "• [b]Preset / Name:[/b] `" + preset_name + "`\n"
	msg += "• [b]Saved Path:[/b] `" + target_path + "`\n"

	# Apply as Global Project Theme if requested
	if set_global:
		ProjectSettings.set_setting("gui/theme/custom", target_path)
		var p_err = ProjectSettings.save()
		if p_err == OK:
			msg += "• [b]Global Project Theme:[/b] ✅ Registered as default in `ProjectSettings.gui/theme/custom`.\n"
		else:
			msg += "• [b]Global Project Theme:[/b] ⚠️ Warning: Failed to save ProjectSettings (Code " + str(p_err) + ").\n"

	msg += "[i]All buttons, panels, progress bars, and line edits will now use these styles.[/i]"
	_emit_output(msg)

func _create_responsive_ui_component(comp_type: String, save_path: String, theme_path: String, parent_node_path: String):
	var ComponentTemplatesScript = load("res://addons/gamedev_ai/ui_studio/component_templates.gd")
	if not ComponentTemplatesScript:
		_emit_output("[color=red]Error: Could not load ComponentTemplates module.[/color]")
		return

	var theme_res: Theme = null
	if theme_path != "" and ResourceLoader.exists(theme_path):
		theme_res = load(theme_path) as Theme
	elif ProjectSettings.has_setting("gui/theme/custom"):
		var global_theme_path = ProjectSettings.get_setting("gui/theme/custom")
		if global_theme_path != "" and ResourceLoader.exists(global_theme_path):
			theme_res = load(global_theme_path) as Theme

	var comp_root = ComponentTemplatesScript.build_component(comp_type, theme_res)
	if not comp_root:
		_emit_output("[color=red]Error building component template for '" + comp_type + "'.[/color]")
		return

	# If instantiating into active scene
	if parent_node_path != "":
		var target_parent = _resolve_node(parent_node_path)
		if target_parent:
			target_parent.add_child(comp_root)
			comp_root.owner = _get_scene_root()
			_save_scene_changes()
			_emit_output("📦 [b]Responsive Component Instantiated into Scene:[/b] `" + comp_root.name + "` under `" + target_parent.name + "`.")
			return

	# Otherwise save as PackedScene file
	var target_path = save_path.strip_edges()
	if target_path == "":
		target_path = "res://ui/" + comp_type.to_lower() + ".tscn"
	elif not target_path.begins_with("res://"):
		target_path = "res://" + target_path
	if not target_path.ends_with(".tscn"):
		target_path += ".tscn"

	var dir_path = target_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var packed_scene = PackedScene.new()
	var pack_err = packed_scene.pack(comp_root)
	if pack_err == OK:
		var s_err = ResourceSaver.save(packed_scene, target_path)
		if s_err == OK:
			_scan_fs()
			var msg = "📦 [b]Responsive UI Component Scene Created![/b]\n"
			msg += "• [b]Type:[/b] `" + comp_type + "`\n"
			msg += "• [b]Path:[/b] `" + target_path + "`\n"
			msg += "[i]You can now instantiate this scene or open it in the 2D editor.[/i]"
			_emit_output(msg)
		else:
			_emit_output("[color=red]Error saving scene to " + target_path + ". Code: " + str(s_err) + "[/color]")
	else:
		_emit_output("[color=red]Error packing UI component scene. Code: " + str(pack_err) + "[/color]")

	comp_root.free()

func _apply_theme_to_scene(theme_path: String, node_path: String):
	if not ResourceLoader.exists(theme_path):
		_emit_output("[color=red]Error: Theme file not found at '" + theme_path + "'.[/color]")
		return

	var theme_res = load(theme_path)
	if not theme_res is Theme:
		_emit_output("[color=red]Error: Resource at '" + theme_path + "' is not a Theme.[/color]")
		return

	var target_node = _resolve_node(node_path)
	if not target_node or not target_node is Control:
		_emit_output("[color=red]Error: Target node at '" + node_path + "' is not a valid Control node.[/color]")
		return

	target_node.theme = theme_res
	_save_scene_changes()

	var msg = "🎨 [b]Theme Applied Successfully![/b]\n"
	msg += "• [b]Theme:[/b] `" + theme_path + "`\n"
	msg += "• [b]Applied to Node:[/b] `" + target_node.name + "`"
	_emit_output(msg)

func _inspect_theme(theme_path: String):
	var target_path = theme_path.strip_edges()
	if target_path == "":
		if ProjectSettings.has_setting("gui/theme/custom"):
			target_path = ProjectSettings.get_setting("gui/theme/custom")

	if target_path == "" or not ResourceLoader.exists(target_path):
		_emit_output("[color=red]Error: No valid Theme file specified or found in ProjectSettings.[/color]")
		return

	var theme_res = load(target_path)
	if not theme_res is Theme:
		_emit_output("[color=red]Error: File at '" + target_path + "' is not a Theme resource.[/color]")
		return

	var report = "🎨 [b]Theme Inspection Report: '" + target_path + "'[/b]\n"
	var type_list = theme_res.get_type_list()
	report += "• [b]Styled Control Types (" + str(type_list.size()) + "):[/b] " + ", ".join(type_list) + "\n"
	_emit_output(report)

# ==============================================================================
# --- Helpers ---
# ==============================================================================

func _resolve_node(path_or_name: String) -> Node:
	var root = _get_scene_root()
	if not root:
		return null
	if path_or_name == "." or path_or_name == "":
		return root
	if root.has_node(path_or_name):
		return root.get_node(path_or_name)
	return root.find_child(path_or_name, true, false)

func _get_scene_root() -> Node:
	if Engine.is_editor_hint():
		return EditorInterface.get_edited_scene_root()
	if executor and "_test_scene_root" in executor and executor._test_scene_root:
		return executor._test_scene_root
	return null

func _save_scene_changes():
	if Engine.is_editor_hint():
		var root = EditorInterface.get_edited_scene_root()
		if root and not root.scene_file_path.is_empty():
			EditorInterface.save_scene()

func _scan_fs():
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
