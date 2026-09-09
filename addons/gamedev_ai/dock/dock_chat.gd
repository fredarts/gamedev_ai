@tool
extends RefCounted
class_name DockChat

var _dock_owner: Node
var ai_provider
var context_manager
var _tool_executor
var _memory_manager
var locale_manager

# UI Node references
var chat_scroll: ScrollContainer
var chat_vbox: VBoxContainer
var input_field: TextEdit
var send_button: Button
var magic_actions_btn: MenuButton
var prompt_settings_btn: MenuButton
var selection_status: Label
var history_button: MenuButton
var summarize_btn: Button
var new_chat_button: Button
var execute_plan_btn: Button
var chat_preset_selector: OptionButton

var _image_preview_scroll: ScrollContainer
var _thumbnail_list: HBoxContainer
var add_file_btn: Button
var _add_file_dialog: FileDialog
var _image_popup_dialog: AcceptDialog
var _popup_texture_rect: TextureRect
var _file_preview_container: HBoxContainer
var _file_preview_label: RichTextLabel
var _file_clear_btn: Button

var tts_player_container: VBoxContainer
var tts_play_btn: Button
var tts_stop_btn: Button
var tts_seek_slider: HSlider
var tts_speed_selector: OptionButton
var tts_player: AudioStreamPlayer

# Chat & Streaming State
var _current_bubble: RichTextLabel = null
var _current_role: String = ""
var _bubble_map: Dictionary = {}
var _chat_log_bbcode: String = ""
var _attached_files: Array[Dictionary] = []
var _dropped_files: Array[String] = []
var _history_ids: Array = []
var _history_offset: int = 0
const HISTORY_LIMIT: int = 15
var _pending_history_entries: Array = []
var _load_more_btn: Button = null

var _next_block_id: int = 0
var _block_data: Dictionary = {}
var _last_ai_response_text: String = ""
var _is_stopped: bool = false
var _plan_pending: bool = false

# Settings & Flags
var watch_mode_enabled: bool = false
var plan_first_enabled: bool = false
var context_enabled: bool = true
var screenshot_enabled: bool = false
var _current_font_size: int = 14

# Multi-Agent Orchestrator
var orchestrator: RefCounted
var _pipeline_chips_container: HBoxContainer
var _pipeline_chip_labels: Dictionary = {}

# Watch Mode Limits
var _last_log_size: int = 0
var _ignore_next_error: bool = false
var _watch_fix_count: int = 0
var _watch_cooldown_until: float = 0.0
const _WATCH_MAX_FIXES: int = 3
const _WATCH_COOLDOWN_SECS: float = 30.0

# Batch Execution
var batch_queue: Array = []
var batch_results: Array = []
var current_tool_context: Dictionary = {}
var _batch_total: int = 0
var _confirm_dialog: ConfirmationDialog

# TTS State
var _cached_tts_text: String = ""
var _cached_tts_stream: AudioStreamWAV = null
var _is_dragging_tts_slider: bool = false

# Regexes & Popups
var _regex_code_block: RegEx
var _regex_bold_italic: RegEx
var _regex_bold: RegEx
var _regex_italic: RegEx
var _regex_strike: RegEx
var _regex_code: RegEx
var _regex_suggest: RegEx
var _regex_md_link: RegEx
var _regex_hr: RegEx
var _regex_h4: RegEx
var _regex_h3: RegEx
var _regex_h2: RegEx
var _regex_h1: RegEx
var _regex_blockquote: RegEx
var _regex_list_nested: RegEx
var _regex_list_item: RegEx
var command_popup: PopupMenu

func setup(dock_owner: Node, p_ai_provider, p_context_manager, p_tool_executor, p_memory_manager, p_locale_manager, nodes: Dictionary):
	_dock_owner = dock_owner
	context_manager = p_context_manager
	_tool_executor = p_tool_executor
	_memory_manager = p_memory_manager
	locale_manager = p_locale_manager
	
	chat_scroll = nodes.get("chat_scroll")
	chat_vbox = nodes.get("chat_vbox")
	input_field = nodes.get("input_field")
	send_button = nodes.get("send_button")
	magic_actions_btn = nodes.get("magic_actions_btn")
	prompt_settings_btn = nodes.get("prompt_settings_btn")
	selection_status = nodes.get("selection_status")
	history_button = nodes.get("history_button")
	summarize_btn = nodes.get("summarize_btn")
	new_chat_button = nodes.get("new_chat_button")
	execute_plan_btn = nodes.get("execute_plan_btn")
	chat_preset_selector = nodes.get("chat_preset_selector")
	
	_image_preview_scroll = nodes.get("_image_preview_scroll")
	_thumbnail_list = nodes.get("_thumbnail_list")
	add_file_btn = nodes.get("add_file_btn")
	_add_file_dialog = nodes.get("_add_file_dialog")
	_image_popup_dialog = nodes.get("_image_popup_dialog")
	_popup_texture_rect = nodes.get("_popup_texture_rect")
	_file_preview_container = nodes.get("_file_preview_container")
	_file_preview_label = nodes.get("_file_preview_label")
	_file_clear_btn = nodes.get("_file_clear_btn")
	
	tts_player_container = nodes.get("tts_player_container")
	tts_play_btn = nodes.get("tts_play_btn")
	tts_stop_btn = nodes.get("tts_stop_btn")
	tts_seek_slider = nodes.get("tts_seek_slider")
	tts_speed_selector = nodes.get("tts_speed_selector")
	tts_player = nodes.get("tts_player")
	
	_setup_regexes()
	_setup_command_popup()
	_connect_signals()
	_connect_tool_executor()
	_setup_orchestrator()
	set_ai_provider(p_ai_provider)

