@tool
extends VBoxContainer

const DockChat = preload("res://addons/gamedev_ai/dock/dock_chat.gd")
const DockDiff = preload("res://addons/gamedev_ai/dock/dock_diff.gd")
const DockGit = preload("res://addons/gamedev_ai/dock/dock_git.gd")
const DockSettings = preload("res://addons/gamedev_ai/dock/dock_settings.gd")
const DockShader = preload("res://addons/gamedev_ai/dock/dock_shader.gd")

# Controller Modules
var chat_ctrl: RefCounted
var diff_ctrl: RefCounted
var git_ctrl: RefCounted
var settings_ctrl: RefCounted
var shader_ctrl: RefCounted

# Managers & Providers
var gemini_client
var ai_provider
var context_manager
var _tool_executor
var _memory_manager
var locale_manager
var git_manager

# Signals for GamedevAI plugin integration
signal preset_changed(config)
signal settings_updated()

# Scene node references (unique names from dock.tscn)
@onready var chat_scroll: ScrollContainer = %ChatScrollContainer
@onready var chat_vbox: VBoxContainer = %ChatVBox
@onready var input_field: TextEdit = %InputField
@onready var send_button: Button = %SendButton
@onready var magic_actions_btn: MenuButton = %MagicActionsBtn
@onready var prompt_settings_btn: MenuButton = %PromptSettingsBtn
@onready var selection_status: Label = %SelectionStatus
@onready var history_button: MenuButton = %HistoryButton
@onready var summarize_btn: Button = %SummarizeBtn
@onready var new_chat_button: Button = %NewChatButton
@onready var execute_plan_btn: Button = %ExecutePlanBtn
@onready var chat_preset_selector: OptionButton = %ChatPresetSelector
@onready var font_size_minus_btn: Button = %FontSizeMinusBtn
@onready var font_size_plus_btn: Button = %FontSizePlusBtn
@onready var _image_preview_scroll: ScrollContainer = %ImagePreviewScroll
@onready var _thumbnail_list: HBoxContainer = %ThumbnailList
@onready var add_file_btn: Button = %AddFileBtn
@onready var _add_file_dialog: FileDialog = %AddFileDialog
@onready var _image_popup_dialog: AcceptDialog = %ImagePopupDialog
@onready var _popup_texture_rect: TextureRect = %PopupTextureRect
@onready var preset_selector: OptionButton = %PresetSelector
@onready var preset_name_input: LineEdit = %PresetNameInput
@onready var provider_selector: OptionButton = %ProviderSelector
@onready var preset_edit_panel: VBoxContainer = %PresetEditPanel
@onready var edit_preset_btn: Button = %EditPresetBtn
@onready var close_edit_btn: Button = %CloseEditBtn
@onready var settings_bar: HBoxContainer = %SettingsBar
@onready var api_input: LineEdit = %ApiInput
@onready var url_input: LineEdit = %UrlInput
@onready var model_input: LineEdit = %ModelInput
@onready var _file_preview_container: HBoxContainer = %FilePreviewContainer
@onready var _file_preview_label: RichTextLabel = %FilePreviewLabel
@onready var _file_clear_btn: Button = %FileClearBtn
@onready var custom_prompt_input: TextEdit = %CustomPromptInput
@onready var _diff_preview_panel: VBoxContainer = %DiffPreviewPanel
@onready var _diff_display: RichTextLabel = %DiffDisplay
@onready var _apply_diff_btn: Button = %ApplyDiffBtn
@onready var _skip_diff_btn: Button = %SkipDiffBtn
@onready var language_selector: OptionButton = %LanguageSelector
@onready var language_label: Label = %LanguageSelector.get_parent().get_child(0)

