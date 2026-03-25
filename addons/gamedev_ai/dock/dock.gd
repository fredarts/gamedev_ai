@tool
extends VBoxContainer

var gemini_client
var context_manager
var _tool_executor
var _memory_manager
var locale_manager

# Scene node references (unique names from dock.tscn)
@onready var chat_scroll: ScrollContainer = %ChatScrollContainer
@onready var chat_vbox: VBoxContainer = %ChatVBox
var _current_bubble: RichTextLabel = null
var _current_role: String = ""
var _bubble_map: Dictionary = {}
@onready var input_field: TextEdit = %InputField
@onready var send_button: Button = %SendButton
@onready var magic_actions_btn: MenuButton = %MagicActionsBtn
@onready var prompt_settings_btn: MenuButton = %PromptSettingsBtn
@onready var selection_status: Label = %SelectionStatus
@onready var history_button: MenuButton = %HistoryButton
@onready var summarize_btn: Button = %SummarizeBtn
@onready var new_chat_button: Button = %NewChatButton
var watch_mode_enabled: bool = false
var plan_first_enabled: bool = false
var context_enabled: bool = true
var screenshot_enabled: bool = false
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

@onready var git_tab: VBoxContainer = $TabContainer/Git
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

var _cached_tts_text: String = ""
var _cached_tts_stream: AudioStreamWAV = null

var git_manager
var _is_generating_commit: bool = false
var _last_ai_response_text: String = ""
var _is_dragging_tts_slider: bool = false
var _enhance_http: HTTPRequest
var _enhanced_text: String = ""

var _attached_files: Array[Dictionary] = []
var _dropped_files: Array[String] = []
var _history_ids: Array = []

var _next_block_id: int = 0
var _block_data: Dictionary = {}
var _chat_log_bbcode: String = ""

var presets: Dictionary = {}
var active_preset_name: String = ""

var _last_log_size: int = 0
var _ignore_next_error: bool = false
var _watch_fix_count: int = 0
var _watch_cooldown_until: float = 0.0
const _WATCH_MAX_FIXES: int = 3
const _WATCH_COOLDOWN_SECS: float = 30.0

var batch_queue: Array = []
var batch_results: Array = []
var current_tool_context: Dictionary = {}
var _is_stopped: bool = false
var _confirm_dialog: ConfirmationDialog
var _batch_total: int = 0
var _plan_pending: bool = false

# Precompiled regex for markdown parser
var _regex_bold_italic: RegEx
var _regex_bold: RegEx
var _regex_italic: RegEx
var _regex_code: RegEx
var _regex_suggest: RegEx

var _copy_popup: PopupMenu
var _floating_copy_btn: Button
var command_popup: PopupMenu

signal preset_changed(config)
signal settings_updated()

func _ready():
	# Initialize locale manager FIRST before any UI updates
	var settings = EditorInterface.get_editor_settings()
	var LocaleMgr = preload("res://addons/gamedev_ai/locale_manager.gd")
	locale_manager = LocaleMgr.new()
	var saved_locale = ""
	if settings.has_setting("gamedev_ai/language"):
		saved_locale = settings.get_setting("gamedev_ai/language")
	if saved_locale != "":
		locale_manager.set_locale(saved_locale)
	
	# Connect scene node signals
	magic_actions_btn.get_popup().id_pressed.connect(_on_magic_action_id_pressed)
	prompt_settings_btn.get_popup().id_pressed.connect(_on_prompt_setting_id_pressed)
	
	# Close other popups when one opens
	magic_actions_btn.get_popup().about_to_popup.connect(func(): prompt_settings_btn.get_popup().hide())
	prompt_settings_btn.get_popup().about_to_popup.connect(func(): magic_actions_btn.get_popup().hide())
	
	init_repo_btn.pressed.connect(_on_init_repo_pressed)
	set_remote_btn.pressed.connect(_on_set_remote_pressed)
	pull_btn.pressed.connect(_on_pull_pressed)
	refresh_git_btn.pressed.connect(_update_git_status)
	auto_generate_commit_btn.pressed.connect(_on_auto_generate_commit_pressed)
	commit_sync_btn.pressed.connect(_on_commit_sync_pressed)
	
	checkout_branch_btn.pressed.connect(_on_checkout_branch_pressed)
	undo_changes_btn.pressed.connect(func(): undo_confirm_dialog.popup_centered())
	force_pull_btn.pressed.connect(func(): force_pull_confirm_dialog.popup_centered())
	force_push_btn.pressed.connect(func(): force_push_confirm_dialog.popup_centered())
	
	undo_confirm_dialog.confirmed.connect(_on_undo_changes_confirmed)
	force_pull_confirm_dialog.confirmed.connect(_on_force_pull_confirmed)
	force_push_confirm_dialog.confirmed.connect(_on_force_push_confirmed)
	
	tts_play_btn.pressed.connect(_on_tts_play_pressed)
	tts_stop_btn.pressed.connect(_on_tts_stop_pressed)
	tts_speed_selector.item_selected.connect(_on_tts_speed_changed)
	tts_player.finished.connect(_on_tts_finished)
	
	tts_seek_slider.drag_started.connect(func(): _is_dragging_tts_slider = true)
	tts_seek_slider.drag_ended.connect(func(changed):
		_is_dragging_tts_slider = false
		if changed and tts_player.playing:
			tts_player.seek(tts_seek_slider.value)
	)
	# Setup speed selector
	tts_speed_selector.add_item("1.0x", 0)
	tts_speed_selector.add_item("1.25x", 1)
	tts_speed_selector.add_item("1.5x", 2)
	tts_speed_selector.add_item("2.0x", 3)
	
	%ExecutePlanBtn.pressed.connect(_on_execute_plan_pressed)
	
	send_button.pressed.connect(_on_send_pressed)
	input_field.gui_input.connect(_on_input_gui_input)
	input_field.text_changed.connect(_on_input_text_changed)
	
	command_popup = PopupMenu.new()
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.11, 0.12, 0.15, 0.98)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.3, 0.5, 0.9, 0.6)
	panel_style.border_blend = true
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 12
	panel_style.content_margin_left = 6
	panel_style.content_margin_right = 6
	panel_style.content_margin_top = 6
	panel_style.content_margin_bottom = 6
	command_popup.add_theme_stylebox_override("panel", panel_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.2, 0.3, 0.5, 0.8)
	hover_style.corner_radius_top_left = 4
	hover_style.corner_radius_top_right = 4
	hover_style.corner_radius_bottom_left = 4
	hover_style.corner_radius_bottom_right = 4
	command_popup.add_theme_stylebox_override("hover", hover_style)
	
	command_popup.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	command_popup.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	command_popup.transparent_bg = true
	
	add_child(command_popup)
	command_popup.id_pressed.connect(_on_command_selected)
	
	add_file_btn.pressed.connect(func(): _add_file_dialog.popup_centered())
	_add_file_dialog.file_selected.connect(_on_add_file_selected)
	_file_clear_btn.pressed.connect(_on_clear_dropped_files)
	_apply_diff_btn.pressed.connect(_on_apply_diff_pressed)
	_skip_diff_btn.pressed.connect(_on_skip_diff_pressed)
	
	# Enable drag and drop across the main chat interface
	input_field.set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)
	chat_scroll.set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)
	
	chat_preset_selector.item_selected.connect(_on_chat_preset_selected)
	font_size_minus_btn.pressed.connect(_on_font_minus_pressed)
	font_size_plus_btn.pressed.connect(_on_font_plus_pressed)
	
	preset_selector.item_selected.connect(_on_preset_selected)
	$TabContainer/Settings/PresetBar/AddPresetBtn.pressed.connect(_on_add_preset_pressed)
	edit_preset_btn.pressed.connect(_on_edit_preset_pressed)
	$TabContainer/Settings/PresetBar/DelPresetBtn.pressed.connect(_on_delete_preset_pressed)
	close_edit_btn.pressed.connect(_on_close_edit_pressed)
	preset_name_input.text_submitted.connect(_on_rename_preset)
	preset_name_input.focus_exited.connect(func(): _on_rename_preset(preset_name_input.text))
	provider_selector.item_selected.connect(_on_provider_type_changed)
	api_input.text_changed.connect(_on_config_changed)
	model_input.text_changed.connect(_on_config_changed)
	url_input.text_changed.connect(_on_config_changed)
	
	new_chat_button.pressed.connect(_on_new_chat_pressed)
	summarize_btn.pressed.connect(_on_summarize_pressed)
	history_button.get_popup().about_to_popup.connect(_on_history_popup_about_to_show)
	history_button.get_popup().id_pressed.connect(_on_history_item_pressed)
	
	var GitManager = preload("res://addons/gamedev_ai/git_manager.gd")
	git_manager = GitManager.new()
	$TabContainer.tab_changed.connect(_on_tab_changed)
	_update_git_status()
	
	# Add provider options
	provider_selector.add_item("Gemini", 0)
	provider_selector.add_item("OpenAI / OpenRouter", 1)
	
	# Polling timer
	$PollTimer.timeout.connect(_on_poll_timer_timeout)
	
	# Load saved custom prompt
	if settings.has_setting("gamedev_ai/custom_system_prompt"):
		custom_prompt_input.text = settings.get_setting("gamedev_ai/custom_system_prompt")
	custom_prompt_input.text_changed.connect(_on_custom_prompt_changed)
	
	# Vector DB UI
	scan_changes_btn.pressed.connect(_on_scan_changes_pressed)
	index_codebase_btn.pressed.connect(_on_index_codebase_pressed)
	index_confirm_dialog.confirmed.connect(_on_index_confirmed)
	enhance_prompt_btn.pressed.connect(_on_enhance_prompt_pressed)
	enhance_preview_dialog.confirmed.connect(_on_enhance_accepted)
	
	# Initial sync of instructions if client is already set
	if gemini_client:
		gemini_client.custom_instructions = custom_prompt_input.text
	
	_load_presets()
	
	_populate_language_selector()
	language_selector.item_selected.connect(_on_language_changed)
	_apply_locale()
	
	# Sync initial language with provider
	if gemini_client:
		gemini_client.response_language_instruction = locale_manager.get_ai_language_instruction()
	
	# Precompile regex for markdown parser
	_regex_bold_italic = RegEx.new()
	_regex_bold_italic.compile("\\*\\*\\*(.+?)\\*\\*\\*")
	_regex_bold = RegEx.new()
	_regex_bold.compile("\\*\\*(.+?)\\*\\*")
	_regex_italic = RegEx.new()
	_regex_italic.compile("(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)")
	_regex_code = RegEx.new()
	_regex_code.compile("`([^`]+)`")
	_regex_suggest = RegEx.new()
	_regex_suggest.compile("\\[SUGGEST:\\s*(.+?)\\]")
	
	# meta_clicked is now connected per-bubble in _create_chat_bubble()
	
	var fs = EditorInterface.get_resource_filesystem()
	if fs and not fs.filesystem_changed.is_connected(_on_filesystem_changed):
		fs.filesystem_changed.connect(_on_filesystem_changed)
	
	# Apply custom visual theme
	_apply_custom_theme()

	_setup_copy_features()


func setup(client, manager, executor):
	context_manager = manager
	_tool_executor = executor
	_tool_executor.tool_output.connect(_on_tool_output)
	_tool_executor.confirmation_needed.connect(_on_confirmation_needed)
	_tool_executor.diff_preview_requested.connect(_on_diff_preview_requested)
	_tool_executor.image_captured.connect(_on_image_captured)
	_tool_executor.init_vector_db(self)
	_tool_executor.vector_db.db_output.connect(_on_vector_db_output)
	
	# Create destructive action confirmation dialog
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "Confirm Destructive Action"
	_confirm_dialog.ok_button_text = "Yes, proceed"
	_confirm_dialog.cancel_button_text = "Cancel"
	_confirm_dialog.confirmed.connect(_on_destructive_confirmed)
	_confirm_dialog.canceled.connect(_on_destructive_cancelled)
	add_child(_confirm_dialog)
	
	_set_client(client)