func set_ai_provider(provider):
	if ai_provider and ai_provider != provider:
		if ai_provider.response_received.is_connected(_on_response_received):
			ai_provider.response_received.disconnect(_on_response_received)
		if ai_provider.tool_call_received.is_connected(_on_tool_calls):
			ai_provider.tool_call_received.disconnect(_on_tool_calls)
		if ai_provider.audio_received.is_connected(_on_audio_received):
			ai_provider.audio_received.disconnect(_on_audio_received)
		if ai_provider.error_occurred.is_connected(_on_ai_error):
			ai_provider.error_occurred.disconnect(_on_ai_error)
		if ai_provider.status_changed.is_connected(_on_ai_status_changed):
			ai_provider.status_changed.disconnect(_on_ai_status_changed)

	ai_provider = provider
	if ai_provider:
		if not ai_provider.response_received.is_connected(_on_response_received):
			ai_provider.response_received.connect(_on_response_received)
		if not ai_provider.tool_call_received.is_connected(_on_tool_calls):
			ai_provider.tool_call_received.connect(_on_tool_calls)
		if not ai_provider.audio_received.is_connected(_on_audio_received):
			ai_provider.audio_received.connect(_on_audio_received)
		if not ai_provider.error_occurred.is_connected(_on_ai_error):
			ai_provider.error_occurred.connect(_on_ai_error)
		if not ai_provider.status_changed.is_connected(_on_ai_status_changed):
			ai_provider.status_changed.connect(_on_ai_status_changed)
	if orchestrator:
		orchestrator.setup(ai_provider, _tool_executor)


func _setup_regexes():
	_regex_code_block = RegEx.new()
	_regex_code_block.compile("```[a-zA-Z0-9_-]*\\r?\\n([\\s\\S]*?)```")
	_regex_suggest = RegEx.new()
	_regex_suggest.compile("\\[SUGGEST:\\s*(.+?)\\]")
	_regex_md_link = RegEx.new()
	_regex_md_link.compile("\\[([^\\]]+)\\]\\(([^\\)]+)\\)")
	_regex_bold_italic = RegEx.new()
	_regex_bold_italic.compile("(\\*\\*\\*|___)(.+?)\\1")
	_regex_bold = RegEx.new()
	_regex_bold.compile("(\\*\\*|__)(.+?)\\1")
	_regex_italic = RegEx.new()
	_regex_italic.compile("(?<![*_])([*_])(?![*_])(.+?)(?<![*_])\\1(?![*_])")
	_regex_strike = RegEx.new()
	_regex_strike.compile("~~(.+?)~~")
	_regex_code = RegEx.new()
	_regex_code.compile("`([^`\\n]+)`")
	_regex_hr = RegEx.new()
	_regex_hr.compile("^[ \\t]*([*\\-_][ \\t]*){3,}[ \\t]*$")
	_regex_h4 = RegEx.new()
	_regex_h4.compile("^####\\s+(.+)$")
	_regex_h3 = RegEx.new()
	_regex_h3.compile("^###\\s+(.+)$")
	_regex_h2 = RegEx.new()
	_regex_h2.compile("^##\\s+(.+)$")
	_regex_h1 = RegEx.new()
	_regex_h1.compile("^#\\s+(.+)$")
	_regex_blockquote = RegEx.new()
	_regex_blockquote.compile("^>\\s*(.+)$")
	_regex_list_nested = RegEx.new()
	_regex_list_nested.compile("^([ \\t]{2,})[-*+]\\s+(.+)$")
	_regex_list_item = RegEx.new()
	_regex_list_item.compile("^[-*+]\\s+(.+)$")

func _setup_command_popup():
	command_popup = PopupMenu.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.11, 0.12, 0.15, 0.98)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.3, 0.5, 0.9, 0.6)
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	command_popup.add_theme_stylebox_override("panel", panel_style)
	command_popup.transparent_bg = true
	_dock_owner.add_child(command_popup)
	command_popup.id_pressed.connect(_on_command_selected)

func _connect_signals():
	if send_button and not send_button.pressed.is_connected(_on_send_pressed):
		send_button.pressed.connect(_on_send_pressed)
	if input_field:
		if not input_field.gui_input.is_connected(_on_input_gui_input):
			input_field.gui_input.connect(_on_input_gui_input)
		if not input_field.text_changed.is_connected(_on_input_text_changed):
			input_field.text_changed.connect(_on_input_text_changed)
			
	if magic_actions_btn and not magic_actions_btn.get_popup().id_pressed.is_connected(_on_magic_action_id_pressed):
		magic_actions_btn.get_popup().id_pressed.connect(_on_magic_action_id_pressed)
	if prompt_settings_btn and not prompt_settings_btn.get_popup().id_pressed.is_connected(_on_prompt_setting_id_pressed):
		prompt_settings_btn.get_popup().id_pressed.connect(_on_prompt_setting_id_pressed)
		
	if new_chat_button and not new_chat_button.pressed.is_connected(_on_new_chat_pressed):
		new_chat_button.pressed.connect(_on_new_chat_pressed)
	if summarize_btn and not summarize_btn.pressed.is_connected(_on_summarize_pressed):
		summarize_btn.pressed.connect(_on_summarize_pressed)
	if history_button:
		if not history_button.get_popup().about_to_popup.is_connected(_on_history_popup_about_to_show):
			history_button.get_popup().about_to_popup.connect(_on_history_popup_about_to_show)
		if not history_button.get_popup().id_pressed.is_connected(_on_history_item_pressed):
			history_button.get_popup().id_pressed.connect(_on_history_item_pressed)
			
	if execute_plan_btn and not execute_plan_btn.pressed.is_connected(_on_execute_plan_pressed):
		execute_plan_btn.pressed.connect(_on_execute_plan_pressed)
		
	if add_file_btn and not add_file_btn.pressed.is_connected(func(): _add_file_dialog.popup_centered()):
		add_file_btn.pressed.connect(func(): _add_file_dialog.popup_centered())
	if _add_file_dialog and not _add_file_dialog.file_selected.is_connected(_on_add_file_selected):
		_add_file_dialog.file_selected.connect(_on_add_file_selected)
	if _file_clear_btn and not _file_clear_btn.pressed.is_connected(_on_clear_dropped_files):
		_file_clear_btn.pressed.connect(_on_clear_dropped_files)
		
	# TTS
	if tts_play_btn and not tts_play_btn.pressed.is_connected(_on_tts_play_pressed):
		tts_play_btn.pressed.connect(_on_tts_play_pressed)
	if tts_stop_btn and not tts_stop_btn.pressed.is_connected(_on_tts_stop_pressed):
		tts_stop_btn.pressed.connect(_on_tts_stop_pressed)
	if tts_speed_selector and not tts_speed_selector.item_selected.is_connected(_on_tts_speed_changed):
		tts_speed_selector.item_selected.connect(_on_tts_speed_changed)
	if tts_player and not tts_player.finished.is_connected(_on_tts_finished):
		tts_player.finished.connect(_on_tts_finished)

	if tts_seek_slider:
		if not tts_seek_slider.drag_started.is_connected(func(): _is_dragging_tts_slider = true):
			tts_seek_slider.drag_started.connect(func(): _is_dragging_tts_slider = true)
		if not tts_seek_slider.drag_ended.is_connected(_on_tts_slider_drag_ended):
			tts_seek_slider.drag_ended.connect(_on_tts_slider_drag_ended)

	# Drag & drop forwarding
	if input_field and chat_scroll:
		input_field.set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)
		chat_scroll.set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)