@onready var git_tab: VBoxContainer = $TabContainer.get_child(2)
@onready var init_repo_btn: Button = %InitRepoBtn
@onready var remote_container: HBoxContainer = %RemoteContainer
@onready var remote_url_input: LineEdit = %RemoteUrlInput
@onready var set_remote_btn: Button = %SetRemoteBtn
@onready var git_status_label: RichTextLabel = %GitStatusLabel
@onready var pull_btn: Button = %PullBtn
@onready var refresh_git_btn: Button = %RefreshGitBtn
@onready var auto_generate_commit_btn: Button = %AutoGenerateBtn
@onready var commit_msg_input: TextEdit = %CommitMsgInput
@onready var commit_sync_btn: Button = %CommitSyncBtn

@onready var branch_label: RichTextLabel = %BranchLabel
@onready var branch_name_input: LineEdit = %BranchNameInput
@onready var checkout_branch_btn: Button = %CheckoutBranchBtn
@onready var undo_changes_btn: Button = %UndoChangesBtn
@onready var force_pull_btn: Button = %ForcePullBtn
@onready var force_push_btn: Button = %ForcePushBtn
@onready var undo_confirm_dialog: ConfirmationDialog = %UndoConfirmDialog
@onready var force_pull_confirm_dialog: ConfirmationDialog = %ForcePullConfirmDialog
@onready var force_push_confirm_dialog: ConfirmationDialog = %ForcePushConfirmDialog

@onready var vector_db_file_list: RichTextLabel = %VectorDBFileList
@onready var scan_changes_btn: Button = %ScanChangesBtn
@onready var index_codebase_btn: Button = %IndexCodebaseBtn
@onready var index_confirm_dialog: ConfirmationDialog = %IndexConfirmDialog
@onready var index_result_dialog: AcceptDialog = %IndexResultDialog
@onready var enhance_prompt_btn: Button = %EnhancePromptBtn
@onready var enhance_preview_dialog: ConfirmationDialog = %EnhancePreviewDialog
@onready var enhance_preview_label: RichTextLabel = %EnhancePreviewLabel

@onready var tts_player_container: VBoxContainer = %TTSPlayerContainer
@onready var tts_play_btn: Button = %TTSPlayBtn
@onready var tts_stop_btn: Button = %TTSStopBtn
@onready var tts_seek_slider: HSlider = %TTSSeekSlider
@onready var tts_speed_selector: OptionButton = %TTSSpeedSelector
@onready var tts_player: AudioStreamPlayer = %TTSPlayer

# Shader Studio Nodes
@onready var shader_category_selector: OptionButton = %ShaderCategorySelector
@onready var shader_preset_selector: OptionButton = %ShaderPresetSelector
@onready var shader_mode_selector: OptionButton = %ShaderModeSelector
@onready var shader_viewport_container: SubViewportContainer = %ShaderViewportContainer
@onready var shader_uniforms_container: VBoxContainer = %ShaderUniformsContainer
@onready var shader_code_edit: TextEdit = %ShaderCodeEdit
@onready var shader_recompile_btn: Button = %ShaderRecompileBtn
@onready var shader_randomize_btn: Button = %ShaderRandomizeBtn
@onready var shader_apply_btn: Button = %ShaderApplyBtn
@onready var shader_save_btn: Button = %ShaderSaveBtn
@onready var shader_status_label: RichTextLabel = %ShaderStatusLabel

