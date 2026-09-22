@tool
extends RefCounted

## Responsive UI Component Templates Generator

# ==============================================================================
# --- Component Factory Engine ---
# ==============================================================================

static func build_component(component_type: String, theme_res: Theme = null) -> Control:
	var comp_type = component_type.to_lower().strip_edges()
	var root: Control = null

	match comp_type:
		"hud", "gameplay_hud":
			root = _build_hud(theme_res)
		"pause_menu", "pause", "settings_menu":
			root = _build_pause_menu(theme_res)
		"inventory_grid", "inventory":
			root = _build_inventory_grid(theme_res)
		"dialogue_box", "dialogue":
			root = _build_dialogue_box(theme_res)
		"main_menu", "title_screen":
			root = _build_main_menu(theme_res)
		_:
			root = _build_hud(theme_res)

	if theme_res and root:
		root.theme = theme_res

	return root

# ==============================================================================
# --- 1. Gameplay HUD Template ---
# ==============================================================================

static func _build_hud(theme_res: Theme) -> Control:
	var hud_root = Control.new()
	hud_root.name = "HUD"
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var margin = MarginContainer.new()
	margin.name = "ScreenMargin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(margin)

	# Top Row (Stats + Minimap/Score)
	var top_hbox = HBoxContainer.new()
	top_hbox.name = "TopRow"
	top_hbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(top_hbox)

	# Health & Mana Container
	var stats_panel = PanelContainer.new()
	stats_panel.name = "StatsPanel"
	stats_panel.custom_minimum_size = Vector2(260, 80)
	top_hbox.add_child(stats_panel)

	var stats_vbox = VBoxContainer.new()
	stats_vbox.name = "StatsVBox"
	stats_panel.add_child(stats_vbox)

	var hp_label = Label.new()
	hp_label.text = "❤️ HP: 100 / 100"
	stats_vbox.add_child(hp_label)

	var hp_bar = ProgressBar.new()
	hp_bar.name = "HealthBar"
	hp_bar.value = 85.0
	hp_bar.custom_minimum_size = Vector2(0, 16)
	stats_vbox.add_child(hp_bar)

	var mana_label = Label.new()
	mana_label.text = "⚡ MANA: 75 / 100"
	stats_vbox.add_child(mana_label)

	var mana_bar = ProgressBar.new()
	mana_bar.name = "ManaBar"
	mana_bar.value = 60.0
	mana_bar.custom_minimum_size = Vector2(0, 14)
	stats_vbox.add_child(mana_bar)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_hbox.add_child(spacer)

	# Coin / Score Counter
	var score_panel = PanelContainer.new()
	score_panel.name = "ScorePanel"
	top_hbox.add_child(score_panel)

	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "🪙 1,250 G"
	score_panel.add_child(score_label)

	# Bottom Hotbar
	var bottom_center = CenterContainer.new()
	bottom_center.name = "BottomCenter"
	bottom_center.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_center.size_flags_vertical = Control.SIZE_SHRINK_END
	bottom_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(bottom_center)

	var hotbar_panel = PanelContainer.new()
	hotbar_panel.name = "HotbarPanel"
	bottom_center.add_child(hotbar_panel)

	var hotbar_hbox = HBoxContainer.new()
	hotbar_hbox.name = "SlotHBox"
	hotbar_panel.add_child(hotbar_hbox)

	for i in range(5):
		var slot_btn = Button.new()
		slot_btn.name = "Slot_" + str(i + 1)
		slot_btn.custom_minimum_size = Vector2(48, 48)
		slot_btn.text = "[" + str(i + 1) + "]"
		hotbar_hbox.add_child(slot_btn)

	return hud_root

# ==============================================================================
# --- 2. Pause Menu Template ---
# ==============================================================================

static func _build_pause_menu(theme_res: Theme) -> Control:
	var pause_root = Control.new()
	pause_root.name = "PauseMenu"
	pause_root.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Dark Dim Overlay
	var overlay = ColorRect.new()
	overlay.name = "DimOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	pause_root.add_child(overlay)

	var center = CenterContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_root.add_child(center)

	var panel = PanelContainer.new()
	panel.name = "MenuPanel"
	panel.custom_minimum_size = Vector2(400, 360)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.name = "MenuVBox"
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var title_lbl = Label.new()
	title_lbl.name = "TitleLabel"
	title_lbl.text = "⏸️ JOGO PAUSADO"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	# Audio Volume Sliders
	var audio_box = VBoxContainer.new()
	audio_box.name = "AudioSettings"
	vbox.add_child(audio_box)

	var master_lbl = Label.new()
	master_lbl.text = "Volume Geral"
	audio_box.add_child(master_lbl)
	var master_slider = HSlider.new()
	master_slider.name = "MasterVolumeSlider"
	master_slider.value = 80.0
	audio_box.add_child(master_slider)

	var sfx_lbl = Label.new()
	sfx_lbl.text = "Efeitos Sonoros (SFX)"
	audio_box.add_child(sfx_lbl)
	var sfx_slider = HSlider.new()
	sfx_slider.name = "SFXVolumeSlider"
	sfx_slider.value = 90.0
	audio_box.add_child(sfx_slider)

	# Action Buttons
	var btn_box = VBoxContainer.new()
	btn_box.name = "ActionButtons"
	btn_box.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_box)

	var resume_btn = Button.new()
	resume_btn.name = "ResumeButton"
	resume_btn.text = "▶️ Continuar"
	btn_box.add_child(resume_btn)

	var restart_btn = Button.new()
	restart_btn.name = "RestartButton"
	restart_btn.text = "🔄 Reiniciar Fase"
	btn_box.add_child(restart_btn)

	var quit_btn = Button.new()
	quit_btn.name = "QuitButton"
	quit_btn.text = "🚪 Menu Principal"
	btn_box.add_child(quit_btn)

	return pause_root