func _set_client(client):
	# Disconnect old client if exists
	if gemini_client:
		if gemini_client.response_received.is_connected(_on_ai_response):
			gemini_client.response_received.disconnect(_on_ai_response)
		if gemini_client.error_occurred.is_connected(_on_ai_error):
			gemini_client.error_occurred.disconnect(_on_ai_error)
		if gemini_client.tool_call_received.is_connected(_on_tool_calls):
			gemini_client.tool_call_received.disconnect(_on_tool_calls)
		if gemini_client.status_changed.is_connected(_on_status_changed):
			gemini_client.status_changed.disconnect(_on_status_changed)
		if gemini_client.has_signal("audio_received") and gemini_client.audio_received.is_connected(_on_audio_received):
			gemini_client.audio_received.disconnect(_on_audio_received)
		if gemini_client.token_usage_reported.is_connected(_on_token_usage):
			gemini_client.token_usage_reported.disconnect(_on_token_usage)
	
	gemini_client = client
	
	if gemini_client:
		gemini_client.response_received.connect(_on_ai_response)
		gemini_client.audio_received.connect(_on_audio_received)
		gemini_client.error_occurred.connect(_on_ai_error)
		gemini_client.tool_call_received.connect(_on_tool_calls)
		gemini_client.status_changed.connect(_on_status_changed)
		gemini_client.token_usage_reported.connect(_on_token_usage)
		if custom_prompt_input:
			gemini_client.custom_instructions = custom_prompt_input.text

func _load_presets():
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("gamedev_ai/presets"):
		presets = settings.get_setting("gamedev_ai/presets")
	
	if presets.is_empty():
		# Default preset
		presets["Gemini Default"] = {
			"provider": 0,
			"api_key": "",
			"base_url": "",
			"model_name": ""
		}
	
	_update_preset_selector()
	
	if settings.has_setting("gamedev_ai/active_preset"):
		active_preset_name = settings.get_setting("gamedev_ai/active_preset")
		if not presets.has(active_preset_name):
			active_preset_name = presets.keys()[0]
	else:
		active_preset_name = presets.keys()[0]
	
	var idx = 0
	for i in range(preset_selector.item_count):
		if preset_selector.get_item_text(i) == active_preset_name:
			idx = i
			break
	preset_selector.selected = idx
	chat_preset_selector.selected = idx
	_on_preset_selected(idx)

func _update_preset_selector():
	preset_selector.clear()
	chat_preset_selector.clear()
	for p_name in presets.keys():
		preset_selector.add_item(p_name)
		chat_preset_selector.add_item(p_name)

func _save_presets():
	var settings = EditorInterface.get_editor_settings()
	settings.set_setting("gamedev_ai/presets", presets)
	settings.set_setting("gamedev_ai/active_preset", active_preset_name)

func _on_preset_selected(index: int):
	active_preset_name = preset_selector.get_item_text(index)
	var config = presets[active_preset_name]
	
	preset_name_input.text = active_preset_name
	provider_selector.selected = config["provider"]
	settings_bar.visible = (config["provider"] == 1)
	api_input.text = config["api_key"]
	url_input.text = config["base_url"]
	model_input.text = config["model_name"]
	
	# Sync chat selector
	chat_preset_selector.selected = index
	
	_save_presets()
	preset_changed.emit(config)

func _on_chat_preset_selected(index: int):
	preset_selector.selected = index
	_on_preset_selected(index)

func _on_add_preset_pressed():
	var new_name = "New Preset " + str(presets.size() + 1)
	presets[new_name] = {
		"provider": 0,
		"api_key": "",
		"base_url": "",
		"model_name": ""
	}
	_update_preset_selector()
	for i in range(preset_selector.item_count):
		if preset_selector.get_item_text(i) == new_name:
			preset_selector.selected = i
			_on_preset_selected(i)
			break
	preset_edit_panel.visible = true

func _on_edit_preset_pressed():
	preset_edit_panel.visible = true

func _on_close_edit_pressed():
	_on_rename_preset(preset_name_input.text)
	preset_edit_panel.visible = false

var _current_font_size: int = 14

func _on_font_minus_pressed():
	_current_font_size = max(10, _current_font_size - 2)
	_apply_font_size()

func _on_font_plus_pressed():
	_current_font_size = min(32, _current_font_size + 2)
	_apply_font_size()

func _apply_font_size():
	for bubble in chat_vbox.get_children():
		_apply_font_size_recursive(bubble)

func _apply_font_size_recursive(node: Node):
	if node is RichTextLabel:
		node.add_theme_font_size_override("normal_font_size", _current_font_size)
		node.add_theme_font_size_override("bold_font_size", _current_font_size)
		node.add_theme_font_size_override("italics_font_size", _current_font_size)
		node.add_theme_font_size_override("bold_italics_font_size", _current_font_size)
		node.add_theme_font_size_override("mono_font_size", _current_font_size)
	for child in node.get_children():
		_apply_font_size_recursive(child)

func _on_delete_preset_pressed():
	if presets.size() <= 1:
		return
	presets.erase(active_preset_name)
	_load_presets()

func _on_provider_type_changed(index: int):
	presets[active_preset_name]["provider"] = index
	settings_bar.visible = (index == 1)
	_save_presets()
	preset_changed.emit(presets[active_preset_name])

func _on_rename_preset(new_name: String):
	new_name = new_name.strip_edges()
	if new_name == "" or new_name == active_preset_name:
		preset_name_input.text = active_preset_name
		return
	
	if presets.has(new_name):
		# Name already exists, revert
		preset_name_input.text = active_preset_name
		return
		
	var config = presets[active_preset_name]
	presets.erase(active_preset_name)
	presets[new_name] = config
	active_preset_name = new_name
	
	_update_preset_selector()
	# Reselect in the list
	for i in range(preset_selector.item_count):
		if preset_selector.get_item_text(i) == active_preset_name:
			preset_selector.selected = i
			break
			
	_save_presets()

func _on_config_changed(_text: String = ""):
	presets[active_preset_name]["api_key"] = api_input.text
	presets[active_preset_name]["base_url"] = url_input.text
	presets[active_preset_name]["model_name"] = model_input.text
	_save_presets()
	settings_updated.emit()

func _populate_language_selector():
	language_selector.clear()
	var locales = locale_manager.get_available_locales()
	var current = locale_manager.get_locale()
	for i in range(locales.size()):
		language_selector.add_item(locales[i]["name"], i)
		if locales[i]["code"] == current:
			language_selector.selected = i

func _on_language_changed(index: int):
	var locales = locale_manager.get_available_locales()
	if index >= 0 and index < locales.size():
		locale_manager.set_locale(locales[index]["code"])
		var settings = EditorInterface.get_editor_settings()
		settings.set_setting("gamedev_ai/language", locales[index]["code"])
		_apply_locale()
		# Update AI response language
		if gemini_client:
			var lang_instruction = locale_manager.get_ai_language_instruction()
			gemini_client.response_language_instruction = lang_instruction

func _apply_locale():
	if not locale_manager:
		return
	var L = locale_manager
	# Chat tab buttons
	send_button.tooltip_text = L.tr("tt_send")
	add_file_btn.text = "" # Icon only
	add_file_btn.tooltip_text = L.tr("tt_attach")
	new_chat_button.text = "" # Icon only
	new_chat_button.tooltip_text = L.tr("new_chat")
	summarize_btn.text = "" # Icon only
	summarize_btn.tooltip_text = L.tr("tt_summarize_memory") if L.has_method("has_message") and L.has_message("tt_summarize_memory") else "Summarize to Memory"
	history_button.text = "" # Icon only
	history_button.tooltip_text = L.tr("history")
	
	magic_actions_btn.text = L.tr("magic_actions") if L.has_message("magic_actions") else "Magic Actions"
	prompt_settings_btn.text = L.tr("prompt_settings") if L.has_message("prompt_settings") else "Prompt Settings"
	
	selection_status.text = L.tr("no_selection")
	input_field.placeholder_text = L.tr("input_placeholder")
	execute_plan_btn.text = L.tr("run_plan")
	
	# Prompt Settings Menu items
	var p_popup = prompt_settings_btn.get_popup()
	p_popup.set_item_text(0, L.tr("context"))
	p_popup.set_item_text(1, L.tr("screenshot"))
	p_popup.set_item_text(2, L.tr("plan_first"))
	p_popup.set_item_text(3, L.tr("watch_mode"))
	
	# TTS
	if not tts_player.playing and not tts_player.stream_paused:
		tts_play_btn.text = L.tr("tts_read_aloud")
	
	# Settings tab
	$TabContainer/Settings/PresetBar/PresetLabel.text = L.tr("preset_label")
	$TabContainer/Settings/PresetBar/AddPresetBtn.text = L.tr("add")
	edit_preset_btn.text = L.tr("edit")
	$TabContainer/Settings/PresetBar/DelPresetBtn.text = L.tr("delete")
	close_edit_btn.text = L.tr("done_editing")
	$TabContainer/Settings/PresetEditPanel/ConfigGrid/NameLabel.text = L.tr("preset_name_label")
	$TabContainer/Settings/PresetEditPanel/ConfigGrid/ProviderLabel.text = L.tr("provider_label")
	$TabContainer/Settings/PresetEditPanel/ConfigGrid/ApiLabel.text = L.tr("api_key_label")
	$TabContainer/Settings/PresetEditPanel/ConfigGrid/ModelLabel.text = L.tr("model_name_label")
	$TabContainer/Settings/PresetEditPanel/SettingsBar/UrlLabel.text = L.tr("base_url_label")
	language_label.text = L.tr("language_label")
	$TabContainer/Settings/CustomPromptLabel.text = L.tr("custom_instructions_label")
	custom_prompt_input.placeholder_text = L.tr("custom_instructions_placeholder")
	
	# Git tab
	init_repo_btn.text = L.tr("initialize_repo")
	init_repo_btn.tooltip_text = L.tr("tt_init_repo")
	$TabContainer/Git/RemoteContainer/Label.text = L.tr("github_url_label")
	set_remote_btn.text = L.tr("save")
	set_remote_btn.tooltip_text = L.tr("tt_set_remote")
	pull_btn.text = L.tr("pull")
	pull_btn.tooltip_text = L.tr("tt_pull")
	refresh_git_btn.text = L.tr("refresh_status")
	refresh_git_btn.tooltip_text = L.tr("tt_refresh_git")
	auto_generate_commit_btn.text = L.tr("auto_generate_commit")
	auto_generate_commit_btn.tooltip_text = L.tr("tt_auto_generate_commit")
	commit_msg_input.placeholder_text = L.tr("commit_msg_placeholder")
	commit_sync_btn.text = L.tr("commit_sync")
	commit_sync_btn.tooltip_text = L.tr("tt_commit_sync")
	checkout_branch_btn.text = L.tr("create_switch")
	checkout_branch_btn.tooltip_text = L.tr("tt_checkout_branch")
	undo_changes_btn.text = L.tr("undo_uncommitted")
	undo_changes_btn.tooltip_text = L.tr("tt_undo_changes")
	force_pull_btn.text = L.tr("force_pull")
	force_pull_btn.tooltip_text = L.tr("tt_force_pull")
	force_push_btn.text = L.tr("force_push")
	force_push_btn.tooltip_text = L.tr("tt_force_push")
	
	# Diff preview
	$TabContainer/Chat/DiffPreviewPanel/DiffLabel.text = L.tr("diff_preview_label")
	_apply_diff_btn.text = L.tr("apply_changes")
	_skip_diff_btn.text = L.tr("skip")
	
	# Confirmation dialogs
	undo_confirm_dialog.title = L.tr("undo_confirm_title")
	undo_confirm_dialog.dialog_text = L.tr("undo_confirm_text")
	force_pull_confirm_dialog.title = L.tr("force_pull_confirm_title")
	force_pull_confirm_dialog.dialog_text = L.tr("force_pull_confirm_text")
	force_push_confirm_dialog.title = L.tr("force_push_confirm_title")
	force_push_confirm_dialog.dialog_text = L.tr("force_push_confirm_text")