func _ready():
	# 1. Initialize Managers
	var LocaleMgr = preload("res://addons/gamedev_ai/locale_manager.gd")
	var GitMgr = preload("res://addons/gamedev_ai/git_manager.gd")
	locale_manager = LocaleMgr.new()
	git_manager = GitMgr.new()
	
	var settings = EditorInterface.get_editor_settings()
	var saved_locale = ""
	if settings.has_setting("gamedev_ai/language"):
		saved_locale = settings.get_setting("gamedev_ai/language")
	if saved_locale != "":
		locale_manager.set_locale(saved_locale)
	
	# 2. Instantiate Sub-controllers
	chat_ctrl = DockChat.new()
	diff_ctrl = DockDiff.new()
	git_ctrl = DockGit.new()
	settings_ctrl = DockSettings.new()
	shader_ctrl = DockShader.new()
	
	# 3. Initialize Sub-controllers with their respective node groups
	diff_ctrl.setup(self, _tool_executor, locale_manager, _diff_preview_panel, _diff_display, _apply_diff_btn, _skip_diff_btn, chat_vbox)
	
	var git_nodes = {
		"git_tab": git_tab, "init_repo_btn": init_repo_btn, "remote_container": remote_container,
		"remote_url_input": remote_url_input, "set_remote_btn": set_remote_btn, "git_status_label": git_status_label,
		"pull_btn": pull_btn, "refresh_git_btn": refresh_git_btn, "auto_generate_commit_btn": auto_generate_commit_btn,
		"commit_msg_input": commit_msg_input, "commit_sync_btn": commit_sync_btn, "branch_label": branch_label,
		"branch_name_input": branch_name_input, "checkout_branch_btn": checkout_branch_btn, "undo_changes_btn": undo_changes_btn,
		"force_pull_btn": force_pull_btn, "force_push_btn": force_push_btn, "undo_confirm_dialog": undo_confirm_dialog,
		"force_pull_confirm_dialog": force_pull_confirm_dialog, "force_push_confirm_dialog": force_push_confirm_dialog
	}
	git_ctrl.setup(self, git_manager, ai_provider, locale_manager, git_nodes)
	
	var settings_nodes = {
		"preset_selector": preset_selector, "preset_name_input": preset_name_input, "provider_selector": provider_selector,
		"preset_edit_panel": preset_edit_panel, "edit_preset_btn": edit_preset_btn, "close_edit_btn": close_edit_btn,
		"add_preset_btn": find_child("AddPresetBtn", true, false), "del_preset_btn": find_child("DelPresetBtn", true, false),
		"settings_bar": settings_bar, "api_input": api_input, "url_input": url_input, "model_input": model_input,
		"language_selector": language_selector, "language_label": language_label, "custom_prompt_input": custom_prompt_input,
		"font_size_minus_btn": font_size_minus_btn, "font_size_plus_btn": font_size_plus_btn,
		"vector_db_file_list": vector_db_file_list, "scan_changes_btn": scan_changes_btn, "index_codebase_btn": index_codebase_btn,
		"index_confirm_dialog": index_confirm_dialog, "index_result_dialog": index_result_dialog,
		"enhance_prompt_btn": enhance_prompt_btn, "enhance_preview_dialog": enhance_preview_dialog,
		"enhance_preview_label": enhance_preview_label,
		"chat_preset_selector": chat_preset_selector
	}
	settings_ctrl.preset_changed.connect(func(cfg): preset_changed.emit(cfg))
	settings_ctrl.settings_updated.connect(func(): settings_updated.emit())
	settings_ctrl.font_size_changed.connect(func(size): chat_ctrl.set_font_size(size))
	settings_ctrl.setup(self, locale_manager, _tool_executor, ai_provider, settings_nodes)
	
	var chat_nodes = {
		"chat_scroll": chat_scroll, "chat_vbox": chat_vbox, "input_field": input_field, "send_button": send_button,
		"magic_actions_btn": magic_actions_btn, "prompt_settings_btn": prompt_settings_btn, "selection_status": selection_status,
		"history_button": history_button, "summarize_btn": summarize_btn, "new_chat_button": new_chat_button,
		"execute_plan_btn": execute_plan_btn, "chat_preset_selector": chat_preset_selector,
		"_image_preview_scroll": _image_preview_scroll, "_thumbnail_list": _thumbnail_list, "add_file_btn": add_file_btn,
		"_add_file_dialog": _add_file_dialog, "_image_popup_dialog": _image_popup_dialog, "_popup_texture_rect": _popup_texture_rect,
		"_file_preview_container": _file_preview_container, "_file_preview_label": _file_preview_label, "_file_clear_btn": _file_clear_btn,
		"tts_player_container": tts_player_container, "tts_play_btn": tts_play_btn, "tts_stop_btn": tts_stop_btn,
		"tts_seek_slider": tts_seek_slider, "tts_speed_selector": tts_speed_selector, "tts_player": tts_player
	}
	chat_ctrl.setup(self, ai_provider, context_manager, _tool_executor, _memory_manager, locale_manager, chat_nodes)
	
	var shader_nodes = {
		"shader_category_selector": shader_category_selector,
		"shader_preset_selector": shader_preset_selector,
		"shader_mode_selector": shader_mode_selector,
		"shader_viewport_container": shader_viewport_container,
		"shader_uniforms_container": shader_uniforms_container,
		"shader_code_edit": shader_code_edit,
		"shader_recompile_btn": shader_recompile_btn,
		"shader_randomize_btn": shader_randomize_btn,
		"shader_apply_btn": shader_apply_btn,
		"shader_save_btn": shader_save_btn,
		"shader_status_label": shader_status_label
	}
	shader_ctrl.setup(self, _tool_executor, shader_nodes)
	
	$TabContainer.tab_changed.connect(_on_tab_changed)
	
	# Apply visual styling and cards
	_apply_custom_theme()

