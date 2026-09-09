@tool
extends RefCounted
class_name DockShader

var _parent_control: Control
var _tool_executor: RefCounted

# UI Elements from Dock
var _category_selector: OptionButton
var _preset_selector: OptionButton
var _mode_selector: OptionButton
var _code_edit: TextEdit
var _uniforms_container: VBoxContainer
var _apply_to_selection_btn: Button
var _save_shader_btn: Button
var _recompile_btn: Button
var _randomize_btn: Button
var _status_label: RichTextLabel

# Live Preview Viewport Nodes
var _viewport_container: SubViewportContainer
var _sub_viewport: SubViewport
var _preview_2d_root: Node2D
var _preview_2d_sprite: Sprite2D
var _preview_3d_root: Node3D
var _preview_3d_mesh: MeshInstance3D
var _preview_3d_camera: Camera3D
var _preview_3d_light: DirectionalLight3D

var _current_preset: String = "hit_flash"
var _current_code: String = ""
var _current_material: ShaderMaterial
var _current_uniforms: Dictionary = {}
var _is_3d_mode: bool = false

signal shader_saved(shader_path: String, material_path: String)

func setup(parent: Control, tool_executor: RefCounted, nodes: Dictionary):
	_parent_control = parent
	_tool_executor = tool_executor
	
	_category_selector = nodes.get("shader_category_selector")
	_preset_selector = nodes.get("shader_preset_selector")
	_mode_selector = nodes.get("shader_mode_selector")
	_code_edit = nodes.get("shader_code_edit")
	_uniforms_container = nodes.get("shader_uniforms_container")
	_apply_to_selection_btn = nodes.get("shader_apply_btn")
	_save_shader_btn = nodes.get("shader_save_btn")
	_recompile_btn = nodes.get("shader_recompile_btn")
	_randomize_btn = nodes.get("shader_randomize_btn")
	_status_label = nodes.get("shader_status_label")
	_viewport_container = nodes.get("shader_viewport_container")
	
	_setup_viewport_preview()
	_populate_categories()
	
	if _category_selector:
		_category_selector.item_selected.connect(_on_category_selected)
	if _preset_selector:
		_preset_selector.item_selected.connect(_on_preset_selected)
	if _mode_selector:
		_mode_selector.item_selected.connect(_on_mode_selected)
	if _apply_to_selection_btn:
		_apply_to_selection_btn.pressed.connect(_on_apply_to_selection_pressed)
	if _save_shader_btn:
		_save_shader_btn.pressed.connect(_on_save_shader_pressed)
	if _recompile_btn:
		_recompile_btn.pressed.connect(_on_recompile_pressed)
	if _randomize_btn:
		_randomize_btn.pressed.connect(_on_randomize_pressed)
		
	# Load default preset
	load_preset("hit_flash")

func _setup_viewport_preview():
	if not _viewport_container:
		return
		
	_sub_viewport = SubViewport.new()
	_sub_viewport.size = Vector2i(256, 180)
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_sub_viewport.transparent_bg = false
	_viewport_container.add_child(_sub_viewport)
	
	# 2D Preview Setup
	_preview_2d_root = Node2D.new()
	_preview_2d_sprite = Sprite2D.new()
	var default_icon = _parent_control.get_theme_icon("Godot", "EditorIcons") if _parent_control else null
	if default_icon:
		_preview_2d_sprite.texture = default_icon
	_preview_2d_sprite.position = Vector2(128, 90)
	_preview_2d_sprite.scale = Vector2(3.5, 3.5)
	_preview_2d_root.add_child(_preview_2d_sprite)
	_sub_viewport.add_child(_preview_2d_root)
	
	# 3D Preview Setup
	_preview_3d_root = Node3D.new()
	_preview_3d_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	_preview_3d_mesh.mesh = sphere
	_preview_3d_mesh.position = Vector3(0, 0, 0)
	
	_preview_3d_camera = Camera3D.new()
	_preview_3d_camera.position = Vector3(0, 0, 3.2)
	
	_preview_3d_light = DirectionalLight3D.new()
	_preview_3d_light.position = Vector3(2, 3, 2)
	_preview_3d_light.rotation_degrees = Vector3(-45, 45, 0)
	
	_preview_3d_root.add_child(_preview_3d_mesh)
	_preview_3d_root.add_child(_preview_3d_camera)
	_preview_3d_root.add_child(_preview_3d_light)
	_sub_viewport.add_child(_preview_3d_root)
	
	_preview_3d_root.visible = false
	_preview_2d_root.visible = true