func _on_new_chat_pressed():
	if gemini_client:
		gemini_client.new_session()
		_clear_chat()
		_add_to_chat("\n[color=gray]" + locale_manager.tr("new_chat_started") + "[/color]\n")
		_update_ui_state(false)

func _on_summarize_pressed():
	_process_send("Por favor, analise as decisões arquiteturais que tomamos nesta conversa e use a ferramenta save_memory para armazenar os pontos-chave.")

func _on_history_popup_about_to_show():
	_refresh_history_list()

func _refresh_history_list():
	var popup = history_button.get_popup()
	popup.clear()
	_history_ids = gemini_client.list_sessions()
	for i in range(_history_ids.size()):
		var session = _history_ids[i]
		popup.add_item(session.title, i)

func _on_history_item_pressed(id: int):
	var session = _history_ids[id]
	if gemini_client.load_session(session.id):
		_rebuild_chat_from_transcript()
		_add_to_chat("\n[color=gray]" + locale_manager.tr("chat_loaded") + session.title + " ---[/color]\n")

func _rebuild_chat_from_transcript():
	_clear_chat()
	for entry in gemini_client.transcript:
		if entry.role == "user":
			_log_user_message(entry.text)
		else:
			_add_to_chat("\n[b]Response:[/b]\n")
			_add_to_chat(_markdown_to_bbcode(entry.text) + "\n")

func _on_status_changed(is_requesting: bool):
	_update_ui_state(is_requesting)

func _update_ui_state(busy: bool):
	input_field.editable = !busy
	var icon_path = "res://addons/gamedev_ai/assets/icons/"
	if busy:
		send_button.text = ""
		send_button.icon = _load_svg_icon(icon_path + "stop.svg", "ffffff")
		send_button.tooltip_text = locale_manager.tr("stop") if locale_manager else "Stop"
		_style_danger_button(send_button, 20)
	else:
		send_button.text = ""
		send_button.icon = _load_svg_icon(icon_path + "send.svg", "ffffff")
		send_button.tooltip_text = locale_manager.tr("tt_send") if locale_manager else "Send"
		_style_solid_button(send_button, Color(0.15, 0.6, 0.35), 20)

func _on_send_pressed():
	if gemini_client and gemini_client.is_requesting:
		_stop_ai()
		return
	var text = input_field.text.strip_edges()
	if text.is_empty() and _attached_files.is_empty():
		return
		
	_process_send(text)


func _on_execute_plan_pressed():
	execute_plan_btn.visible = false
	_plan_pending = false
	plan_first_enabled = false # Auto-disable to avoid loop
	prompt_settings_btn.get_popup().set_item_checked(2, false)
	_process_send("Okay, the plan looks good. Please execute the proposed plan now using the appropriate tools.", true)

func _on_magic_action_id_pressed(id: int):
	var L = locale_manager
	match id:
		0: _on_quick_action_pressed(L.tr("refactor") if L else "Refactor this code")
		1: _on_quick_action_pressed(L.tr("fix") if L else "Fix errors in this code")
		2: _on_quick_action_pressed(L.tr("explain") if L else "Explain what this code does")
		3: _on_undo_pressed()
		4: _on_fix_console_pressed()

func _on_prompt_setting_id_pressed(id: int):
	var popup = prompt_settings_btn.get_popup()
	var checked = !popup.is_item_checked(id)
	popup.set_item_checked(id, checked)
	
	match id:
		0: context_enabled = checked
		1: screenshot_enabled = checked
		2: plan_first_enabled = checked
		3: watch_mode_enabled = checked

func _on_quick_action_pressed(action_text: String):
	_process_send(action_text)

func _on_tts_play_pressed():
	if _last_ai_response_text.is_empty():
		return
		
	# Check if we already have the cache for this exact response
	if _cached_tts_text == _last_ai_response_text and _cached_tts_stream != null:
		if tts_player.playing:
			tts_player.stream_paused = true
			tts_play_btn.text = locale_manager.tr("tts_play") if locale_manager else "▶ Play"
		elif tts_player.stream_paused:
			tts_player.stream_paused = false
			tts_play_btn.text = locale_manager.tr("tts_pause") if locale_manager else "⏸ Pause"
		else:
			# Not playing, start from slider position
			var pos = tts_seek_slider.value
			tts_player.stream = _cached_tts_stream
			tts_player.play(pos)
			tts_play_btn.text = locale_manager.tr("tts_pause") if locale_manager else "⏸ Pause"
			tts_stop_btn.disabled = false
		return
		
	# No cache, request from API
	if gemini_client:
		tts_play_btn.disabled = true
		tts_play_btn.text = locale_manager.tr("tts_loading") if locale_manager else "⏳ Loading..."
		
		# Strip BBCode
		var regex = RegEx.new()
		regex.compile("\\[.*?\\]")
		var plain_text = regex.sub(_last_ai_response_text, "", true)
		
		_cached_tts_text = _last_ai_response_text
		gemini_client.request_tts(plain_text)
	else:
		print("Error: gemini_client is null!")

func _on_audio_received(raw_data: PackedByteArray):
	tts_play_btn.disabled = false
	tts_play_btn.text = locale_manager.tr("tts_pause") if locale_manager else "⏸ Pause"
	tts_stop_btn.disabled = false
	
	if raw_data.is_empty():
		return
		
	var audio_data = raw_data
	var sample_rate = 24000
	var channels = 1
	var bytes_per_sample = 2
	var is_16bit = true
	
	# Parse WAV RIFF Header to extract pure PCM and avoid the "glitch"
	if raw_data.size() > 44 and raw_data.slice(0, 4) == "RIFF".to_ascii_buffer() and raw_data.slice(8, 12) == "WAVE".to_ascii_buffer():
		channels = raw_data.decode_u16(22)
		sample_rate = raw_data.decode_u32(24)
		var bits_per_sample = raw_data.decode_u16(34)
		
		is_16bit = (bits_per_sample == 16)
		bytes_per_sample = bits_per_sample / 8
		
		# Find the "data" subchunk dynamically
		var data_idx = 12
		while data_idx < raw_data.size() - 8:
			var chunk_id = raw_data.slice(data_idx, data_idx + 4)
			var chunk_size = raw_data.decode_u32(data_idx + 4)
			if chunk_id == "data".to_ascii_buffer():
				audio_data = raw_data.slice(data_idx + 8, data_idx + 8 + chunk_size)
				break
			data_idx += 8 + chunk_size
			
	var stream = AudioStreamWAV.new()
	stream.data = audio_data
	stream.format = AudioStreamWAV.FORMAT_16_BITS if is_16bit else AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = (channels == 2)
	
	_cached_tts_stream = stream
	tts_player.stream = stream
	tts_player.play()
	
	# Compute exact length in seconds
	var length_seconds = float(audio_data.size()) / float(sample_rate * channels * bytes_per_sample)
	tts_seek_slider.max_value = length_seconds
	tts_seek_slider.value = 0.0

func _on_tts_stop_pressed():
	tts_player.stop()
	tts_player.stream_paused = false
	tts_play_btn.text = locale_manager.tr("tts_play") if locale_manager else "▶ Play"
	tts_seek_slider.value = 0.0
	tts_stop_btn.disabled = true

func _on_tts_seek_changed(_value: float):
	pass # Logic moved to drag signals

func _on_tts_speed_changed(index: int):
	var speeds = [1.0, 1.25, 1.5, 2.0]
	tts_player.pitch_scale = speeds[index]

func _on_tts_finished():
	tts_play_btn.text = locale_manager.tr("tts_play") if locale_manager else "▶ Play"
	tts_stop_btn.disabled = true
	tts_seek_slider.value = 0.0

func _process(_delta):
	if tts_player.playing and not _is_dragging_tts_slider:
		tts_seek_slider.set_value_no_signal(tts_player.get_playback_position())

func _stop_ai():
	_is_stopped = true
	batch_queue.clear()
	batch_results.clear()
	current_tool_context = {}
	if gemini_client:
		gemini_client.cancel_request()
		
	if _diff_preview_panel and _diff_preview_panel.visible:
		_diff_preview_panel.visible = false
		chat_scroll.visible = true
		if _tool_executor and _tool_executor.has_method("cancel_pending_action"):
			_tool_executor.cancel_pending_action()
			
	_add_to_chat("\n[color=orange][b]" + locale_manager.tr("ai_stopped") + "[/b][/color]\n")
	_update_ui_state(false)

func _on_input_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER and event.shift_pressed:
			input_field.get_viewport().set_input_as_handled()
			var text = input_field.text.strip_edges()
			if text.is_empty() and _attached_files.is_empty():
				return
			_process_send(text)
		elif event.keycode == KEY_V and event.ctrl_pressed:
			var clipboard_image = DisplayServer.clipboard_get_image()
			if clipboard_image and not clipboard_image.is_empty():
				input_field.get_viewport().set_input_as_handled()
				var img_buffer = clipboard_image.save_png_to_buffer()
				_attached_files.append({
					"type": "image",
					"filename": "clipboard.png",
					"mime_type": "image/png",
					"image_obj": clipboard_image,
					"raw_bytes": img_buffer
				})
				_refresh_thumbnails()
				_add_to_chat("\n[color=green][i]" + locale_manager.tr("image_pasted") + "[/i][/color]\n")

const SLASH_COMMANDS = [
	"/brainstorm", "/plan", "/debug", "/create", "/deploy", 
	"/enhance", "/orchestrate", "/preview", "/status", "/test"
]

func _on_input_text_changed():
	var text = input_field.text
	var caret_line = input_field.get_caret_line()
	var caret_col = input_field.get_caret_column()
	
	var lines = text.split("\n")
	if lines.size() <= caret_line: return
	var line_text = lines[caret_line]
	var text_before_caret = line_text.substr(0, caret_col)
	
	var last_space_idx = text_before_caret.rfind(" ")
	var current_word = ""
	if last_space_idx == -1:
		current_word = text_before_caret
	else:
		current_word = text_before_caret.substr(last_space_idx + 1)
	
	if current_word.begins_with("/") and current_word.length() > 0:
		_show_command_suggestions(current_word)
	else:
		command_popup.hide()

func _show_command_suggestions(prefix: String):
	command_popup.clear()
	var matches = []
	for cmd in SLASH_COMMANDS:
		if cmd.begins_with(prefix):
			matches.append(cmd)
	
	if matches.is_empty():
		command_popup.hide()
		return
		
	for i in range(matches.size()):
		command_popup.add_item(matches[i], i)
		
	var caret_pos = input_field.get_caret_draw_pos()
	var global_pos = input_field.global_position + caret_pos + Vector2(0, 24)
	
	var popup_rect = Rect2i(int(global_pos.x), int(global_pos.y), 200, matches.size() * 32)
	command_popup.popup(popup_rect)

func _on_command_selected(id: int):
	var selected_cmd = command_popup.get_item_text(id)
	
	var text = input_field.text
	var caret_line = input_field.get_caret_line()
	var caret_col = input_field.get_caret_column()
	
	var lines = text.split("\n")
	var line_text = lines[caret_line]
	var text_before_caret = line_text.substr(0, caret_col)
	var text_after_caret = line_text.substr(caret_col)
	
	var last_space_idx = text_before_caret.rfind(" ")
	var new_line_text = ""
	if last_space_idx == -1:
		new_line_text = selected_cmd + " " + text_after_caret
	else:
		new_line_text = text_before_caret.substr(0, last_space_idx + 1) + selected_cmd + " " + text_after_caret
		
	lines[caret_line] = new_line_text
	input_field.text = "\n".join(lines)
	
	var new_col = (last_space_idx + 1 if last_space_idx != -1 else 0) + selected_cmd.length() + 1
	input_field.set_caret_line(caret_line)
	input_field.set_caret_column(new_col)
	
	command_popup.hide()
	input_field.grab_focus()