func _connect_tool_executor():
	if _tool_executor:
		if not _tool_executor.tool_output.is_connected(_on_tool_output):
			_tool_executor.tool_output.connect(_on_tool_output)
		if not _tool_executor.confirmation_needed.is_connected(_on_confirmation_needed):
			_tool_executor.confirmation_needed.connect(_on_confirmation_needed)
		if not _tool_executor.image_captured.is_connected(_on_image_captured):
			_tool_executor.image_captured.connect(_on_image_captured)

func set_font_size(new_size: int):
	_current_font_size = new_size
	for child in chat_vbox.get_children():
		var label = child.find_child("RichTextLabel", true, false)
		if label and label is RichTextLabel:
			label.add_theme_font_size_override("normal_font_size", _current_font_size)
			label.add_theme_font_size_override("bold_font_size", _current_font_size)
			label.add_theme_font_size_override("italics_font_size", _current_font_size)
			label.add_theme_font_size_override("bold_italics_font_size", _current_font_size)
			label.add_theme_font_size_override("mono_font_size", _current_font_size)

# ===================== PROMPT SENDING & STOPPING =====================

func _on_send_pressed():
	if (ai_provider and ai_provider.is_requesting) or not batch_queue.is_empty():
		_stop_ai_generation()
		return
		
	if input_field == null: return
	var text = input_field.text.strip_edges()
	if text == "" and _attached_files.is_empty() and _dropped_files.is_empty():
		return
	_process_send(text)

func _stop_ai_generation():
	_is_stopped = true
	batch_queue.clear()
	batch_results.clear()
	current_tool_context = {}
	if ai_provider:
		ai_provider.cancel_request()
	_update_send_button_state(false)
	_add_to_chat("\n[color=orange][b]⏹️ AI generation stopped by user.[/b][/color]\n", "system")

func _on_ai_status_changed(is_req: bool):
	_update_send_button_state(is_req)

func _get_button_icon(icon_name: String) -> Texture2D:
	if _dock_owner and _dock_owner.has_method("_load_svg_icon"):
		return _dock_owner._load_svg_icon("res://addons/gamedev_ai/assets/icons/" + icon_name + ".svg", "ffffff", 0.75)
	var path = "res://addons/gamedev_ai/assets/icons/" + icon_name + ".svg"
	if ResourceLoader.exists(path):
		return load(path)
	return null

func _update_send_button_state(is_req: bool):
	if not send_button or not is_instance_valid(send_button):
		return
		
	if is_req:
		send_button.icon = _get_button_icon("stop")
		send_button.tooltip_text = "Stop AI generation"
		var stop_style = StyleBoxFlat.new()
		stop_style.bg_color = Color(0.85, 0.22, 0.22)
		stop_style.corner_radius_top_left = 20
		stop_style.corner_radius_top_right = 20
		stop_style.corner_radius_bottom_right = 20
		stop_style.corner_radius_bottom_left = 20
		send_button.add_theme_stylebox_override("normal", stop_style)
		send_button.add_theme_stylebox_override("hover", stop_style)
		send_button.add_theme_stylebox_override("pressed", stop_style)
	else:
		send_button.icon = _get_button_icon("send")
		send_button.tooltip_text = "Send your message to the AI"
		var send_style = StyleBoxFlat.new()
		send_style.bg_color = Color(0.15, 0.6, 0.35)
		send_style.corner_radius_top_left = 20
		send_style.corner_radius_top_right = 20
		send_style.corner_radius_bottom_right = 20
		send_style.corner_radius_bottom_left = 20
		send_button.add_theme_stylebox_override("normal", send_style)
		send_button.add_theme_stylebox_override("hover", send_style)
		send_button.add_theme_stylebox_override("pressed", send_style)