func setup(client, manager, executor):
	gemini_client = client
	ai_provider = client
	context_manager = manager
	_tool_executor = executor
	
	if diff_ctrl:
		diff_ctrl._tool_executor = _tool_executor
	if settings_ctrl:
		settings_ctrl._tool_executor = _tool_executor
		settings_ctrl.set_ai_provider(ai_provider)
	if git_ctrl:
		git_ctrl.set_ai_provider(ai_provider)
	if chat_ctrl:
		chat_ctrl.context_manager = context_manager
		chat_ctrl._tool_executor = _tool_executor
		chat_ctrl.set_ai_provider(ai_provider)
	if shader_ctrl:
		shader_ctrl._tool_executor = _tool_executor
		
	if _tool_executor:
		_tool_executor.diff_preview_requested.connect(func(path, old_c, new_c, t_name, args):
			diff_ctrl.show_diff_preview(path, old_c, new_c, t_name, args)
		)
		_tool_executor.init_vector_db(self)
		if _tool_executor.vector_db:
			_tool_executor.vector_db.db_output.connect(func(msg):
				settings_ctrl.on_vector_db_output(msg)
			)

func _set_client(provider):
	gemini_client = provider
	ai_provider = provider
	if chat_ctrl:
		chat_ctrl.set_ai_provider(provider)
	if git_ctrl:
		git_ctrl.set_ai_provider(provider)
	if settings_ctrl:
		settings_ctrl.set_ai_provider(provider)

func _on_log_entry(entry: Dictionary):
	if chat_ctrl:
		chat_ctrl.handle_engine_log(entry)

func _on_tab_changed(tab: int):
	if tab == 2 and git_ctrl:
		git_ctrl.update_git_status()

# ===================== VISUAL THEME & CARDS =====================