func _on_add_file_selected(path: String):
	var ext = path.get_extension().to_lower()
	var filename = path.get_file()
	
	if ext in ["png", "jpg", "jpeg", "webp"]:
		var img = Image.new()
		var err = img.load(path)
		if err == OK:
			var file = FileAccess.open(path, FileAccess.READ)
			var bytes = file.get_buffer(file.get_length())
			var mime = "image/" + ("jpeg" if ext in ["jpg", "jpeg"] else ext)
			
			_attached_files.append({
				"type": "image",
				"filename": filename,
				"mime_type": mime,
				"image_obj": img,
				"raw_bytes": bytes
			})
			_refresh_thumbnails()
			_add_to_chat("\n[color=green][i]" + locale_manager.tr("image_attached") + filename + "[/i][/color]\n")
		else:
			_add_to_chat("\n[color=red]" + locale_manager.tr("failed_load_image") + path + "[/color]\n")
	elif ext in ["txt", "md", "csv", "json", "gd"]:
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			_attached_files.append({
				"type": "text",
				"filename": filename,
				"text_content": content
			})
			_refresh_thumbnails()
			_add_to_chat("\n[color=green][i]" + locale_manager.tr("text_file_attached") + filename + "[/i][/color]\n")
	elif ext in ["pdf", "mp3", "wav", "ogg"]:
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var bytes = file.get_buffer(file.get_length())
			var mime = "application/pdf" if ext == "pdf" else "audio/" + ("mpeg" if ext == "mp3" else ext)
			_attached_files.append({
				"type": "binary",
				"filename": filename,
				"mime_type": mime,
				"raw_bytes": bytes
			})
			_refresh_thumbnails()
			_add_to_chat("\n[color=green][i]" + locale_manager.tr("file_attached") + filename + "[/i][/color]\n")

func _on_image_captured(path: String):
	if FileAccess.file_exists(path):
		var img = Image.new()
		var err = img.load(path)
		if err == OK:
			var file = FileAccess.open(path, FileAccess.READ)
			var bytes = file.get_buffer(file.get_length())
			var filename = path.get_file()
			
			_attached_files.append({
				"type": "image",
				"filename": filename,
				"mime_type": "image/png",
				"image_obj": img,
				"raw_bytes": bytes
			})
			_refresh_thumbnails()
			var tr_text = locale_manager.tr("image_attached") if locale_manager else "Attached image: "
			_add_to_chat("\n[color=green][i]" + tr_text + filename + "[/i][/color]\n")
			
			_process_send("I have captured the screenshot of the editor. Please analyze it as per my previous request.", true)

func _refresh_thumbnails():
	for child in _thumbnail_list.get_children():
		child.queue_free()
		
	if _attached_files.is_empty():
		_image_preview_scroll.visible = false
		return
		
	_image_preview_scroll.visible = true
	
	for i in range(_attached_files.size()):
		var file_data = _attached_files[i]
		var container = Control.new()
		
		if file_data["type"] == "image":
			var img = file_data["image_obj"]
			var thumb_rect = TextureRect.new()
			thumb_rect.custom_minimum_size = Vector2(80, 80)
			var texture = ImageTexture.create_from_image(img)
			thumb_rect.texture = texture
			thumb_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			thumb_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			thumb_rect.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					_popup_texture_rect.texture = texture
					_image_popup_dialog.popup_centered()
			)
			thumb_rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			container.custom_minimum_size = Vector2(80, 80)
			container.add_child(thumb_rect)
		else:
			var panel = PanelContainer.new()
			panel.custom_minimum_size = Vector2(120, 80)
			var vbox = VBoxContainer.new()
			vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			var icon_label = Label.new()
			var is_audio = file_data["filename"].ends_with("mp3") or file_data["filename"].ends_with("wav") or file_data["filename"].ends_with("ogg")
			icon_label.text = "🎵" if is_audio else "📄"
			icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			var name_label = Label.new()
			name_label.text = file_data["filename"]
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_label.clip_text = true
			name_label.custom_minimum_size = Vector2(110, 0)
			vbox.add_child(icon_label)
			vbox.add_child(name_label)
			panel.add_child(vbox)
			container.custom_minimum_size = Vector2(120, 80)
			container.add_child(panel)
		
		var close_btn = Button.new()
		close_btn.text = "X"
		close_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		close_btn.size = Vector2(24, 24)
		close_btn.position = Vector2(container.custom_minimum_size.x - 24, 0)
		close_btn.add_theme_color_override("font_color", Color(1, 0, 0))
		close_btn.pressed.connect(func():
			_remove_attached_file(i)
		)
		
		container.add_child(close_btn)
		_thumbnail_list.add_child(container)

func _remove_attached_file(index: int):
	if index >= 0 and index < _attached_files.size():
		_attached_files.remove_at(index)
		_refresh_thumbnails()
		_add_to_chat("[i]" + locale_manager.tr("attachment_removed") + "[/i]\n")

func _is_game_running() -> bool:
	return EditorInterface.is_playing_scene()

func _process_send(prompt_text: String, is_execute_plan: bool = false):
	if _is_game_running():
		_add_to_chat("\n[color=orange][b]" + locale_manager.tr("game_running_warning") + "[/color]\n", "system")
		return
	_is_stopped = false
	_watch_fix_count = 0  # Reset watch mode counter on manual user message
	
	if not is_execute_plan:
		var est_tokens = int(prompt_text.length() / 4.0)
		_log_user_message(prompt_text, est_tokens)
		input_field.text = ""
	else:
		_add_to_chat("\n[color=cyan][b]" + locale_manager.tr("executing_plan") + "[/b][/color]\n")
	
	var selection = {}
	if context_manager:
		selection = context_manager.get_selection_info()
	
	var final_prompt = prompt_text
	if not selection.is_empty() and not is_execute_plan:
		final_prompt = "Selection Context (File: " + selection.path + "):\n```gdscript\n" + selection.text + "\n```\n\nCommand: " + prompt_text
		_add_to_chat("[i]Using selection from " + selection.path.get_file() + "...[/i]\n")

	if plan_first_enabled and not is_execute_plan:
		final_prompt += "\n\nCRITICAL INSTRUCTION: The user has enabled 'Plan First' mode. Do NOT output any tool calls to modify files yet. Instead, output a detailed, numbered step-by-step plan explaining exactly what tools you will use and what you will do. This is your planning phase."
		_plan_pending = true
	else:
		_plan_pending = false
		execute_plan_btn.visible = false

	var context = ""
	if context_enabled and context_manager:
		context += "Engine Info:\n" + context_manager.get_engine_version_context() + "\n"
		context += "Project Structure:\n" + context_manager.get_project_index() + "\n"
		context += "Project Settings:\n" + context_manager.get_project_settings_dump() + "\n"
		context += "Current Scene tree:\n" + context_manager.get_scene_tree_dump() + "\n"
		context += "Current Script content:\n" + context_manager.get_current_script() + "\n"
	
	# Inject persistent project memory
	if _memory_manager:
		var memory_text = _memory_manager.get_all_memories_formatted()
		if memory_text != "":
			context += "\n" + memory_text + "\n"
	
	# Add dropped files context
	if not _dropped_files.is_empty():
		context += "\n--- Additional File Context ---\n"
		for path in _dropped_files:
			if FileAccess.file_exists(path):
				var f = FileAccess.open(path, FileAccess.READ)
				if f:
					context += "File: " + path + "\n"
					context += f.get_as_text() + "\n\n"
	
	var files_data = []
	# Process attached files
	if not _attached_files.is_empty():
		for file in _attached_files:
			if file["type"] == "text":
				context += "\n--- Attached File: " + file["filename"] + " ---\n"
				context += file["text_content"] + "\n"
			elif file["type"] == "image":
				var encoded = _encode_image(file["image_obj"])
				files_data.append(encoded)
				if file.has("path"):
					context += "\n--- Image File: " + file["path"] + " ---\n"
			elif file["type"] == "binary":
				var base64 = Marshalls.raw_to_base64(file["raw_bytes"])
				files_data.append({
					"mime_type": file["mime_type"],
					"data": base64
				})
		_add_to_chat("[i]" + locale_manager.tr("sending_attachments") + "[/i]\n")
		_attached_files.clear()
		_refresh_thumbnails()
		
	# Fallback/append screenshot toggle
	if screenshot_enabled and context_manager:
		var scr = context_manager.get_editor_screenshot()
		if not scr.is_empty():
			files_data.append(scr)
			_add_to_chat("[i]" + locale_manager.tr("capturing_screenshot") + "[/i]\n")

	var tools = []
	if _tool_executor:
		tools = _tool_executor.get_tool_definitions()
	
	if gemini_client:
		gemini_client.send_prompt(final_prompt, context, tools, files_data)
		_add_to_chat("\n[i]" + locale_manager.tr("thinking") + "[/i]\n", "system")
		_on_clear_dropped_files()

func _encode_image(image: Image) -> Dictionary:
	var max_dim = 1024
	if image.get_width() > max_dim or image.get_height() > max_dim:
		var scale = float(max_dim) / max(image.get_width(), image.get_height())
		image.resize(int(image.get_width() * scale), int(image.get_height() * scale))
	
	var buffer = image.save_png_to_buffer()
	var base64 = Marshalls.raw_to_base64(buffer)
	return {
		"mime_type": "image/png",
		"data": base64
	}

func _on_poll_timer_timeout():
	# 1. Update Selection Status
	if context_manager:
		var selection = context_manager.get_selection_info()
		if not selection.is_empty():
			selection_status.text = locale_manager.tr("selection_prefix") + selection.path.get_file()
			selection_status.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2)) # Green
		else:
			selection_status.text = locale_manager.tr("no_selection")
			selection_status.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5)) # Gray
			
	# 2. Watch Mode Logic
	if watch_mode_enabled:
		_check_for_new_errors()

func _check_for_new_errors():
	var path = "user://logs/godot.log"
	if not FileAccess.file_exists(path): return
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var length = file.get_length()
	file.close()
	
	if _last_log_size == 0:
		_last_log_size = length # Initial sync, don't trigger on old errors
		return
		
	if length > _last_log_size:
		# Log has grown, read new content
		file = FileAccess.open(path, FileAccess.READ)
		file.seek(_last_log_size)
		var new_content = file.get_buffer(length - _last_log_size).get_string_from_utf8()
		file.close()
		_last_log_size = length
		
		# Check for errors in new content
		if "ERROR:" in new_content or "SCRIPT ERROR:" in new_content:
			if gemini_client and not gemini_client.is_requesting:
				# Rate limiting: max fixes and cooldown
				if _watch_fix_count >= _WATCH_MAX_FIXES:
					_add_to_chat("\n[color=orange][b]" + locale_manager.tr("watch_max_limit").replace("{max}", str(_WATCH_MAX_FIXES)) + "[/b][/color]\n")
					return
				
				var now = Time.get_unix_time_from_system()
				if now < _watch_cooldown_until:
					return  # Still in cooldown
				
				_watch_fix_count += 1
				_watch_cooldown_until = now + _WATCH_COOLDOWN_SECS
				_add_to_chat("\n[color=orange][b]" + locale_manager.tr("watch_error_detected").replace("{current}", str(_watch_fix_count)).replace("{max}", str(_WATCH_MAX_FIXES)) + "[/b][/color]\n")
				_process_send("I noticed a new error in the console:\n" + new_content + "\n\nPlease analyze and fix it.")

func _on_tool_calls(tool_calls: Array):
	batch_queue = tool_calls.duplicate()
	batch_results.clear()
	_batch_total = tool_calls.size()
	
	if not batch_queue.is_empty():
		var first_tool = batch_queue[0]
		var action_name = "AI Batch: " + first_tool.get("name", "Unknown")
		if _tool_executor.has_method("start_composite_action"):
			_tool_executor.start_composite_action(action_name)
			
		_process_next_batch_item()