func _process_send(prompt_text: String, is_execute_plan: bool = false, is_watch_mode: bool = false):
	if _is_game_running() and not is_watch_mode:
		_add_to_chat("\n[color=orange][b]" + locale_manager.tr("game_running_warning") + "[/color]\n", "system")
		return
	_is_stopped = false
	_watch_fix_count = 0
	
	if not is_execute_plan:
		var est_tokens = int(prompt_text.length() / 4.0)
		_log_user_message(prompt_text, est_tokens)
		input_field.text = ""
	else:
		_add_to_chat("\n[color=cyan][b]" + locale_manager.tr("executing_plan") + "[/b][/color]\n")
	
	if prompt_text.begins_with("/orchestrate"):
		var task = prompt_text.trim_prefix("/orchestrate").strip_edges()
		if task == "":
			_add_to_chat("\n[color=yellow][b]Usage:[/b] /orchestrate <feature description>[/color]\nExample: /orchestrate Create a Coin Pickup System with HUD and Sound\n", "system")
			return
		if orchestrator:
			orchestrator.start_orchestration(task)
			return

	if prompt_text.begins_with("/sfx"):
		var sfx_arg = prompt_text.trim_prefix("/sfx").strip_edges()
		if sfx_arg == "":
			_add_to_chat("\n[color=cyan][b]🎵 Procedural SFX Generator:[/b][/color]\nUsage: `/sfx <preset or description>` (e.g. `/sfx coin`, `/sfx jump`, `/sfx laser`, `/sfx explosion`)\nAvailable presets: `coin`, `laser`, `jump`, `hit`, `hurt`, `explosion`, `powerup`, `blip`, `ui_click`, `dash`, `game_over`, `victory`\n", "system")
			return
		if _tool_executor:
			_tool_executor.execute_tool("generate_sfx", {"preset": sfx_arg})
			return

	if prompt_text.begins_with("/shader"):
		var shader_arg = prompt_text.trim_prefix("/shader").strip_edges()
		if shader_arg == "":
			_add_to_chat("\n[color=pink][b]🎨 Visual Shader & Material Synthesizer:[/b][/color]\nUsage: `/shader <preset or description>` (e.g. `/shader hit_flash`, `/shader toon_cel`, `/shader dissolve_2d`, `/shader water_ripple`)\nAvailable presets: `hit_flash`, `dissolve_2d`, `outline_2d`, `shield_bubble`, `pixelate_2d`, `vhs_glitch`, `hologram_2d`, `water_ripple`, `wind_sway_2d`, `fire_lava`, `toon_cel`, `fresnel_rim`, `stylized_water_3d`, `dissolve_3d`, `hologram_3d`, `foliage_wind_3d`\n", "system")
			return
		if _tool_executor:
			_tool_executor.execute_tool("generate_shader", {"preset": shader_arg})
			return
	
	var selection = {}
	if context_manager:
		selection = context_manager.get_selection_info()
	
	var final_prompt = prompt_text
	if not selection.is_empty() and not is_execute_plan:
		final_prompt = "Selection Context (File: " + selection.path + "):\n```gdscript\n" + selection.text + "\n```\n\nCommand: " + prompt_text
		_add_to_chat("[i]Using selection from " + selection.path.get_file() + "...[/i]\n")
	
	var context_str = ""
	if context_enabled and context_manager:
		context_str = context_manager.build_context()
	
	var images = []
	if screenshot_enabled and context_manager:
		var screenshot = context_manager.get_editor_screenshot()
		if not screenshot.is_empty():
			images.append(screenshot)
			
	var text_attachments = ""
	for att in _attached_files:
		if att["type"] == "image":
			var raw = att.get("raw_bytes", PackedByteArray())
			var b64 = Marshalls.raw_to_base64(raw) if not raw.is_empty() else ""
			images.append({
				"filename": att["filename"],
				"mime_type": att.get("mime_type", "image/png"),
				"raw_bytes": raw,
				"data": b64,
				"image_obj": att.get("image_obj", null)
			})
		elif att["type"] == "text":
			text_attachments += "\n\n--- Attached Reference File: " + att["filename"] + " ---\n" + att.get("text_content", "")
	
	if text_attachments != "":
		final_prompt += text_attachments
		
	# Clear attached files and hide the UI preview so it doesn't persist across messages
	_attached_files.clear()
	_refresh_thumbnails()
	_on_clear_dropped_files()
	
	var tools_list = _get_filtered_tools()
	if ai_provider:
		ai_provider.send_prompt(final_prompt, context_str, tools_list, images)
	else:
		_add_to_chat("\n[color=red]Error: AI Provider is not configured. Please check your settings in Configurações.[/color]\n", "system")

func _get_filtered_tools() -> Array:
	var tools = []
	if _tool_executor:
		tools = _tool_executor.get_tool_definitions()
		if not screenshot_enabled:
			var filtered = []
			for t in tools:
				if t.get("name") != "capture_editor_screenshot":
					filtered.append(t)
			return filtered
	return tools

func _is_game_running() -> bool:
	return EditorInterface.is_playing_scene()

func _log_user_message(msg: String, token_count: int = -1, insert_index: int = -1):
	var header = ""
	if token_count != -1:
		header += "\n[right][i][color=gray](Est. Tokens: ~" + str(token_count) + ")[/color][/i][/right]\n"
	_add_to_chat(header + msg + "\n", "user", insert_index)

func _add_to_chat(bbcode: String, role: String = "system", insert_index: int = -1):
	_chat_log_bbcode += bbcode
	
	if _current_bubble == null or _current_role != role:
		_create_chat_bubble(role, insert_index)
		
	_current_bubble.append_text(bbcode)
	
	var current_bb = _current_bubble.get_meta("raw_bbcode", "")
	_current_bubble.set_meta("raw_bbcode", current_bb + bbcode)
	
	if insert_index == -1 and _dock_owner and _dock_owner.is_inside_tree():
		await _dock_owner.get_tree().process_frame
		var v_scroll = chat_scroll.get_v_scroll_bar()
		if v_scroll:
			v_scroll.value = v_scroll.max_value