func _apply_custom_theme():
	# Root Dock Panel - Deep slate obsidian background with subtle margin
	var panel_style = _create_glass_style(Color(0.06, 0.07, 0.09, 1.0), Color(1, 1, 1, 0.06), 0)
	panel_style.content_margin_left = 6
	panel_style.content_margin_right = 6
	panel_style.content_margin_top = 4
	panel_style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", panel_style)
	
	# TabContainer Glass Styling with generous breathing room
	_style_tab_container($TabContainer)
	
	# Chat Preset Selector - Stable width and clean placement
	if chat_preset_selector:
		chat_preset_selector.custom_minimum_size = Vector2(135, 28)
		chat_preset_selector.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
	# Chat Input - Floating Glass Card with inset breathing room
	var input_style = _create_glass_style(Color(0.08, 0.10, 0.14, 0.85), Color(1, 1, 1, 0.10), 10, 6, Color(0, 0, 0, 0.35))
	input_style.content_margin_left = 14
	input_style.content_margin_right = 14
	input_style.content_margin_top = 12
	input_style.content_margin_bottom = 44
	input_field.add_theme_stylebox_override("normal", input_style)
	
	var input_focus = input_style.duplicate()
	input_focus.border_color = Color(0.25, 0.55, 0.95, 0.70)
	input_focus.shadow_color = Color(0.12, 0.32, 0.80, 0.25)
	input_field.add_theme_stylebox_override("focus", input_focus)
	
	# Settings Custom Prompt Input - Match Glass Card style
	if custom_prompt_input:
		var prompt_style = _create_glass_style(Color(0.08, 0.10, 0.14, 0.80), Color(1, 1, 1, 0.09), 8, 4, Color(0, 0, 0, 0.25))
		prompt_style.content_margin_left = 12
		prompt_style.content_margin_right = 12
		prompt_style.content_margin_top = 10
		prompt_style.content_margin_bottom = 10
		custom_prompt_input.add_theme_stylebox_override("normal", prompt_style)
		var prompt_focus = prompt_style.duplicate()
		prompt_focus.border_color = Color(0.25, 0.55, 0.95, 0.65)
		custom_prompt_input.add_theme_stylebox_override("focus", prompt_focus)
	
	# Send Button - Modern Electric Blue Pill/Circle
	var send_style = _create_glass_style(Color(0.20, 0.48, 0.92, 0.95), Color(0.45, 0.70, 1.0, 0.50), 20, 4, Color(0.1, 0.3, 0.8, 0.30))
	send_button.add_theme_stylebox_override("normal", send_style)
	var send_hover = send_style.duplicate()
	send_hover.bg_color = Color(0.26, 0.56, 1.0, 1.0)
	send_hover.border_color = Color(0.6, 0.8, 1.0, 0.70)
	send_button.add_theme_stylebox_override("hover", send_hover)
	send_button.add_theme_stylebox_override("pressed", send_style)
	
	# Load SVG Icons
	var icon_path = "res://addons/gamedev_ai/assets/icons/"
	new_chat_button.icon = _load_svg_icon(icon_path + "plus.svg", "ffffff", 0.75)
	history_button.icon = _load_svg_icon(icon_path + "history.svg", "ffffff", 0.75)
	summarize_btn.icon = _load_svg_icon(icon_path + "save.svg", "ffffff", 0.75)
	add_file_btn.icon = _load_svg_icon(icon_path + "attach.svg", "ffffff", 0.75)
	send_button.icon = _load_svg_icon(icon_path + "send.svg", "ffffff", 0.75)
	magic_actions_btn.icon = _load_svg_icon(icon_path + "magic.svg", "ffffff", 0.75)
	prompt_settings_btn.icon = _load_svg_icon(icon_path + "settings.svg", "ffffff", 0.75)
	
	# Clean button text to avoid emoji duplication with SVG icons
	new_chat_button.text = "New"
	history_button.text = "History"
	summarize_btn.text = "Save"
	
	# Chat Header Buttons
	_style_glass_button(new_chat_button, "primary", 6)
	_style_glass_button(history_button, "secondary", 6)
	_style_glass_button(summarize_btn, "secondary", 6)
	_style_glass_button(font_size_minus_btn, "secondary", 4)
	_style_glass_button(font_size_plus_btn, "secondary", 4)
	
	# Toolbar Icon Buttons (inside input container)
	_style_glass_button(add_file_btn, "icon", 6)
	_style_glass_button(prompt_settings_btn, "icon", 6)
	
	# Chat Utility & Actions
	_style_glass_button(magic_actions_btn, "secondary", 8)
	_style_glass_button(execute_plan_btn, "primary", 6)
	_style_glass_button(_apply_diff_btn, "primary", 6)
	_style_glass_button(_skip_diff_btn, "secondary", 6)
	_style_glass_button(tts_play_btn, "secondary", 6)
	_style_glass_button(tts_stop_btn, "danger", 6)
	_style_glass_button(_file_clear_btn, "danger", 6)
	
	# Hide raw selection status if empty
	if selection_status and selection_status.text == "No selection":
		selection_status.visible = false
	
	# Git Tab Buttons
	_style_glass_button(init_repo_btn, "primary", 8)
	_style_glass_button(set_remote_btn, "secondary", 6)
	_style_glass_button(pull_btn, "secondary", 6)
	_style_glass_button(refresh_git_btn, "secondary", 6)
	_style_glass_button(auto_generate_commit_btn, "secondary", 6)
	_style_glass_button(commit_sync_btn, "primary", 8)
	_style_glass_button(checkout_branch_btn, "secondary", 6)
	
	_style_glass_button(undo_changes_btn, "danger", 6)
	_style_glass_button(force_pull_btn, "danger", 6)
	_style_glass_button(force_push_btn, "danger", 6)
	
	# Shader Studio Buttons - Harmonized Palette
	_style_glass_button(shader_apply_btn, "primary", 6)
	_style_glass_button(shader_recompile_btn, "secondary", 6)
	_style_glass_button(shader_randomize_btn, "secondary", 6)
	_style_glass_button(shader_save_btn, "secondary", 6)
	
	# Settings Tab Buttons
	_style_glass_button(enhance_prompt_btn, "primary", 6)
	_style_glass_button(scan_changes_btn, "secondary", 6)
	_style_glass_button(index_codebase_btn, "primary", 6)
	_style_glass_button(edit_preset_btn, "secondary", 6)
	_style_glass_button(close_edit_btn, "success", 6)
	
	var add_preset_btn = find_child("AddPresetBtn", true, false)
	var del_preset_btn = find_child("DelPresetBtn", true, false)
	if add_preset_btn: _style_glass_button(add_preset_btn, "secondary", 6)
	if del_preset_btn: _style_glass_button(del_preset_btn, "danger", 6)
	
	# Glass Input styling for Commit message & Shader code
	if commit_msg_input:
		var commit_style = _create_glass_style(Color(0.08, 0.10, 0.14, 0.80), Color(1, 1, 1, 0.09), 8, 4, Color(0, 0, 0, 0.25))
		commit_style.content_margin_left = 12
		commit_style.content_margin_right = 12
		commit_style.content_margin_top = 8
		commit_style.content_margin_bottom = 8
		commit_msg_input.add_theme_stylebox_override("normal", commit_style)
		var commit_focus = commit_style.duplicate()
		commit_focus.border_color = Color(0.25, 0.55, 0.95, 0.65)
		commit_msg_input.add_theme_stylebox_override("focus", commit_focus)
		
	if shader_code_edit:
		var code_style = _create_glass_style(Color(0.06, 0.07, 0.10, 0.85), Color(1, 1, 1, 0.08), 8, 4, Color(0, 0, 0, 0.30))
		code_style.content_margin_left = 10
		code_style.content_margin_right = 10
		code_style.content_margin_top = 10
		code_style.content_margin_bottom = 10
		shader_code_edit.add_theme_stylebox_override("normal", code_style)
		shader_code_edit.add_theme_stylebox_override("focus", code_style)

	# Glass status containers
	var status_bg = _create_glass_style(Color(0.07, 0.08, 0.12, 0.70), Color(1, 1, 1, 0.06), 8, 2, Color(0, 0, 0, 0.15))
	status_bg.content_margin_left = 12
	status_bg.content_margin_right = 12
	status_bg.content_margin_top = 10
	status_bg.content_margin_bottom = 10
	if git_status_label:
		git_status_label.add_theme_stylebox_override("normal", status_bg)
	if vector_db_file_list:
		vector_db_file_list.add_theme_stylebox_override("normal", status_bg)
	if shader_status_label:
		var stat_bg = _create_glass_style(Color(0.08, 0.10, 0.15, 0.75), Color(0.2, 0.5, 0.9, 0.30), 6)
		stat_bg.content_margin_left = 10
		stat_bg.content_margin_right = 10
		stat_bg.content_margin_top = 6
		stat_bg.content_margin_bottom = 6
		shader_status_label.add_theme_stylebox_override("normal", stat_bg)
		
	# LineEdit Glass Styling
	var line_edit_style = _create_glass_style(Color(0.09, 0.11, 0.15, 0.75), Color(1, 1, 1, 0.08), 6)
	line_edit_style.content_margin_left = 10
	line_edit_style.content_margin_right = 10
	line_edit_style.content_margin_top = 6
	line_edit_style.content_margin_bottom = 6
	var line_edit_focus = line_edit_style.duplicate()
	line_edit_focus.border_color = Color(0.25, 0.55, 0.95, 0.65)
	for le in [remote_url_input, branch_name_input, preset_name_input, api_input, url_input, model_input]:
		if is_instance_valid(le):
			le.add_theme_stylebox_override("normal", line_edit_style)
			le.add_theme_stylebox_override("focus", line_edit_focus)

	# OptionButton Glass Styling
	var opt_style = _create_glass_style(Color(0.12, 0.15, 0.22, 0.70), Color(1, 1, 1, 0.09), 6)
	opt_style.content_margin_left = 10
	opt_style.content_margin_right = 10
	opt_style.content_margin_top = 6
	opt_style.content_margin_bottom = 6
	var opt_hover = opt_style.duplicate()
	opt_hover.bg_color = Color(0.16, 0.20, 0.30, 0.85)
	opt_hover.border_color = Color(1, 1, 1, 0.18)
	for opt in [preset_selector, chat_preset_selector, language_selector, provider_selector, shader_category_selector, shader_preset_selector, shader_mode_selector]:
		if is_instance_valid(opt):
			opt.add_theme_stylebox_override("normal", opt_style)
			opt.add_theme_stylebox_override("hover", opt_hover)
			opt.add_theme_stylebox_override("pressed", opt_style)
			opt.add_theme_stylebox_override("focus", opt_hover)
	
	$TabContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for child in $TabContainer.get_children():
		if child is Control:
			child.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _create_glass_style(bg_color: Color, border_color: Color = Color(1, 1, 1, 0.08), corner_radius: int = 8, shadow_size: int = 0, shadow_color: Color = Color(0, 0, 0, 0.25)) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(corner_radius)
	if shadow_size > 0:
		style.shadow_size = shadow_size
		style.shadow_color = shadow_color
		style.shadow_offset = Vector2(0, 2)
	return style