func _process_next_batch_item():
	if _is_stopped:
		return
	if batch_queue.is_empty():
		return
		
	var call_data = batch_queue.pop_front()
	current_tool_context = call_data 
	
	var tool_name = call_data["name"]
	var args = call_data["args"]
	
	var step = _batch_total - batch_queue.size()
	var progress = "[" + str(step) + "/" + str(_batch_total) + "] " if _batch_total > 1 else ""
	
	var arg_str = str(args)
	if arg_str.length() > 100:
		_append_collapsible_block(progress + "Tool Call: " + tool_name, arg_str, "yellow", false)
	else:
		_add_to_chat("\n[color=yellow]" + progress + "Tool Call: " + tool_name + " " + arg_str + "[/color]\n")
		
	_tool_executor.execute_tool(tool_name, args)

func _on_tool_output(output: String):
	if _is_stopped:
		return
		
	var line_count = output.count("\n") + 1
	var label = "Tool Output " + ("(" + str(line_count) + " lines)" if line_count > 1 else "")
	_append_collapsible_block(label, output, "green", false)
	
	if not current_tool_context.is_empty():
		var tool_id = current_tool_context.get("id", "")
		var response_part = gemini_client.generate_tool_response(current_tool_context["name"], output, tool_id)
		batch_results.append(response_part)
		current_tool_context = {}
	
	if not batch_queue.is_empty():
		await get_tree().process_frame
		_process_next_batch_item()
	else:
		if gemini_client and not batch_results.is_empty():
			_add_to_chat("\n[i]" + locale_manager.tr("sending_batch_results") + "[/i]\n")
			var tools = []
			if _tool_executor:
				tools = _tool_executor.get_tool_definitions()
			gemini_client.send_tool_responses(batch_results, tools)
			batch_results.clear()
			
		if _tool_executor.has_method("commit_composite_action"):
			_tool_executor.commit_composite_action()

func _on_undo_pressed():
	if _tool_executor and _tool_executor.has_method("undo"):
		_tool_executor.undo()
		_add_to_chat("\n[i]" + locale_manager.tr("undoing_last") + "[/i]\n")

func _on_fix_console_pressed():
	var errors = _get_error_logs()
	if errors.is_empty():
		_add_to_chat("\n[i]" + locale_manager.tr("no_errors_found") + "[/i]\n")
		return
		
	var prompt = "Here are the errors from the current Godot session. Please analyze and fix them:\n\n" + errors
	_process_send(prompt)

func _get_error_logs() -> String:
	var path = "user://logs/godot.log"
	if not FileAccess.file_exists(path):
		return "Error: Log file not found at " + path + ". Please enable file logging in Project Settings."
		
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return "Error: Could not open log file."
		
	var content = file.get_as_text()
	file.close()
	
	var session_start_index = content.rfind("Godot Engine v")
	if session_start_index != -1:
		content = content.substr(session_start_index)
	
	var lines = content.split("\n")
	var unique_errors = {}
	var filtered_errors = []
	
	for line in lines:
		if "ERROR" in line or "SCRIPT ERROR" in line or "WARNING" in line:
			if not unique_errors.has(line):
				unique_errors[line] = true
				filtered_errors.append(line)
	
	if filtered_errors.is_empty():
		return ""
		
	return "\n".join(filtered_errors)

func _on_ai_response(response: String):
	if _is_stopped:
		return
	if _is_generating_commit:
		_is_generating_commit = false
		commit_msg_input.text = response.strip_edges()
		auto_generate_commit_btn.disabled = false
		return
		
	_last_ai_response_text = response
	
	# --- Fallback: detect tool calls embedded as text ---
	var extracted_calls = _extract_text_tool_calls(response)
	if not extracted_calls.is_empty():
		# Strip tool call text from the visible response
		var clean_response = _strip_tool_call_text(response)
		if clean_response.strip_edges() != "":
			pass
			_add_to_chat(_markdown_to_bbcode(clean_response) + "\n", "ai")
		_on_tool_calls(extracted_calls)
		return
	
	pass
	_add_to_chat(_markdown_to_bbcode(response) + "\n", "ai")
	
	if _plan_pending:
		execute_plan_btn.visible = true

func _extract_text_tool_calls(text: String) -> Array:
	var calls = []
	
	# Pattern 1: <tool_call>{"arguments": {}, "name": "tool_name"}</tool_call>
	var regex1 = RegEx.new()
	regex1.compile("<tool_call>\\s*([\\s\\S]*?)\\s*</tool_call>")
	var matches1 = regex1.search_all(text)
	for m in matches1:
		var json_str = m.get_string(1).strip_edges()
		var parsed = JSON.parse_string(json_str)
		if parsed and typeof(parsed) == TYPE_DICTIONARY:
			var call_data = {
				"name": parsed.get("name", ""),
				"args": parsed.get("arguments", parsed.get("args", {}))
			}
			if call_data["name"] != "":
				calls.append(call_data)
	
	# Pattern 2: ```json\n{"name": "...", "arguments": {...}}\n```
	if calls.is_empty():
		var regex2 = RegEx.new()
		regex2.compile("```(?:json)?\\s*\\n\\s*(\\{[\\s\\S]*?\"name\"[\\s\\S]*?\\})\\s*\\n\\s*```")
		var matches2 = regex2.search_all(text)
		for m in matches2:
			var json_str = m.get_string(1).strip_edges()
			var parsed = JSON.parse_string(json_str)
			if parsed and typeof(parsed) == TYPE_DICTIONARY and parsed.has("name"):
				var call_data = {
					"name": parsed.get("name", ""),
					"args": parsed.get("arguments", parsed.get("args", {}))
				}
				if call_data["name"] != "":
					calls.append(call_data)
	
	return calls

func _strip_tool_call_text(text: String) -> String:
	var result = text
	# Strip <tool_call>...</tool_call>
	var regex1 = RegEx.new()
	regex1.compile("<tool_call>[\\s\\S]*?</tool_call>")
	result = regex1.sub(result, "", true)
	# Strip ```json tool blocks
	var regex2 = RegEx.new()
	regex2.compile("```(?:json)?\\s*\\n\\s*\\{[\\s\\S]*?\"name\"[\\s\\S]*?\\}\\s*\\n\\s*```")
	result = regex2.sub(result, "", true)
	return result

func _on_ai_error(error: String):
	if _is_generating_commit:
		_is_generating_commit = false
		auto_generate_commit_btn.disabled = false
		commit_msg_input.text = "Error generating commit message."
		return
	_add_to_chat("\n[color=red]Error: " + error + "[/color]\n")

func _on_tab_changed(tab: int):
	# Git tab is index 2
	if tab == 2:
		_update_git_status()

func _update_git_status():
	if not git_manager.is_git_repo():
		git_status_label.text = locale_manager.tr("no_git_repo")
		init_repo_btn.visible = true
		remote_container.visible = false
		pull_btn.disabled = true
		commit_sync_btn.disabled = true
		auto_generate_commit_btn.disabled = true
	else:
		init_repo_btn.visible = false
		remote_container.visible = true
		pull_btn.disabled = false
		commit_sync_btn.disabled = false
		auto_generate_commit_btn.disabled = false
		
		var current_remote = git_manager.git_get_remote()
		if current_remote != "":
			remote_url_input.text = current_remote
			
		var branch = git_manager.git_get_current_branch()
		branch_label.text = locale_manager.tr("current_branch") + "[b]" + branch + "[/b]"
			
		var status = git_manager.git_status()
		if status.strip_edges() == "":
			git_status_label.text = "[color=green]" + locale_manager.tr("working_tree_clean") + "[/color]"
		else:
			git_status_label.text = locale_manager.tr("pending_changes") + "\n" + status

func _on_set_remote_pressed():
	var url = remote_url_input.text.strip_edges()
	if url == "":
		return
	git_manager.git_remote_add(url)
	_update_git_status()

func _on_init_repo_pressed():
	git_manager.git_init()
	_update_git_status()

func _set_git_busy(busy: bool):
	pull_btn.disabled = busy
	commit_sync_btn.disabled = busy
	auto_generate_commit_btn.disabled = busy
	checkout_branch_btn.disabled = busy
	undo_changes_btn.disabled = busy
	force_pull_btn.disabled = busy
	force_push_btn.disabled = busy
	if busy:
		git_status_label.text = "[color=yellow]" + locale_manager.tr("working_please_wait") + "[/color]"

func _on_pull_pressed():
	_set_git_busy(true)
	git_status_label.text = "[color=yellow]" + locale_manager.tr("pulling_from_github") + "[/color]"
	await get_tree().process_frame
	var res = git_manager.git_pull()
	git_status_label.text = locale_manager.tr("pull_result") + "\n" + res
	_set_git_busy(false)
	await get_tree().create_timer(3.0).timeout
	_update_git_status()

func _on_checkout_branch_pressed():
	var branch_name = branch_name_input.text.strip_edges()
	if branch_name == "":
		return
	
	_set_git_busy(true)
	git_status_label.text = "[color=yellow]" + locale_manager.tr("switching_branch") + "[/color]"
	await get_tree().process_frame
	var res = git_manager.git_checkout_branch(branch_name)
	git_status_label.text = res
	branch_name_input.text = ""
	_set_git_busy(false)
	await get_tree().create_timer(2.0).timeout
	_update_git_status()

func _on_undo_changes_confirmed():
	_set_git_busy(true)
	git_status_label.text = "[color=yellow]" + locale_manager.tr("undoing_uncommitted") + "[/color]"
	await get_tree().process_frame
	var res = git_manager.git_discard_changes()
	git_status_label.text = "[color=green]" + locale_manager.tr("modifications_discarded") + "[/color]\n" + res
	_set_git_busy(false)
	await get_tree().create_timer(3.0).timeout
	_update_git_status()
	
func _on_force_pull_confirmed():
	_set_git_busy(true)
	git_status_label.text = "[color=yellow]" + locale_manager.tr("force_pulling") + "[/color]"
	await get_tree().process_frame
	var res = git_manager.git_force_pull()
	git_status_label.text = "[color=green]" + locale_manager.tr("force_pull_complete") + "[/color]\n" + res
	_set_git_busy(false)
	await get_tree().create_timer(3.0).timeout
	_update_git_status()

func _on_force_push_confirmed():
	_set_git_busy(true)
	git_status_label.text = "[color=yellow]" + locale_manager.tr("force_pushing") + "[/color]"
	await get_tree().process_frame
	git_manager.git_add_all()
	var msg = commit_msg_input.text.strip_edges()
	if msg != "":
		git_manager.git_commit(msg)
	var res = git_manager.git_force_push()
	if res.strip_edges() == "":
		res = "Done."
	git_status_label.text = "[color=green]" + locale_manager.tr("force_push_complete") + "[/color]\n" + res
	commit_msg_input.text = ""
	_set_git_busy(false)
	await get_tree().create_timer(3.0).timeout
	_update_git_status()

func _on_commit_sync_pressed():
	var msg = commit_msg_input.text.strip_edges()
	if msg == "":
		msg = "Updates"
	
	_set_git_busy(true)
	git_status_label.text = "[color=yellow]" + locale_manager.tr("committing_pushing") + "[/color]"
	await get_tree().process_frame
	git_manager.git_add_all()
	git_manager.git_commit(msg)
	var push_res = git_manager.git_push()
	if push_res.strip_edges() == "":
		push_res = "Done."
	git_status_label.text = locale_manager.tr("push_result") + "\n" + push_res
	commit_msg_input.text = ""
	_set_git_busy(false)
	await get_tree().create_timer(3.0).timeout
	_update_git_status()

func _on_auto_generate_commit_pressed():
	if git_manager.git_status().strip_edges() == "":
		commit_msg_input.text = locale_manager.tr("no_changes_to_commit")
		return
	
	if gemini_client == null or gemini_client.api_key == "":
		commit_msg_input.text = locale_manager.tr("ai_not_configured")
		return
		
	commit_msg_input.text = locale_manager.tr("generating")
	auto_generate_commit_btn.disabled = true
	_is_generating_commit = true
	var diff = git_manager.git_diff()
	var prompt = "You are an expert developer. Write a clear, concise Git commit message for the following diff. Only return the commit message snippet without any markdown formatting or explanations:\n\n" + diff
	
	gemini_client.send_prompt(prompt, "", [], [])