func _create_chat_bubble(role: String, insert_index: int = -1):
	_current_role = role
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	
	var inner_hbox = HBoxContainer.new()
	inner_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner_hbox.add_theme_constant_override("separation", 12)
	
	var text_vbox = VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.selection_enabled = true
	label.meta_clicked.connect(_on_meta_clicked)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_current_bubble = label
	text_vbox.add_child(label)
	
	if _current_font_size != 14:
		label.add_theme_font_size_override("normal_font_size", _current_font_size)
		label.add_theme_font_size_override("bold_font_size", _current_font_size)
		label.add_theme_font_size_override("italics_font_size", _current_font_size)
		label.add_theme_font_size_override("bold_italics_font_size", _current_font_size)
		label.add_theme_font_size_override("mono_font_size", _current_font_size)
		
	if role == "user":
		style.bg_color = Color(0.18, 0.22, 0.3)
	elif role == "ai":
		style.bg_color = Color(0.13, 0.14, 0.18)
	else:
		style.bg_color = Color(0.10, 0.10, 0.12)
		
	inner_hbox.add_child(text_vbox)
	panel.add_child(inner_hbox)
	
	if insert_index >= 0 and insert_index < chat_vbox.get_child_count():
		chat_vbox.add_child(panel)
		chat_vbox.move_child(panel, insert_index)
	else:
		chat_vbox.add_child(panel)

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

func _toggle_block(id: int):
	if not _block_data.has(id): return
	var data = _block_data[id]
	data.expanded = !data.expanded
	if data.has("bubble_ref") and is_instance_valid(data.bubble_ref):
		var raw = data.bubble_ref.get_meta("raw_bbcode", "")
		data.bubble_ref.text = raw

func _on_response_received(response: String):
	_update_send_button_state(false)
	if _dock_owner and _dock_owner.git_ctrl and _dock_owner.git_ctrl.handle_ai_commit_response(response):
		return
	_last_ai_response_text = response
	_add_to_chat(_markdown_to_bbcode(response), "ai")

func _on_tool_calls(tool_calls: Array):
	if _is_stopped:
		_update_send_button_state(false)
		return
	_update_send_button_state(true)
	batch_queue = tool_calls.duplicate()
	batch_results.clear()
	_batch_total = tool_calls.size()
	
	if not batch_queue.is_empty():
		var first_tool = batch_queue[0]
		var action_name = "AI Batch: " + first_tool.get("name", "Unknown")
		if _tool_executor and _tool_executor.has_method("start_composite_action"):
			_tool_executor.start_composite_action(action_name)
			
		_process_next_batch_item()

func _process_next_batch_item():
	if _is_stopped:
		return
	if batch_queue.is_empty():
		return
		
	var call_data = batch_queue.pop_front()
	current_tool_context = call_data 
	
	var tool_name = call_data.get("name", "")
	var args = call_data.get("args", {})
	
	var step = _batch_total - batch_queue.size()
	var progress = "[" + str(step) + "/" + str(_batch_total) + "] " if _batch_total > 1 else ""
	
	var arg_str = JSON.stringify(args, "  ")
	_append_collapsible_block(progress + "Tool Call: " + tool_name, arg_str, "yellow", false)
		
	if _tool_executor:
		_tool_executor.execute_tool(tool_name, args)

func _on_tool_output(output):
	if _is_stopped:
		return
		
	var out_str = str(output)
	var line_count = out_str.count("\n") + 1
	var label = "Tool Output " + ("(" + str(line_count) + " lines)" if line_count > 1 else "")
	_append_collapsible_block(label, out_str, "dodgerblue", false)
	
	if not current_tool_context.is_empty() and ai_provider:
		var tool_id = current_tool_context.get("id", "")
		var response_part = ai_provider.generate_tool_response(current_tool_context.get("name", ""), out_str, tool_id)
		batch_results.append(response_part)
		current_tool_context = {}
	
	if not batch_queue.is_empty():
		if _dock_owner and _dock_owner.is_inside_tree():
			await _dock_owner.get_tree().process_frame
		_process_next_batch_item()
	else:
		if ai_provider and not batch_results.is_empty():
			_add_to_chat("\n[i]" + locale_manager.tr("sending_batch_results") + "[/i]\n")
			var tools = _get_filtered_tools()
			ai_provider.send_tool_responses(batch_results, tools, [])
			batch_results.clear()
			
		if _tool_executor and _tool_executor.has_method("commit_composite_action"):
			_tool_executor.commit_composite_action()

func _on_confirmation_needed(message: String, tool_name: String, args: Dictionary):
	_append_collapsible_block("Confirmation Required", message, "orange", true)

func _on_image_captured(image_path: String):
	_attach_file_from_path(image_path)

func _on_ai_error(error: String):
	_update_send_button_state(false)
	if _dock_owner and _dock_owner.git_ctrl and _dock_owner.git_ctrl.handle_ai_commit_error():
		return
	_add_to_chat("\n[color=red]Error: " + error + "[/color]\n")


func handle_engine_log(entry: Dictionary):
	if not watch_mode_enabled: return
	if entry.type == "error":
		var now = Time.get_ticks_msec() / 1000.0
		if now < _watch_cooldown_until: return
		if _watch_fix_count >= _WATCH_MAX_FIXES: return
		
		_watch_fix_count += 1
		_watch_cooldown_until = now + _WATCH_COOLDOWN_SECS
		var fix_prompt = "Fix Engine Error:\n" + entry.message
		_process_send(fix_prompt, false, true)