func _populate_categories():
	if not _category_selector:
		return
	_category_selector.clear()
	for cat in ShaderPresets.CATEGORIES:
		_category_selector.add_item(cat)
	_populate_presets_for_category(0)

func _populate_presets_for_category(cat_index: int):
	if not _preset_selector or not _category_selector:
		return
	_preset_selector.clear()
	var cat_name = _category_selector.get_item_text(cat_index)
	var presets = ShaderPresets.CATEGORIES.get(cat_name, [])
	for p in presets:
		var p_data = ShaderPresets.get_preset(p)
		_preset_selector.add_item(p_data.get("name", p), presets.find(p))
		_preset_selector.set_item_metadata(_preset_selector.get_item_count() - 1, p)

func _on_category_selected(idx: int):
	_populate_presets_for_category(idx)
	if _preset_selector and _preset_selector.get_item_count() > 0:
		_on_preset_selected(0)

func _on_preset_selected(idx: int):
	if not _preset_selector:
		return
	var preset_name = _preset_selector.get_item_metadata(idx)
	if preset_name:
		load_preset(preset_name)

func _on_mode_selected(idx: int):
	_is_3d_mode = (idx == 1)
	_update_view_mode()

func _update_view_mode():
	if _preview_2d_root:
		_preview_2d_root.visible = not _is_3d_mode
	if _preview_3d_root:
		_preview_3d_root.visible = _is_3d_mode
		
	if _current_material:
		if _is_3d_mode and _preview_3d_mesh:
			_preview_3d_mesh.material_override = _current_material
			if _preview_2d_sprite:
				_preview_2d_sprite.material = null
		elif not _is_3d_mode and _preview_2d_sprite:
			_preview_2d_sprite.material = _current_material
			if _preview_3d_mesh:
				_preview_3d_mesh.material_override = null

func load_preset(preset_name: String):
	_current_preset = preset_name
	var p_data = ShaderPresets.get_preset(preset_name)
	if p_data.is_empty():
		return
		
	_current_code = p_data.get("code", "")
	var p_type = p_data.get("type", "canvas_item")
	_is_3d_mode = (p_type == "spatial")
	
	if _mode_selector:
		_mode_selector.select(1 if _is_3d_mode else 0)
		
	if _code_edit:
		_code_edit.text = _current_code
		
	_current_material = ShaderSynthesizer.create_shader_material(_current_code, p_data.get("default_uniforms", {}))
	_update_view_mode()
	_rebuild_uniform_controls()
	
	if _status_label:
		_status_label.text = "[color=#38bdf8]● [b]" + p_data.get("name", preset_name) + "[/b][/color] [color=#94a3b8](" + p_type + ")[/color]"

func _rebuild_uniform_controls():
	if not _uniforms_container:
		return
		
	for child in _uniforms_container.get_children():
		child.queue_free()
		
	var uniforms = UniformParser.parse_shader_code(_current_code)
	if uniforms.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No uniforms detected in shader."
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		_uniforms_container.add_child(empty_lbl)
		return
		
	for u in uniforms:
		var u_name = u.get("name", "")
		var u_type = u.get("type", "")
		var u_hint = u.get("hint", "")
		var def_val = u.get("default_value")
		
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var label = Label.new()
		label.text = u_name.capitalize() + ":"
		label.custom_minimum_size = Vector2(110, 0)
		row.add_child(label)
		
		if u_hint == "source_color" or u_type == "vec4" or u_type == "Color":
			var color_picker = ColorPickerButton.new()
			color_picker.custom_minimum_size = Vector2(80, 26)
			color_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var col_val = def_val if def_val is Color else Color.WHITE
			color_picker.color = col_val
			color_picker.color_changed.connect(func(new_color: Color):
				if _current_material:
					_current_material.set_shader_parameter(u_name, new_color)
			)
			row.add_child(color_picker)
			
		elif u_type == "float" or u_type == "int":
			var slider = HSlider.new()
			slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			var range_arr = u.get("hint_range", [])
			var min_v = range_arr[0] if range_arr.size() > 0 else 0.0
			var max_v = range_arr[1] if range_arr.size() > 1 else (1.0 if u_type == "float" else 100.0)
			var step_v = range_arr[2] if range_arr.size() > 2 else (0.01 if u_type == "float" else 1.0)
			
			slider.min_value = min_v
			slider.max_value = max_v
			slider.step = step_v
			var current_num = float(def_val) if def_val != null else min_v
			slider.value = current_num
			
			var val_label = Label.new()
			val_label.custom_minimum_size = Vector2(45, 0)
			val_label.text = str(snappedf(current_num, 0.01))
			
			slider.value_changed.connect(func(v: float):
				val_label.text = str(snappedf(v, 0.01))
				if _current_material:
					_current_material.set_shader_parameter(u_name, v if u_type == "float" else int(v))
			)
			row.add_child(slider)
			row.add_child(val_label)
			
		elif u_type == "bool":
			var checkbox = CheckBox.new()
			checkbox.button_pressed = bool(def_val) if def_val != null else false
			checkbox.toggled.connect(func(pressed: bool):
				if _current_material:
					_current_material.set_shader_parameter(u_name, pressed)
			)
			row.add_child(checkbox)
			
		else:
			var info_label = Label.new()
			info_label.text = "(" + u_type + ")"
			info_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			row.add_child(info_label)
			
		_uniforms_container.add_child(row)