func _log_user_message(msg: String, token_count: int = -1):
	var header = ""
	if token_count != -1:
		header += "\n[right][i][color=gray](Est. Tokens: ~" + str(token_count) + ")[/color][/i][/right]\n"
	_add_to_chat(header + msg + "\n", "user")

func _on_log_entry(entry: Dictionary):
	var color = "red" if entry.type == "error" else "gray"
	var msg = "\n[color=" + color + "][b]Engine " + entry.type.capitalize() + ":[/b] " + entry.message
	if entry.has("source") and entry.source.file:
		msg += " (" + entry.source.file.get_file() + ":" + str(entry.source.line) + ")"
	msg += "[/color]\n"
	_add_to_chat(msg)

func _markdown_to_bbcode(text: String) -> String:
	var result = ""
	var lines = text.split("\n")
	var in_code_block = false
	
	for line in lines:
		if line.strip_edges().begins_with("```"):
			if in_code_block:
				result += "[/code]\n"
				in_code_block = false
			else:
				result += "[code]"
				in_code_block = true
			continue
		
		if in_code_block:
			result += line + "\n"
			continue
		
		if line.begins_with("### "):
			result += "[b]" + line.substr(4) + "[/b]\n"
			continue
		elif line.begins_with("## "):
			result += "\n[b][color=#8be9fd]" + line.substr(3) + "[/color][/b]\n"
			continue
		elif line.begins_with("# "):
			result += "\n[b][color=#50fa7b][font_size=18]" + line.substr(2) + "[/font_size][/color][/b]\n"
			continue
		
		if line.strip_edges().begins_with("- ") or line.strip_edges().begins_with("* "):
			var indent = line.length() - line.strip_edges().length()
			var prefix = "  ".repeat(indent / 2) + "• "
			line = prefix + line.strip_edges().substr(2)
		
		# Use precompiled regex (initialized in _ready)
		line = _regex_bold_italic.sub(line, "[b][i]$1[/i][/b]", true)
		line = _regex_bold.sub(line, "[b]$1[/b]", true)
		line = _regex_italic.sub(line, "[i]$1[/i]", true)
		line = _regex_code.sub(line, "[code]$1[/code]", true)
		line = _regex_suggest.sub(line, "[url=suggest:$1][b][color=#50fa7b] 💡 $1 [/color][/b][/url]", true)
		
		result += line + "\n"
	
	if in_code_block:
		result += "[/code]\n"
	
	return result

func _on_confirmation_needed(message: String, _tool_name: String, _args: Dictionary):
	_confirm_dialog.dialog_text = "⚠️ " + message + "\n\n" + locale_manager.tr("cannot_be_undone")
	_confirm_dialog.popup_centered()

func _on_destructive_confirmed():
	if _tool_executor:
		_tool_executor.confirm_pending_action()

func _on_destructive_cancelled():
	if _tool_executor:
		_tool_executor.cancel_pending_action()

func _on_token_usage(usage: Dictionary):
	var prompt = usage.get("prompt_tokens", 0)
	var completion = usage.get("completion_tokens", 0)
	var total = usage.get("total_tokens", 0)
	_add_to_chat("[color=gray][i]Tokens — Prompt: " + str(prompt) + " | Completion: " + str(completion) + " | Total: " + str(total) + "[/i][/color]\n")

func _on_custom_prompt_changed():
	var settings = EditorInterface.get_editor_settings()
	settings.set_setting("gamedev_ai/custom_system_prompt", custom_prompt_input.text)
	if gemini_client:
		gemini_client.custom_instructions = custom_prompt_input.text

# Drag & Drop Handlers
func _can_drop_data_fw(_at_pos: Vector2, data: Variant) -> bool:
	return _can_drop_data(_at_pos, data)

func _drop_data_fw(_at_pos: Vector2, data: Variant):
	_drop_data(_at_pos, data)

func _can_drop_data(_at_pos: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY:
		if data.has("type"):
			if data["type"] in ["files", "nodes", "resource", "obj"]:
				return true
		if data.has("files"):
			return true
	return false

func _drop_data(_at_pos: Vector2, data: Variant):
	var paths_to_add: Array[String] = []
	
	if typeof(data) == TYPE_DICTIONARY:
		if data.has("type"):
			if data["type"] == "files" and data.has("files"):
				paths_to_add.append_array(data["files"])
			elif data["type"] == "nodes" and data.has("nodes"):
				# Iterate nodes natively, trying to find script or scene
				var editor = EditorInterface.get_edited_scene_root()
				for np in data["nodes"]:
					var node = editor.get_node_or_null(np) if editor else null
					if node:
						if node.scene_file_path != "":
							paths_to_add.append(node.scene_file_path)
						var script = node.get_script()
						if script and script.resource_path != "":
							paths_to_add.append(script.resource_path)
			elif data["type"] == "resource" and data.has("resource"):
				var res = data["resource"]
				if res and res.resource_path != "":
					paths_to_add.append(res.resource_path)
			elif data["type"] == "obj" and data.has("object"):
				var obj = data["object"]
				if obj is Resource and obj.resource_path != "":
					paths_to_add.append(obj.resource_path)
				elif obj is Node:
					if obj.scene_file_path != "":
						paths_to_add.append(obj.scene_file_path)
					var script = obj.get_script()
					if script and script.resource_path != "":
						paths_to_add.append(script.resource_path)
		
		# Fallback if just 'files' array exists and wasn't caught by above
		if paths_to_add.is_empty() and data.has("files"):
			paths_to_add.append_array(data["files"])
			
	for f in paths_to_add:
		if not _dropped_files.has(f):
			# Support dragged images
			var ext = f.get_extension().to_lower()
			if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "webp":
				var img = Image.new()
				var err = img.load(f)
				if err == OK:
					var file = FileAccess.open(f, FileAccess.READ)
					var bytes = file.get_buffer(file.get_length())
					var mime = "image/" + ("jpeg" if ext in ["jpg", "jpeg"] else ext)
					
					_attached_files.append({
						"type": "image",
						"filename": f.get_file(),
						"path": f,
						"mime_type": mime,
						"image_obj": img,
						"raw_bytes": bytes
					})
					_refresh_thumbnails()
			else:
				_dropped_files.append(f)
	
	_update_dropped_files_ui()

func _update_dropped_files_ui():
	if _dropped_files.is_empty():
		_file_preview_container.visible = false
	else:
		_file_preview_container.visible = true
		var file_names = []
		for f in _dropped_files:
			file_names.append(f.get_file())
		_file_preview_label.text = "[color=cyan]Files attached:[/color] " + ", ".join(file_names)

func _on_clear_dropped_files():
	_dropped_files.clear()
	_update_dropped_files_ui()

func _on_diff_preview_requested(path: String, old_content: String, new_content: String, tool_name: String, _args: Dictionary):
	_diff_preview_panel.visible = true
	if _diff_preview_panel.get_parent() != chat_vbox:
		_diff_preview_panel.reparent(chat_vbox)
	chat_vbox.move_child(_diff_preview_panel, -1)
	
	_diff_display.scroll_following = false
	_diff_display.clear()
	_diff_display.append_text("[b]Modifying: " + path + "[/b] (" + tool_name + ")\n")
	
	if tool_name == "patch_script" or tool_name == "replace_selection":
		# Component-based diff
		_diff_display.append_text("[color=red][s]" + _markdown_to_bbcode(old_content) + "[/s][/color]\n")
		_diff_display.append_text("[color=green]" + _markdown_to_bbcode(new_content) + "[/color]\n")
	else:
		# Full file diff (very simplified line-by-line)
		var old_lines = old_content.split("\n")
		var new_lines = new_content.split("\n")
		
		# A very basic diff for display purposes
		# In a real app we'd use a better diffing algorithm
		if old_content == "":
			_diff_display.append_text("[color=green]" + _markdown_to_bbcode(new_content) + "[/color]\n")
		else:
			# Just show the new content for now to avoid complexity of line diffing
			# but color it slightly to indicate it's new
			_diff_display.append_text("[i]New content preview:[/i]\n")
			_diff_display.append_text(_markdown_to_bbcode(new_content))

	await get_tree().process_frame
	var v_scroll = _diff_display.get_v_scroll_bar()
	if v_scroll:
		v_scroll.value = 0

func _on_apply_diff_pressed():
	_diff_preview_panel.visible = false
	if _tool_executor:
		_tool_executor.confirm_pending_action()

func _on_skip_diff_pressed():
	_diff_preview_panel.visible = false
	if _tool_executor:
		_tool_executor.cancel_pending_action()

func _on_filesystem_changed():
	var valid_files: Array[String] = []
	for f in _dropped_files:
		if FileAccess.file_exists(f):
			valid_files.append(f)
			
	if valid_files.size() != _dropped_files.size():
		_dropped_files = valid_files
		_update_dropped_files_ui()

func _on_meta_clicked(meta):
	var meta_str = str(meta)
	if meta_str.begins_with("suggest:"):
		var suggestion = meta_str.substr(8)
		input_field.text = suggestion
		_on_send_pressed()
	elif meta_str.begins_with("toggle_block:"):
		var block_id = meta_str.substr(13).to_int()
		_toggle_block(block_id)
	else:
		OS.shell_open(meta_str)

func _append_collapsible_block(label: String, content: String, color: String, expanded: bool):
	var id = _next_block_id
	_next_block_id += 1
	
	_block_data[id] = {
		"label": label,
		"content": content,
		"color": color,
		"expanded": expanded,
		"bubble_ref": _current_bubble
	}
	
	_add_to_chat(_get_block_bbcode(id))

func _get_block_bbcode(id: int) -> String:
	var data = _block_data[id]
	var icon = "📂 " if not data.expanded else "📖 "
	var action = "[Expand]" if not data.expanded else "[Collapse]"
	var bb = "\n[color=" + data.color + "]" + icon + data.label + " [/color]"
	bb += "[url=toggle_block:" + str(id) + "][i][color=gray]" + action + "[/color][/i][/url]\n"
	
	if data.expanded:
		bb += "[indent][i]" + data.content + "[/i][/indent]\n"
	
	return bb

func _toggle_block(id: int):
	if not _block_data.has(id): return
	
	var data = _block_data[id]
	var old_bb = _get_block_bbcode(id)
	data.expanded = !data.expanded
	var new_bb = _get_block_bbcode(id)
	
	_chat_log_bbcode = _chat_log_bbcode.replace(old_bb, new_bb)
	
	# Update the specific bubble if registered
	if data.has("bubble_ref") and is_instance_valid(data.bubble_ref):
		data.bubble_ref.text = data.bubble_ref.text.replace(old_bb, new_bb)
	
	await get_tree().process_frame
	var vbar = chat_scroll.get_v_scroll_bar()
	if vbar: vbar.value = vbar.max_value

func _add_to_chat(bbcode: String, role: String = "system"):
	_chat_log_bbcode += bbcode
	
	if _current_bubble == null or _current_role != role:
		_create_chat_bubble(role)
		
	_current_bubble.append_text(bbcode)
	
	# Auto-scroll
	await get_tree().process_frame
	var v_scroll = chat_scroll.get_v_scroll_bar()
	if v_scroll:
		v_scroll.value = v_scroll.max_value

func _create_chat_bubble(role: String):
	_current_role = role
	
	# Outer styled panel (the "bubble")
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	
	# Inner HBox: [Avatar | Text]  or  [Text | Avatar]
	var inner_hbox = HBoxContainer.new()
	inner_hbox.size_flags_horizontal = SIZE_EXPAND_FILL
	inner_hbox.add_theme_constant_override("separation", 12)
	
	# Avatar in round white circle
	var avatar_holder = PanelContainer.new()
	var avatar_style = StyleBoxFlat.new()
	avatar_style.bg_color = Color(0.95, 0.95, 0.95)
	avatar_style.corner_radius_top_left = 20
	avatar_style.corner_radius_top_right = 20
	avatar_style.corner_radius_bottom_left = 20
	avatar_style.corner_radius_bottom_right = 20
	avatar_style.content_margin_left = 4
	avatar_style.content_margin_right = 4
	avatar_style.content_margin_top = 4
	avatar_style.content_margin_bottom = 4
	avatar_holder.add_theme_stylebox_override("panel", avatar_style)
	avatar_holder.custom_minimum_size = Vector2(40, 40)
	avatar_holder.size_flags_horizontal = SIZE_SHRINK_CENTER
	avatar_holder.size_flags_vertical = SIZE_SHRINK_BEGIN  # Align to top
	
	var avatar = TextureRect.new()
	avatar.custom_minimum_size = Vector2(32, 32)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_holder.add_child(avatar)
	
	# Text column (label + optional copy btn)
	var text_vbox = VBoxContainer.new()
	text_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.selection_enabled = true
	if has_method("_on_meta_clicked"):
		label.meta_clicked.connect(_on_meta_clicked)
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	_current_bubble = label
	text_vbox.add_child(label)
	
	# Apply current font size to the new bubble
	if _current_font_size != 14:
		label.add_theme_font_size_override("normal_font_size", _current_font_size)
		label.add_theme_font_size_override("bold_font_size", _current_font_size)
		label.add_theme_font_size_override("italics_font_size", _current_font_size)
		label.add_theme_font_size_override("bold_italics_font_size", _current_font_size)
		label.add_theme_font_size_override("mono_font_size", _current_font_size)
	
	# "Copy" button for AI/system bubbles
	if role == "ai" or role == "system":
		var copy_btn = Button.new()
		copy_btn.text = "📋 Copy"
		copy_btn.size_flags_horizontal = SIZE_SHRINK_END
		copy_btn.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		var empty_style = StyleBoxEmpty.new()
		copy_btn.add_theme_stylebox_override("normal", empty_style)
		copy_btn.add_theme_stylebox_override("hover", empty_style)
		copy_btn.add_theme_stylebox_override("focus", empty_style)
		copy_btn.pressed.connect(func():
			DisplayServer.clipboard_set(label.get_parsed_text())
			copy_btn.text = "✔️ Copied"
			copy_btn.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		)
		text_vbox.add_child(copy_btn)
	
	# Assemble based on role
	if role == "user":
		style.bg_color = Color(0.18, 0.22, 0.3)
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 2
		var user_tex = load("res://addons/gamedev_ai/assets/user_icon.svg")
		if user_tex:
			avatar.texture = user_tex
			avatar.modulate = Color(0.3, 0.4, 0.6)
		inner_hbox.add_child(text_vbox)
		inner_hbox.add_child(avatar_holder)
	else:
		style.bg_color = Color(0.12, 0.13, 0.16, 0.7)
		style.corner_radius_bottom_left = 2
		style.corner_radius_bottom_right = 12
		var ai_tex = load("res://addons/gamedev_ai/assets/ai_icon.png")
		if ai_tex:
			avatar.texture = ai_tex
		inner_hbox.add_child(avatar_holder)
		inner_hbox.add_child(text_vbox)
	
	panel.add_child(inner_hbox)
	
	# Appearance animation
	panel.modulate.a = 0.0
	chat_vbox.add_child(panel)
	var tween = chat_vbox.create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)