func _markdown_to_bbcode(text: String) -> String:
	var out = text
	
	# 1. Extract and preserve multiline code blocks
	var code_blocks: Array = []
	if _regex_code_block:
		var matches = _regex_code_block.search_all(out)
		for i in range(matches.size() - 1, -1, -1):
			var m = matches[i]
			var code_content = m.get_string(1)
			# Escape bbcode brackets inside code block
			code_content = code_content.replace("[", "[lb]")
			var formatted_block = "\n[code][bgcolor=#181b22][color=#c9d1d9]" + code_content + "[/color][/bgcolor][/code]\n"
			var placeholder = "@@@CODE_BLOCK_" + str(i) + "@@@"
			code_blocks.append({"placeholder": placeholder, "content": formatted_block})
			out = out.substr(0, m.get_start()) + placeholder + out.substr(m.get_end())
	
	# 2. Convert clickable suggestions [SUGGEST: ...] -> [url=suggest:...]
	if _regex_suggest:
		out = _regex_suggest.sub(out, "\n[indent][color=#58a6ff]💡 [url=suggest:$1][b][u]$1[/u][/b][/url][/color][/indent]", true)
	
	# 3. Convert Markdown Links [text](url) -> [url=url][color=...][u]text[/u][/color][/url]
	if _regex_md_link:
		out = _regex_md_link.sub(out, "[url=$2][color=#58a6ff][u]$1[/u][/color][/url]", true)
	
	# 4. Line-by-line formatting (Headers, Lists, Blockquotes, HR)
	var lines = out.split("\n")
	var processed_lines: Array = []
	for line in lines:
		var pline = line
		if _regex_hr and _regex_hr.search(pline):
			pline = "[color=#30363d]────────────────────────────────────────[/color]"
		elif _regex_h1 and _regex_h1.search(pline):
			pline = _regex_h1.sub(pline, "[font_size=18][b][color=#ffffff]$1[/color][/b][/font_size]")
		elif _regex_h2 and _regex_h2.search(pline):
			pline = _regex_h2.sub(pline, "[font_size=16][b][color=#79c0ff]$1[/color][/b][/font_size]")
		elif _regex_h3 and _regex_h3.search(pline):
			pline = _regex_h3.sub(pline, "[font_size=15][b][color=#a5d6ff]$1[/color][/b][/font_size]")
		elif _regex_h4 and _regex_h4.search(pline):
			pline = _regex_h4.sub(pline, "[b][color=#e6edf3]$1[/color][/b]")
		elif _regex_blockquote and _regex_blockquote.search(pline):
			pline = _regex_blockquote.sub(pline, "[indent][color=#8b949e][i]$1[/i][/color][/indent]")
		elif _regex_list_nested and _regex_list_nested.search(pline):
			pline = _regex_list_nested.sub(pline, "[indent]  • $2[/indent]")
		elif _regex_list_item and _regex_list_item.search(pline):
			pline = _regex_list_item.sub(pline, "  • $1")
		processed_lines.append(pline)
	out = "\n".join(processed_lines)
	
	# 5. Inline formatting (Code, Bold, Italic, Strikethrough)
	if _regex_code:
		out = _regex_code.sub(out, "[code][color=#7ee787]$1[/color][/code]", true)
	if _regex_bold_italic:
		out = _regex_bold_italic.sub(out, "[b][i]$2[/i][/b]", true)
	if _regex_bold:
		out = _regex_bold.sub(out, "[b]$2[/b]", true)
	if _regex_italic:
		out = _regex_italic.sub(out, "[i]$2[/i]", true)
	if _regex_strike:
		out = _regex_strike.sub(out, "[s]$1[/s]", true)
	
	# 6. Restore preserved code blocks
	for item in code_blocks:
		out = out.replace(item["placeholder"], item["content"])
	
	return out

const MAX_UI_BLOCK_LINES = 16
const MAX_UI_BLOCK_CHARS = 1000

func _append_collapsible_block(label: String, content: String, color: String, expanded: bool):
	var id = _next_block_id
	_next_block_id += 1
	var safe_content = content.replace("[", "[lb]")
	_block_data[id] = {"label": label, "content": safe_content, "color": color, "expanded": expanded}
	
	var lines = safe_content.split("\n")
	var display_text = safe_content
	if lines.size() > MAX_UI_BLOCK_LINES or safe_content.length() > MAX_UI_BLOCK_CHARS:
		var preview_lines = []
		var count = mini(lines.size(), 8)
		for i in range(count):
			preview_lines.append(lines[i])
		var omitted = lines.size() - count
		preview_lines.append("... [i][color=gray](+ " + str(omitted) + " lines hidden from preview - full data sent to AI)[/color][/i]")
		display_text = "\n".join(preview_lines)
		
	_add_to_chat("\n[color=" + color + "]⚙ " + label + ":[/color]\n[indent]" + display_text + "[/indent]\n")

# ===================== CHAT CONTROLS & POPUPS =====================

func _on_new_chat_pressed():
	for child in chat_vbox.get_children():
		child.queue_free()
	_chat_log_bbcode = ""
	_current_bubble = null
	_current_role = ""
	_block_data.clear()
	_attached_files.clear()
	_refresh_thumbnails()
	if ai_provider:
		ai_provider.new_session()
	_add_to_chat("[i]" + locale_manager.tr("new_chat_started") + "[/i]\n")

func _on_summarize_pressed():
	if _chat_log_bbcode.strip_edges() == "": return
	var prompt = "Summarize the key architectural decisions, mechanics, and code from this conversation into concise project memory bullet points:\n\n" + _chat_log_bbcode
	if ai_provider:
		ai_provider.send_prompt(prompt, "", [], [])

func _on_history_popup_about_to_show():
	_history_offset = 0
	_refresh_history_list()

func _refresh_history_list():
	if not history_button: return
	var popup = history_button.get_popup()
	popup.clear()
	if ai_provider == null:
		popup.add_item("No AI Provider configured", 0)
		popup.set_item_disabled(0, true)
		return
		
	_history_ids = ai_provider.list_sessions(0, HISTORY_LIMIT)
	if _history_ids.is_empty():
		popup.add_item(locale_manager.tr("no_history_saved") if locale_manager else "No chat history saved", 0)
		popup.set_item_disabled(0, true)
		return

	for i in range(_history_ids.size()):
		var session = _history_ids[i]
		var title = session.get("title", "Chat " + str(i + 1))
		popup.add_item(title, i)
		
	if _history_ids.size() == HISTORY_LIMIT:
		popup.add_separator()
		popup.add_item("🔄 " + (locale_manager.tr("load_more") if locale_manager else "Load more..."), 9999)