func _style_tab_container(tabs: TabContainer):
	if not is_instance_valid(tabs): return
	
	var panel = _create_glass_style(Color(0.06, 0.07, 0.09, 0.95), Color(1, 1, 1, 0.05), 8)
	panel.content_margin_left = 12
	panel.content_margin_right = 12
	panel.content_margin_top = 10
	panel.content_margin_bottom = 12
	tabs.add_theme_stylebox_override("panel", panel)
	
	tabs.add_theme_constant_override("side_margin", 8)
	
	var tab_selected = StyleBoxFlat.new()
	tab_selected.bg_color = Color(0.14, 0.17, 0.25, 0.85)
	tab_selected.border_color = Color(0.35, 0.60, 1.0, 0.85)
	tab_selected.border_width_bottom = 2
	tab_selected.corner_radius_top_left = 6
	tab_selected.corner_radius_top_right = 6
	tab_selected.content_margin_left = 14
	tab_selected.content_margin_right = 14
	tab_selected.content_margin_top = 8
	tab_selected.content_margin_bottom = 8
	tabs.add_theme_stylebox_override("tab_selected", tab_selected)
	
	var tab_unselected = StyleBoxFlat.new()
	tab_unselected.bg_color = Color(0.08, 0.10, 0.14, 0.45)
	tab_unselected.border_color = Color(1, 1, 1, 0.04)
	tab_unselected.border_width_bottom = 1
	tab_unselected.corner_radius_top_left = 6
	tab_unselected.corner_radius_top_right = 6
	tab_unselected.content_margin_left = 14
	tab_unselected.content_margin_right = 14
	tab_unselected.content_margin_top = 8
	tab_unselected.content_margin_bottom = 8
	tabs.add_theme_stylebox_override("tab_unselected", tab_unselected)
	
	var tab_hovered = tab_unselected.duplicate()
	tab_hovered.bg_color = Color(0.18, 0.22, 0.32, 0.70)
	tabs.add_theme_stylebox_override("tab_hovered", tab_hovered)