func _clear_chat():
	_chat_log_bbcode = ""
	_current_bubble = null
	for child in chat_vbox.get_children():
		child.queue_free()

# ═══════════════════════════════════════════════════════════════
# GLASSMORPHISM THEME SYSTEM V3 (RICH NEON & MARGINS)
# ═══════════════════════════════════════════════════════════════

func _apply_custom_theme():
	# Keep only the margins that were requested by the user
	
	# Tab padding and spacing
	var tabbar_bg = StyleBoxFlat.new()
	tabbar_bg.bg_color = Color(0.08, 0.09, 0.12) # Dark background for the tab bar
	tabbar_bg.content_margin_top = 10 # Spacing above tabs
	$TabContainer.add_theme_stylebox_override("tabbar_background", tabbar_bg)
	
	# Remove custom tab colors so it uses editor default colors
	if $TabContainer.has_theme_stylebox_override("tab_unselected"):
		$TabContainer.remove_theme_stylebox_override("tab_unselected")
	if $TabContainer.has_theme_stylebox_override("tab_selected"):
		$TabContainer.remove_theme_stylebox_override("tab_selected")

	var tab_panel = StyleBoxEmpty.new()
	tab_panel.content_margin_left = 12
	tab_panel.content_margin_right = 12
	tab_panel.content_margin_top = 12
	tab_panel.content_margin_bottom = 12
	$TabContainer.add_theme_stylebox_override("panel", tab_panel)
	
	# Margins for chat actions
	var chat_container = $TabContainer/Chat
	chat_container.add_theme_constant_override("separation", 12)
	
	# Chat output display padding
	var output_style = StyleBoxFlat.new()
	output_style.bg_color = Color(0, 0, 0, 0.15) # subtle dark background for readability
	output_style.corner_radius_top_left = 8
	output_style.corner_radius_top_right = 8
	output_style.corner_radius_bottom_right = 8
	output_style.corner_radius_bottom_left = 8
	output_style.content_margin_left = 12
	output_style.content_margin_top = 12
	output_style.content_margin_right = 12
	output_style.content_margin_bottom = 12
	chat_scroll.add_theme_stylebox_override("panel", output_style)
	
	# Input field padding
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.1, 0.11, 0.14)
	input_style.border_width_left = 1
	input_style.border_width_top = 1
	input_style.border_width_right = 1
	input_style.border_width_bottom = 1
	input_style.border_color = Color(0.25, 0.27, 0.35)
	input_style.corner_radius_top_left = 12
	input_style.corner_radius_top_right = 12
	input_style.corner_radius_bottom_right = 12
	input_style.corner_radius_bottom_left = 12
	input_style.content_margin_left = 16
	input_style.content_margin_right = 16
	input_style.content_margin_top = 12
	input_style.content_margin_bottom = 35 # Extra space for toolbar
	
	input_field.add_theme_stylebox_override("normal", input_style)
	input_field.add_theme_stylebox_override("focus", input_style)
	
	# Circular Send Button Style
	var send_style = StyleBoxFlat.new()
	send_style.bg_color = Color(0.15, 0.6, 0.35)
	send_style.corner_radius_top_left = 20
	send_style.corner_radius_top_right = 20
	send_style.corner_radius_bottom_right = 20
	send_style.corner_radius_bottom_left = 20
	send_style.shadow_color = Color(0, 0, 0, 0.3)
	send_style.shadow_size = 4
	send_style.shadow_offset = Vector2(0, 2)
	
	send_button.add_theme_stylebox_override("normal", send_style)
	send_button.add_theme_stylebox_override("hover", send_style)
	send_button.add_theme_stylebox_override("pressed", send_style)
	
	# Apply SVG Icons
	var icon_path = "res://addons/gamedev_ai/assets/icons/"
	new_chat_button.icon = _load_svg_icon(icon_path + "plus.svg", "ffffff")
	history_button.icon = _load_svg_icon(icon_path + "history.svg", "ffffff")
	summarize_btn.icon = _load_svg_icon(icon_path + "settings.svg", "ffffff")
	add_file_btn.icon = _load_svg_icon(icon_path + "attach.svg", "ffffff")
	send_button.icon = _load_svg_icon(icon_path + "send.svg", "ffffff")
	magic_actions_btn.icon = _load_svg_icon(icon_path + "magic.svg", "ffffff")
	prompt_settings_btn.icon = _load_svg_icon(icon_path + "settings.svg", "ffffff")
	
	magic_actions_btn.size_flags_horizontal = SIZE_SHRINK_BEGIN
	prompt_settings_btn.size_flags_horizontal = SIZE_SHRINK_BEGIN
	
	# Secondary toolbar style
	var ghost_style = StyleBoxEmpty.new()
	ghost_style.content_margin_left = 8
	ghost_style.content_margin_right = 8
	
	add_file_btn.add_theme_stylebox_override("normal", ghost_style)
	magic_actions_btn.add_theme_stylebox_override("normal", ghost_style)
	prompt_settings_btn.add_theme_stylebox_override("normal", ghost_style)
	
	_style_solid_button(execute_plan_btn, Color(0.2, 0.6, 0.3))
	_style_solid_button(_apply_diff_btn, Color(0.2, 0.6, 0.3))
	
	_style_solid_button(_skip_diff_btn, Color(0.4, 0.4, 0.45))
	_style_solid_button(tts_play_btn, Color(0.3, 0.4, 0.5))
	if is_instance_valid(tts_stop_btn):
		_style_solid_button(tts_stop_btn, Color(0.5, 0.3, 0.3))
	_style_solid_button(_file_clear_btn, Color(0.5, 0.3, 0.3))
	
	_style_solid_button(font_size_minus_btn, Color(0.3, 0.35, 0.4))
	_style_solid_button(font_size_plus_btn, Color(0.3, 0.35, 0.4))
	_style_solid_button(new_chat_button, Color(0.3, 0.35, 0.4))
	_style_solid_button(history_button, Color(0.3, 0.35, 0.4))
	
	# Git Buttons Colors
	_style_solid_button(init_repo_btn, Color(0.2, 0.6, 0.3))
	_style_solid_button(set_remote_btn, Color(0.25, 0.35, 0.5))
	_style_solid_button(pull_btn, Color(0.25, 0.35, 0.5))
	_style_solid_button(refresh_git_btn, Color(0.3, 0.4, 0.5))
	_style_solid_button(auto_generate_commit_btn, Color(0.4, 0.3, 0.6))
	_style_solid_button(commit_sync_btn, Color(0.2, 0.6, 0.3))
	_style_solid_button(checkout_branch_btn, Color(0.25, 0.35, 0.5))
	
	# Ghost danger buttons (border only, no fill)
	_style_ghost_danger_button(undo_changes_btn)
	_style_ghost_danger_button(force_pull_btn)
	_style_ghost_danger_button(force_push_btn)
	
	_add_action_icons()
	
	# Force horizontal expansion for all tabs and their internals
	$TabContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for child in $TabContainer.get_children():
		if child is Control:
			child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_force_expansion_recursive(child)
	
	# ── Phase 2: Settings Cards ──
	_apply_settings_cards()
	_apply_git_zones()

func _load_svg_icon(path: String, color_hex: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return null
	var svg_content = file.get_as_text()
	svg_content = svg_content.replace("currentColor", "#" + color_hex)
	var img = Image.new()
	var err = img.load_svg_from_string(svg_content)
	if err == OK:
		return ImageTexture.create_from_image(img)
	return null

func _force_expansion_recursive(node: Node):
	if node is Control:
		if node is Container:
			node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for child in node.get_children():
			_force_expansion_recursive(child)

func _style_solid_button(btn: Control, bg_color: Color, corner: int = 6):
	if not is_instance_valid(btn):
		return
	var normal = StyleBoxFlat.new()
	normal.bg_color = bg_color
	normal.corner_radius_top_left = corner
	normal.corner_radius_top_right = corner
	normal.corner_radius_bottom_right = corner
	normal.corner_radius_bottom_left = corner
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	
	var hover = normal.duplicate()
	hover.bg_color = bg_color.lightened(0.2)
	
	var pressed = normal.duplicate()
	pressed.bg_color = bg_color.darkened(0.2)
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _style_danger_button(btn: Control, corner: int = 6):
	_style_solid_button(btn, Color(0.7, 0.2, 0.2), corner)

func _style_ghost_danger_button(btn: Control):
	if not is_instance_valid(btn):
		return
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0, 0, 0, 0)
	normal.border_color = Color(0.8, 0.25, 0.25, 0.6)
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_left = 6
	normal.corner_radius_bottom_right = 6
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	
	var hover = normal.duplicate()
	hover.bg_color = Color(0.7, 0.2, 0.2, 0.15)
	hover.border_color = Color(0.9, 0.3, 0.3, 0.8)
	
	var pressed = normal.duplicate()
	pressed.bg_color = Color(0.7, 0.2, 0.2, 0.3)
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4))