func _on_recompile_pressed():
	if not _code_edit:
		return
	_current_code = _code_edit.text
	_current_material = ShaderSynthesizer.create_shader_material(_current_code)
	_is_3d_mode = ("shader_type spatial" in _current_code)
	if _mode_selector:
		_mode_selector.select(1 if _is_3d_mode else 0)
	_update_view_mode()
	_rebuild_uniform_controls()
	if _status_label:
		_status_label.text = "[color=green]✅ Shader recompiled & preview updated successfully.[/color]"

func _on_randomize_pressed():
	if not _current_material:
		return
	var uniforms = UniformParser.parse_shader_code(_current_code)
	for u in uniforms:
		var u_name = u.get("name", "")
		var u_type = u.get("type", "")
		var u_hint = u.get("hint", "")
		if u_hint == "source_color" or u_type == "Color":
			var rnd_col = Color(randf(), randf(), randf(), 1.0)
			_current_material.set_shader_parameter(u_name, rnd_col)
		elif u_type == "float":
			var range_arr = u.get("hint_range", [])
			var min_v = range_arr[0] if range_arr.size() > 0 else 0.0
			var max_v = range_arr[1] if range_arr.size() > 1 else 1.0
			var rnd_val = randf_range(min_v, max_v)
			_current_material.set_shader_parameter(u_name, rnd_val)
	_rebuild_uniform_controls()
	if _status_label:
		_status_label.text = "[color=#f59e0b]🎲 Parameters mutated with random values.[/color]"

func _on_apply_to_selection_pressed():
	if not Engine.is_editor_hint():
		return
	var selection = EditorInterface.get_selection().get_selected_nodes()
	if selection.is_empty():
		if _status_label:
			_status_label.text = "[color=#f43f5e]⚠️ No node selected in the Scene Tree. Please select a Sprite2D or MeshInstance3D first.[/color]"
		return
		
	var target = selection[0]
	var root = EditorInterface.get_edited_scene_root()
	var ur = EditorInterface.get_editor_undo_redo()
	
	if target is CanvasItem:
		var old_mat = target.material
		if ur:
			ur.create_action("Apply Shader to " + target.name, UndoRedo.MERGE_DISABLE, root)
			ur.add_do_property(target, "material", _current_material)
			ur.add_undo_property(target, "material", old_mat)
			ur.commit_action()
		else:
			target.material = _current_material
		if _status_label:
			_status_label.text = "[color=#10b981]✓ Applied shader to 2D node [b]" + target.name + "[/b]![/color]"
	elif target is GeometryInstance3D:
		var old_mat = target.material_override
		if ur:
			ur.create_action("Apply Shader to " + target.name, UndoRedo.MERGE_DISABLE, root)
			ur.add_do_property(target, "material_override", _current_material)
			ur.add_undo_property(target, "material_override", old_mat)
			ur.commit_action()
		else:
			target.material_override = _current_material
		if _status_label:
			_status_label.text = "[color=#10b981]✓ Applied shader to 3D node [b]" + target.name + "[/b]![/color]"
	else:
		if _status_label:
			_status_label.text = "[color=#f43f5e]⚠️ Selected node is not a CanvasItem or GeometryInstance3D.[/color]"

func _on_save_shader_pressed():
	var timestamp = str(Time.get_unix_time_from_system()).split(".")[0]
	var target_path = "res://shaders/" + _current_preset + "_" + timestamp + ".gdshader"
	
	var res = ShaderWriter.save_shader_and_material(target_path, _current_code)
	if res.get("success", false):
		var sh_path = res.get("shader_path", "")
		var mat_path = res.get("material_path", "")
		if _status_label:
			_status_label.text = "[color=green]💾 Saved shader to `" + sh_path + "` and material to `" + mat_path + "`![/color]"
		shader_saved.emit(sh_path, mat_path)
	else:
		if _status_label:
			_status_label.text = "[color=red]Error saving shader: " + res.get("error", "") + "[/color]"