func _load_more_history():
	if ai_provider == null: return
	_history_offset += HISTORY_LIMIT
	var new_sessions = ai_provider.list_sessions(_history_offset, HISTORY_LIMIT)
	if new_sessions.is_empty(): return
	
	var popup = history_button.get_popup()
	var item_cnt = popup.item_count
	if item_cnt >= 2 and popup.get_item_id(item_cnt - 1) == 9999:
		popup.remove_item(item_cnt - 1)
		popup.remove_item(item_cnt - 2)
		
	for session in new_sessions:
		var idx = _history_ids.size()
		_history_ids.append(session)
		var title = session.get("title", "Chat " + str(idx + 1))
		popup.add_item(title, idx)

func _on_history_item_pressed(id: int):
	if id == 9999:
		_load_more_history()
		return
		
	if id >= 0 and id < _history_ids.size():
		var session = _history_ids[id]
		var session_id = session.get("id", "")
		if session_id != "" and ai_provider and ai_provider.load_session(session_id):
			_rebuild_chat_from_transcript()
			_add_to_chat("\n[color=gray]" + locale_manager.tr("chat_loaded") + session.get("title", "") + " ---[/color]\n")

func _rebuild_chat_from_transcript():
	for child in chat_vbox.get_children():
		child.queue_free()
	_chat_log_bbcode = ""
	_current_bubble = null
	_current_role = ""
	_block_data.clear()
	_attached_files.clear()
	_refresh_thumbnails()
		
	if ai_provider == null or not ("transcript" in ai_provider):
		return
		
	var all_entries = ai_provider.transcript
	for entry in all_entries:
		var role = entry.get("role", "user")
		var text = entry.get("text", "")
		if role == "user":
			_log_user_message(text)
		else:
			_add_to_chat(_markdown_to_bbcode(text) + "\n", "ai")

func _on_execute_plan_pressed():
	if _plan_pending:
		_plan_pending = false
		execute_plan_btn.visible = false
		_process_send("Execute the approved plan step by step.", true)

func _on_magic_action_id_pressed(id: int):
	match id:
		0: _process_send("Refactor the current script following clean code principles.")
		1: _process_send("Fix errors in the selected code snippet.")
		2: _process_send("Explain how the selected code works.")
		3: if _tool_executor: _tool_executor.undo()
		4: _process_send("Analyze and fix the latest console errors.")

func _on_prompt_setting_id_pressed(id: int):
	var popup = prompt_settings_btn.get_popup()
	var checked = !popup.is_item_checked(id)
	popup.set_item_checked(id, checked)
	match id:
		0: context_enabled = checked
		1: screenshot_enabled = checked
		2: plan_first_enabled = checked
		3: watch_mode_enabled = checked

func _on_input_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if not event.shift_pressed:
				_dock_owner.get_viewport().set_input_as_handled()
				_on_send_pressed()
				return
		elif event.keycode == KEY_V and (event.ctrl_pressed or event.meta_pressed):
			if _try_paste_image_from_clipboard():
				_dock_owner.get_viewport().set_input_as_handled()
				return

func _try_paste_image_from_clipboard() -> bool:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		return false
	if not DisplayServer.clipboard_has_image():
		return false
	var img = DisplayServer.clipboard_get_image()
	if img == null or img.is_empty():
		return false
		
	# Resize if too large to optimize tokens and bandwidth
	if img.get_width() > 1920 or img.get_height() > 1080:
		var scale_factor = min(1920.0 / img.get_width(), 1080.0 / img.get_height())
		img.resize(int(img.get_width() * scale_factor), int(img.get_height() * scale_factor))
		
	var png_bytes = img.save_png_to_buffer()
	if png_bytes.is_empty():
		return false
		
	var timestamp = Time.get_datetime_dict_from_system()
	var filename = "pasted_image_%02d%02d%02d.png" % [timestamp.hour, timestamp.minute, timestamp.second]
	
	_attached_files.append({
		"type": "image",
		"filename": filename,
		"mime_type": "image/png",
		"image_obj": img,
		"raw_bytes": png_bytes
	})
	_refresh_thumbnails()
	_add_to_chat("\n[color=green][i]🖼️ Image pasted from clipboard: " + filename + "[/i][/color]\n")
	return true

func _on_input_text_changed():
	var text = input_field.text
	if text.begins_with("/"):
		_show_command_popup(text)
	else:
		command_popup.hide()

func _show_command_popup(filter: String):
	command_popup.clear()
	var cmds = [
		{"name": "/sfx", "desc": "Generate procedural SFX (coin, jump, laser...)"},
		{"name": "/orchestrate", "desc": "Run 4-persona multi-agent pipeline"},
		{"name": "/plan", "desc": "Create a detailed implementation plan"},
		{"name": "/debug", "desc": "Investigate and fix a bug"},
		{"name": "/brainstorm", "desc": "Explore ideas and possibilities"},
		{"name": "/create", "desc": "Build a new feature from scratch"}
	]
	var count = 0
	for cmd in cmds:
		if filter == "/" or cmd.name.begins_with(filter):
			command_popup.add_item(cmd.name + " - " + cmd.desc, count)
			command_popup.set_item_metadata(count, cmd.name)
			count += 1
	if count > 0:
		var pos = input_field.global_position + Vector2(0, -command_popup.size.y - 10)
		command_popup.position = Vector2i(pos.x, pos.y)
		command_popup.popup()

func _on_command_selected(id: int):
	var cmd = command_popup.get_item_metadata(id)
	input_field.text = cmd + " "
	input_field.set_caret_column(input_field.text.length())

# ===================== ATTACHMENTS & DRAG & DROP =====================

func _on_add_file_selected(path: String):
	_attach_file_from_path(path)