func _make_card_style(bg_color: Color = Color(0.14, 0.15, 0.19), border_color: Color = Color(0.25, 0.27, 0.35, 0.4)) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _wrap_in_card(parent: Control, children: Array, title: String, bg_color: Color = Color(0.14, 0.15, 0.19), border_color: Color = Color(0.25, 0.27, 0.35, 0.4)) -> PanelContainer:
	var card = PanelContainer.new()
	card.size_flags_horizontal = SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_card_style(bg_color, border_color))
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	
	# Add title label
	if title != "":
		var title_label = Label.new()
		title_label.text = title
		title_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
		vbox.add_child(title_label)
	
	# Get indexes for insertion order
	var insert_idx = -1
	for child in children:
		if is_instance_valid(child) and child.get_parent() == parent:
			var idx = child.get_index()
			if insert_idx == -1 or idx < insert_idx:
				insert_idx = idx
	
	# Reparent children into the card
	for child in children:
		if is_instance_valid(child):
			child.reparent(vbox)
	
	card.add_child(vbox)
	if insert_idx >= 0 and insert_idx < parent.get_child_count():
		parent.add_child(card)
		parent.move_child(card, insert_idx)
	else:
		parent.add_child(card)
	
	return card

func _apply_settings_cards():
	var settings_tab = $TabContainer/Settings
	settings_tab.add_theme_constant_override("separation", 12)
	
	# Card 1: API & Provider
	var preset_bar = $TabContainer/Settings/PresetBar
	var preset_edit = $TabContainer/Settings/PresetEditPanel
	_wrap_in_card(settings_tab, [preset_bar, preset_edit], "API & Provedor")
	
	# Card 2: AI Behavior
	var lang_hbox = $TabContainer/Settings/LanguageHBox
	var prompt_label = $TabContainer/Settings/CustomPromptLabel
	var prompt_input = custom_prompt_input
	var enhance_btn = enhance_prompt_btn
	# Increase Custom Instructions height
	prompt_input.custom_minimum_size = Vector2(0, 200)
	_wrap_in_card(settings_tab, [lang_hbox, prompt_label, prompt_input, enhance_btn], "Comportamento da IA")
	
	# Card 3: Vector Database
	var vdb_sep = $TabContainer/Settings/VectorDBSeparator
	var vdb_label = $TabContainer/Settings/VectorDBLabel
	var vdb_scroll = $TabContainer/Settings/VectorDBScroll
	var vdb_actions = $TabContainer/Settings/VectorDBActionsHBox
	# Increase VectorDB list height
	vdb_scroll.custom_minimum_size = Vector2(0, 180)
	vdb_sep.queue_free()
	_wrap_in_card(settings_tab, [vdb_label, vdb_scroll, vdb_actions], "Vector Database")

func _apply_git_zones():
	var git_tab = $TabContainer/Git
	git_tab.add_theme_constant_override("separation", 12)
	
	# Increase Git status panel height (~20 lines)
	git_status_label.custom_minimum_size = Vector2(0, 300)
	
	# Git Status Panel styling
	var status_style = _make_card_style(Color(0.10, 0.11, 0.14), Color(0.2, 0.22, 0.3, 0.5))
	git_status_label.add_theme_stylebox_override("normal", status_style)
	
	# Increase commit message height
	commit_msg_input.custom_minimum_size = Vector2(0, 120)
	
	# Main Zone: Remote + Status + Actions + Commit
	var remote = $TabContainer/Git/RemoteContainer
	var git_actions = $TabContainer/Git/GitActionsContainer
	var commit_container = $TabContainer/Git/CommitMsgContainer
	var commit_btn = commit_sync_btn
	_wrap_in_card(git_tab, [remote, git_status_label, git_actions, commit_container, commit_btn], "Commit & Sync")
	
	# Branch Zone
	var branch_container = $TabContainer/Git/BranchContainer
	_wrap_in_card(git_tab, [branch_container], "Branch")
	
	# Remove old separator
	var old_sep = $TabContainer/Git/HSeparator
	if is_instance_valid(old_sep):
		old_sep.queue_free()
	
	# Danger Zone
	var danger_hbox = $TabContainer/Git/AdvancedGitHBox
	_wrap_in_card(git_tab, [danger_hbox], "Danger Zone", Color(0.22, 0.08, 0.08), Color(0.6, 0.2, 0.2, 0.5))

func _add_action_icons():
	var btn_map = {
		$TabContainer/Chat/ActionsContainer/RefactorBtn: "✧ ",
		$TabContainer/Chat/ActionsContainer/FixBtn: "� ",
		$TabContainer/Chat/ActionsContainer/ExplainBtn: "💡 ",
		$TabContainer/Chat/ActionsContainer/UndoBtn: "↶ ",
		$TabContainer/Chat/ActionsContainer/FixConsoleBtn: "⌨ ",
	}
	for btn in btn_map.keys():
		var icon_prefix = btn_map[btn]
		if not btn.text.begins_with(icon_prefix.left(1)):
			btn.text = icon_prefix + btn.text

# --- Copy functionality (legacy stubs - copy is now per-bubble) ---
func _setup_copy_features():
	pass

func _on_output_display_gui_input(_event: InputEvent):
	pass

func _check_floating_copy_btn():
	pass

func _on_copy_popup_id_pressed(_id: int):
	pass

func _on_floating_copy_pressed():
	pass

func _perform_copy():
	pass

# ===================== VECTOR DB UI =====================
func _on_scan_changes_pressed():
	if not _tool_executor or not _tool_executor.vector_db:
		vector_db_file_list.text = "[color=red]Error: VectorDB not initialized.[/color]"
		return
	
	scan_changes_btn.disabled = true
	scan_changes_btn.text = "⏳ Scanning..."
	
	var result = _tool_executor.vector_db.scan_changes()
	var bbcode = ""
	
	# New or modified (yellow)
	for path in result["new_or_modified"]:
		bbcode += "[color=yellow]● NEW/MOD [/color] " + path + "\n"
	
	# Moved/renamed (blue)
	for m in result["moved"]:
		bbcode += "[color=dodgerblue]➜ MOVED  [/color] " + m["old"] + " → " + m["new"] + "\n"
	
	# Deleted (red)
	for path in result["deleted"]:
		bbcode += "[color=red]✖ DELETED[/color] " + path + "\n"
	
	# Retained (green) - show count only to avoid clutter
	var retained_count = result["retained"].size()
	if retained_count > 0:
		bbcode += "[color=green]✔ " + str(retained_count) + " file(s) unchanged (retained)[/color]\n"
	
	if bbcode == "":
		bbcode = "[color=gray]No script files found in the project.[/color]"
	
	# Summary line
	var total = result["retained"].size() + result["moved"].size() + result["new_or_modified"].size() + result["deleted"].size()
	bbcode += "\n[b]Total: " + str(total) + " files[/b] | "
	bbcode += "[color=yellow]" + str(result["new_or_modified"].size()) + " to embed[/color] | "
	bbcode += "[color=dodgerblue]" + str(result["moved"].size()) + " moved[/color] | "
	bbcode += "[color=red]" + str(result["deleted"].size()) + " deleted[/color]"
	
	vector_db_file_list.text = bbcode
	scan_changes_btn.disabled = false
	scan_changes_btn.text = "🔍 Scan Changes"

func _on_index_codebase_pressed():
	index_confirm_dialog.popup_centered()

func _on_index_confirmed():
	if not _tool_executor or not _tool_executor.vector_db:
		return
	index_codebase_btn.disabled = true
	index_codebase_btn.text = "⏳ Indexing..."
	scan_changes_btn.disabled = true
	_tool_executor.vector_db.index_project()

var _vdb_messages: Array = []

func _on_vector_db_output(text: String):
	_vdb_messages.append(text)
	# The final message contains "complete" — show the result popup
	if "complete" in text.to_lower():
		var full_msg = "\n".join(_vdb_messages)
		_vdb_messages.clear()
		index_result_dialog.dialog_text = full_msg
		index_result_dialog.popup_centered()
		index_codebase_btn.disabled = false
		index_codebase_btn.text = "⚡ Index Codebase"
		scan_changes_btn.disabled = false

# ===================== ENHANCE INSTRUCTIONS =====================
func _on_enhance_prompt_pressed():
	var raw_text = custom_prompt_input.text.strip_edges()
	if raw_text == "":
		_show_enhance_error("Please write some instructions first before enhancing.")
		return
	
	enhance_prompt_btn.disabled = true
	enhance_prompt_btn.text = "⏳ Enhancing..."
	
	# Create a one-shot HTTPRequest if not already created
	if not _enhance_http:
		_enhance_http = HTTPRequest.new()
		_enhance_http.use_threads = true
		_enhance_http.timeout = 360.0
		add_child(_enhance_http)
		_enhance_http.request_completed.connect(_on_enhance_request_completed)
	
	# Build the one-shot request using the active preset
	var preset = presets.get(active_preset_name, {})
	var provider = preset.get("provider", 0)
	var api_key = preset.get("api_key", "")
	var base_url = preset.get("base_url", "")
	var model = preset.get("model_name", "")
	
	var enhance_prompt = "You are an expert at writing system prompt instructions for AI coding assistants specialized in Godot 4 game development. The user has written the following custom instructions but they may not be well structured or clear enough. Your job is to rewrite and enhance these instructions to be clearer, more specific, and more effective, while preserving the user's original intent. Keep the same language the user wrote in. Output ONLY the enhanced instructions text, no explanations or markdown formatting.\n\nOriginal instructions:\n" + raw_text
	
	var url = ""
	var headers = ["Content-Type: application/json"]
	var body = ""
	
	if provider == 0: # Gemini / Vertex
		var m = model if model != "" else "gemini-3.1-pro-preview"
		if base_url != "":
			url = base_url
			if not url.ends_with("/"): url += "/"
			url += "v1beta/models/" + m + ":generateContent"
		else:
			url = "http://127.0.0.1:8000/v1beta/models/" + m + ":generateContent"
		body = JSON.stringify({
			"contents": [{"role": "user", "parts": [{"text": enhance_prompt}]}]
		})
	else: # OpenAI / OpenRouter
		var m = model if model != "" else "gpt-4o"
		if base_url != "":
			url = base_url
			if not url.ends_with("/"): url += "/"
			url += "v1/chat/completions"
		else:
			url = "https://api.openai.com/v1/chat/completions"
		if api_key != "":
			headers.append("Authorization: Bearer " + api_key)
		body = JSON.stringify({
			"model": m,
			"messages": [{"role": "user", "content": enhance_prompt}]
		})
	
	var err = _enhance_http.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		_show_enhance_error("Failed to send enhance request: " + str(err))
		_reset_enhance_btn()

func _on_enhance_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		var payload = body.get_string_from_utf8()
		_show_enhance_error("API Error (" + str(response_code) + "): " + payload.substr(0, 300))
		_reset_enhance_btn()
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	var text = ""
	
	# Parse Gemini response
	if json and json.has("candidates"):
		var parts = json["candidates"][0].get("content", {}).get("parts", [])
		for part in parts:
			if part.has("text"):
				text += part["text"]
	# Parse OpenAI response
	elif json and json.has("choices"):
		text = json["choices"][0].get("message", {}).get("content", "")
	
	if text.strip_edges() == "":
		_show_enhance_error("AI returned an empty response.")
		_reset_enhance_btn()
		return
	
	_enhanced_text = text.strip_edges()
	enhance_preview_label.text = _enhanced_text
	enhance_preview_dialog.popup_centered()
	_reset_enhance_btn()

func _on_enhance_accepted():
	if _enhanced_text != "":
		custom_prompt_input.text = _enhanced_text
		# Save to editor settings
		var settings = EditorInterface.get_editor_settings()
		settings.set_setting("gamedev_ai/custom_system_prompt", _enhanced_text)
		if gemini_client:
			gemini_client.custom_instructions = _enhanced_text
		_enhanced_text = ""

func _reset_enhance_btn():
	enhance_prompt_btn.disabled = false
	enhance_prompt_btn.text = "✨ Enhance Instructions with AI"

func _show_enhance_error(msg: String):
	enhance_preview_label.text = "[color=red]" + msg + "[/color]"
	enhance_preview_dialog.popup_centered()