func _load_svg_icon(path: String, color_hex: String, scale: float = 1.0) -> Texture2D:
	if not FileAccess.file_exists(path): return null
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return null
	var svg_content = file.get_as_text()
	svg_content = svg_content.replace("currentColor", "#" + color_hex)
	var img = Image.new()
	if img.load_svg_from_string(svg_content, scale) == OK:
		return ImageTexture.create_from_image(img)
	return null

func _style_glass_button(btn: Control, variant: String = "secondary", corner: int = 6):
	if not is_instance_valid(btn): return
	
	var normal = StyleBoxFlat.new()
	normal.set_corner_radius_all(corner)
	normal.set_border_width_all(1)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	
	var hover = normal.duplicate()
	var pressed = normal.duplicate()
	var font_color = Color(0.90, 0.93, 0.98)
	
	match variant:
		"primary":
			normal.bg_color = Color(0.20, 0.44, 0.88, 0.90)
			normal.border_color = Color(0.40, 0.65, 1.0, 0.45)
			normal.shadow_size = 4
			normal.shadow_color = Color(0.1, 0.3, 0.8, 0.25)
			normal.shadow_offset = Vector2(0, 2)
			
			hover.bg_color = Color(0.25, 0.52, 0.98, 1.0)
			hover.border_color = Color(0.55, 0.75, 1.0, 0.70)
			hover.shadow_size = 6
			hover.shadow_color = Color(0.15, 0.35, 0.85, 0.35)
			
			pressed.bg_color = Color(0.15, 0.36, 0.76, 1.0)
			font_color = Color.WHITE
		"success":
			normal.bg_color = Color(0.10, 0.45, 0.30, 0.75)
			normal.border_color = Color(0.25, 0.80, 0.55, 0.40)
			
			hover.bg_color = Color(0.14, 0.55, 0.36, 0.90)
			hover.border_color = Color(0.35, 0.90, 0.65, 0.60)
			
			pressed.bg_color = Color(0.08, 0.36, 0.24, 0.95)
			font_color = Color.WHITE
		"danger":
			normal.bg_color = Color(0.85, 0.25, 0.30, 0.08)
			normal.border_color = Color(0.85, 0.30, 0.35, 0.35)
			
			hover.bg_color = Color(0.85, 0.25, 0.30, 0.20)
			hover.border_color = Color(0.95, 0.40, 0.45, 0.70)
			
			pressed.bg_color = Color(0.65, 0.15, 0.20, 0.30)
			font_color = Color(0.96, 0.55, 0.58)
		"icon":
			normal.bg_color = Color(0.14, 0.17, 0.24, 0.55)
			normal.border_color = Color(1.0, 1.0, 1.0, 0.08)
			normal.content_margin_left = 6
			normal.content_margin_right = 6
			normal.content_margin_top = 4
			normal.content_margin_bottom = 4
			
			hover.bg_color = Color(0.20, 0.25, 0.35, 0.85)
			hover.border_color = Color(1.0, 1.0, 1.0, 0.20)
			
			pressed.bg_color = Color(0.11, 0.13, 0.18, 0.95)
		_: # "secondary" (Default Glass)
			normal.bg_color = Color(0.13, 0.16, 0.23, 0.65)
			normal.border_color = Color(1.0, 1.0, 1.0, 0.09)
			normal.shadow_size = 2
			normal.shadow_color = Color(0, 0, 0, 0.18)
			normal.shadow_offset = Vector2(0, 1)
			
			hover.bg_color = Color(0.18, 0.23, 0.32, 0.85)
			hover.border_color = Color(1.0, 1.0, 1.0, 0.18)
			
			pressed.bg_color = Color(0.10, 0.12, 0.17, 0.95)
			font_color = Color(0.90, 0.93, 0.98)
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_color_override("font_color", font_color)