func _attach_file_from_path(path: String):
	var abs_path = ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	var ext = path.get_extension().to_lower()
	var filename = path.get_file()
	
	if ext in ["png", "jpg", "jpeg", "webp"]:
		var img = Image.new()
		if img.load(abs_path) == OK:
			var file = FileAccess.open(abs_path, FileAccess.READ)
			if file:
				_attached_files.append({
					"type": "image",
					"filename": filename,
					"mime_type": "image/" + ext,
					"image_obj": img,
					"raw_bytes": file.get_buffer(file.get_length())
				})
				_refresh_thumbnails()
				_add_to_chat("\n[color=green][i]Image attached: " + filename + "[/i][/color]\n")
	else:
		var file = FileAccess.open(abs_path, FileAccess.READ)
		if file:
			_attached_files.append({"type": "text", "filename": filename, "text_content": file.get_as_text()})
			_refresh_thumbnails()
			_add_to_chat("\n[color=green][i]File attached: " + filename + "[/i][/color]\n")

func _refresh_thumbnails():
	if not _thumbnail_list or not _image_preview_scroll: return
	for child in _thumbnail_list.get_children(): child.queue_free()
	_image_preview_scroll.visible = not _attached_files.is_empty()
	_image_preview_scroll.custom_minimum_size = Vector2(0, 30)
	
	for i in range(_attached_files.size()):
		var att = _attached_files[i]
		var btn = Button.new()
		var icon = "🖼️ " if att.get("type") == "image" else "📎 "
		btn.text = icon + att["filename"] + " ✕"
		btn.tooltip_text = "Click to remove " + att["filename"]
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.add_theme_font_size_override("font_size", 11)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.18, 0.22, 0.28, 0.95)
		style.border_color = Color(0.35, 0.45, 0.55, 0.8)
		style.set_border_width_all(1)
		style.set_corner_radius_all(6)
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 2
		style.content_margin_bottom = 2
		btn.add_theme_stylebox_override("normal", style)
		
		var style_hover = style.duplicate()
		style_hover.bg_color = Color(0.32, 0.18, 0.22, 0.95)
		style_hover.border_color = Color(0.85, 0.35, 0.35, 0.9)
		btn.add_theme_stylebox_override("hover", style_hover)
		
		var idx = i
		btn.pressed.connect(func(): _remove_attached_file(idx))
		_thumbnail_list.add_child(btn)

func _remove_attached_file(index: int):
	if index >= 0 and index < _attached_files.size():
		_attached_files.remove_at(index)
		_refresh_thumbnails()

func _can_drop_data_fw(_pos = null, data = null, _ctrl = null) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	return data.has("files") or data.has("nodes") or data.has("type")

func _drop_data_fw(_pos = null, data = null, _ctrl = null):
	if typeof(data) != TYPE_DICTIONARY:
		return
	if data.has("files"):
		for f in data["files"]:
			_attach_file_from_path(str(f))
	elif data.has("nodes"):
		for n in data["nodes"]:
			if input_field:
				input_field.text += " $" + str(n)

func _on_clear_dropped_files():
	_dropped_files.clear()
	if _file_preview_container: _file_preview_container.visible = false

# ===================== TTS PLAYER =====================

func _on_tts_play_pressed():
	if _last_ai_response_text == "": return
	if ai_provider:
		ai_provider.request_tts(_last_ai_response_text)

func _on_tts_stop_pressed():
	if tts_player and tts_player.playing:
		tts_player.stop()
		tts_play_btn.disabled = false
		tts_stop_btn.disabled = true

func _on_tts_speed_changed(index: int):
	var speeds = [1.0, 1.25, 1.5, 2.0]
	if index >= 0 and index < speeds.size() and tts_player:
		tts_player.pitch_scale = speeds[index]

func _on_tts_finished():
	tts_play_btn.disabled = false
	tts_stop_btn.disabled = true

func _on_tts_slider_drag_ended(changed: bool):
	_is_dragging_tts_slider = false
	if changed and tts_player and tts_player.playing:
		tts_player.seek(tts_seek_slider.value)

func _on_audio_received(raw_data: PackedByteArray):
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 24000
	stream.data = raw_data
	if tts_player:
		tts_player.stream = stream
		tts_player.play()
		tts_play_btn.disabled = true
		tts_stop_btn.disabled = false

# ===================== MULTI-AGENT ORCHESTRATOR =====================

func _setup_orchestrator():
	var AgentOrchestratorScript = load("res://addons/gamedev_ai/orchestration/agent_orchestrator.gd")
	if AgentOrchestratorScript:
		orchestrator = AgentOrchestratorScript.new()
		orchestrator.setup(ai_provider, _tool_executor)
		orchestrator.status_message.connect(func(msg): _add_to_chat(msg + "\n", "system"))
		orchestrator.stage_started.connect(_on_orchestrator_stage_started)
		orchestrator.stage_completed.connect(_on_orchestrator_stage_completed)
		orchestrator.pipeline_completed.connect(_on_orchestrator_pipeline_completed)
		orchestrator.pipeline_failed.connect(func(err): _add_to_chat("\n[color=red]❌ Pipeline Failed: " + err + "[/color]\n", "system"))

func _on_orchestrator_stage_started(role: int, role_name: String):
	var icon = "🤖"
	var PersonaConfigScript = load("res://addons/gamedev_ai/orchestration/persona_config.gd")
	if PersonaConfigScript:
		icon = PersonaConfigScript.get_persona_icon(role)
	_add_to_chat("\n[b]" + icon + " [" + role_name.to_upper() + " ACTIVE][/b]\n", "system")

func _on_orchestrator_stage_completed(_role: int, role_name: String, _summary: String):
	_add_to_chat("[color=green]✔ Phase " + role_name + " finished.[/color]\n", "system")

func _on_orchestrator_pipeline_completed(_blackboard):
	_add_to_chat("\n[color=green][b]✨ All Multi-Agent Pipeline Stages Completed Successfully![/b][/color]\n", "system")