# ==============================================================================
# --- 3. Inventory Grid Template ---
# ==============================================================================

static func _build_inventory_grid(theme_res: Theme) -> Control:
	var inv_root = Control.new()
	inv_root.name = "Inventory"
	inv_root.set_anchors_preset(Control.PRESET_FULL_RECT)

	var center = CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	inv_root.add_child(center)

	var panel = PanelContainer.new()
	panel.name = "InventoryPanel"
	panel.custom_minimum_size = Vector2(440, 380)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.name = "ContentVBox"
	panel.add_child(vbox)

	var header_lbl = Label.new()
	header_lbl.name = "HeaderLabel"
	header_lbl.text = "🎒 INVENTÁRIO (24 Slots)"
	header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header_lbl)

	var scroll = ScrollContainer.new()
	scroll.name = "GridScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var grid = GridContainer.new()
	grid.name = "SlotGrid"
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)

	for i in range(24):
		var slot = Button.new()
		slot.name = "Slot_" + str(i)
		slot.custom_minimum_size = Vector2(56, 56)
		slot.text = ""
		grid.add_child(slot)

	return inv_root

# ==============================================================================
# --- 4. Dialogue Box Template ---
# ==============================================================================

static func _build_dialogue_box(theme_res: Theme) -> Control:
	var dial_root = Control.new()
	dial_root.name = "DialogueSystem"
	dial_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	dial_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var margin = MarginContainer.new()
	margin.name = "BottomMargin"
	margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_bottom", 32)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dial_root.add_child(margin)

	var panel = PanelContainer.new()
	panel.name = "DialoguePanel"
	panel.custom_minimum_size = Vector2(0, 160)
	margin.add_child(panel)

	var hbox = HBoxContainer.new()
	hbox.name = "DialogueHBox"
	hbox.add_theme_constant_override("separation", 20)
	panel.add_child(hbox)

	# Portrait Frame
	var portrait_panel = PanelContainer.new()
	portrait_panel.name = "PortraitFrame"
	portrait_panel.custom_minimum_size = Vector2(120, 120)
	hbox.add_child(portrait_panel)

	var portrait_rect = TextureRect.new()
	portrait_rect.name = "PortraitTexture"
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_panel.add_child(portrait_rect)

	# Text Column
	var text_vbox = VBoxContainer.new()
	text_vbox.name = "TextVBox"
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	var name_label = Label.new()
	name_label.name = "CharacterName"
	name_label.text = "🧙‍♂️ Mago Ancião"
	text_vbox.add_child(name_label)

	var text_body = RichTextLabel.new()
	text_body.name = "DialogueText"
	text_body.bbcode_enabled = true
	text_body.text = "Saudações, bravo aventureiro! O reino precisa da sua coragem para derrotar a escuridão..."
	text_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_vbox.add_child(text_body)

	return dial_root

# ==============================================================================
# --- 5. Main Menu Title Screen Template ---
# ==============================================================================

static func _build_main_menu(theme_res: Theme) -> Control:
	var menu_root = Control.new()
	menu_root.name = "MainMenu"
	menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)

	var center = CenterContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_root.add_child(center)

	var vbox = VBoxContainer.new()
	vbox.name = "MenuVBox"
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	var title_lbl = Label.new()
	title_lbl.name = "GameTitle"
	title_lbl.text = "⚔️ MEU NOVO JOGO"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	var btn_vbox = VBoxContainer.new()
	btn_vbox.name = "ButtonsVBox"
	btn_vbox.add_theme_constant_override("separation", 10)
	vbox.add_child(btn_vbox)

	var play_btn = Button.new()
	play_btn.name = "PlayButton"
	play_btn.text = "🎮 Novo Jogo"
	play_btn.custom_minimum_size = Vector2(220, 44)
	btn_vbox.add_child(play_btn)

	var continue_btn = Button.new()
	continue_btn.name = "ContinueButton"
	continue_btn.text = "💾 Continuar"
	btn_vbox.add_child(continue_btn)

	var settings_btn = Button.new()
	settings_btn.name = "SettingsButton"
	settings_btn.text = "⚙️ Opções"
	btn_vbox.add_child(settings_btn)

	var exit_btn = Button.new()
	exit_btn.name = "ExitButton"
	exit_btn.text = "🚪 Sair do Jogo"
	btn_vbox.add_child(exit_btn)

	return menu_root
