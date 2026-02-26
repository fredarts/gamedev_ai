@tool
extends VBoxContainer

var gemini_client
var context_manager
var _tool_executor
var _memory_manager

# Scene node references (unique names from dock.tscn)
@onready var output_display: RichTextLabel = %OutputDisplay
@onready var input_field: TextEdit = %InputField
@onready var send_button: Button = %SendButton
@onready var context_toggle: CheckButton = %ContextToggle
@onready var screenshot_toggle: CheckButton = %ScreenshotToggle
@onready var selection_status: Label = %SelectionStatus
@onready var history_button: MenuButton = %HistoryButton
@onready var new_chat_button: Button = %NewChatButton
@onready var watch_mode_toggle: CheckButton = %WatchModeToggle
@onready var plan_first_toggle: CheckButton = %PlanFirstToggle
@onready var execute_plan_btn: Button = %ExecutePlanBtn
@onready var chat_preset_selector: OptionButton = %ChatPresetSelector
@onready var font_size_minus_btn: Button = %FontSizeMinusBtn
@onready var font_size_plus_btn: Button = %FontSizePlusBtn
@onready var _image_preview_container: HBoxContainer = %ImagePreviewContainer
@onready var _image_preview_label: Label = %ImagePreviewLabel
@onready var _image_clear_btn: Button = %ImageClearBtn
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

var _pasted_image: Image = null
var _dropped_files: Array[String] = []
var _history_ids: Array = []

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

signal preset_changed(config)
signal settings_updated()

func _ready():
	# Connect scene node signals
	$TabContainer/Chat/ActionsContainer/RefactorBtn.pressed.connect(func(): _on_quick_action_pressed("Refactor this code"))
	$TabContainer/Chat/ActionsContainer/FixBtn.pressed.connect(func(): _on_quick_action_pressed("Fix errors in this code"))
	$TabContainer/Chat/ActionsContainer/ExplainBtn.pressed.connect(func(): _on_quick_action_pressed("Explain what this code does"))
	$TabContainer/Chat/ActionsContainer/UndoBtn.pressed.connect(_on_undo_pressed)
	$TabContainer/Chat/ActionsContainer/FixConsoleBtn.pressed.connect(_on_fix_console_pressed)
	%ExecutePlanBtn.pressed.connect(_on_execute_plan_pressed)
	
	send_button.pressed.connect(_on_send_pressed)
	input_field.gui_input.connect(_on_input_gui_input)
	_image_clear_btn.pressed.connect(_on_clear_pasted_image)
	_file_clear_btn.pressed.connect(_on_clear_dropped_files)
	_apply_diff_btn.pressed.connect(_on_apply_diff_pressed)
	_skip_diff_btn.pressed.connect(_on_skip_diff_pressed)
	
	# Enable drag and drop across the main chat interface
	input_field.set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)
	output_display.set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)
	
	chat_preset_selector.item_selected.connect(_on_chat_preset_selected)
	font_size_minus_btn.pressed.connect(_on_font_minus_pressed)
	font_size_plus_btn.pressed.connect(_on_font_plus_pressed)
	
	preset_selector.item_selected.connect(_on_preset_selected)
	$TabContainer/Settings/PresetBar/AddPresetBtn.pressed.connect(_on_add_preset_pressed)
	edit_preset_btn.pressed.connect(_on_edit_preset_pressed)
	$TabContainer/Settings/PresetBar/DelPresetBtn.pressed.connect(_on_delete_preset_pressed)
	close_edit_btn.pressed.connect(_on_close_edit_pressed)
	preset_name_input.text_submitted.connect(_on_rename_preset)
	provider_selector.item_selected.connect(_on_provider_type_changed)
	api_input.text_changed.connect(_on_config_changed)
	model_input.text_changed.connect(_on_config_changed)
	url_input.text_changed.connect(_on_config_changed)
	
	new_chat_button.pressed.connect(_on_new_chat_pressed)
	history_button.get_popup().about_to_popup.connect(_on_history_popup_about_to_show)
	history_button.get_popup().id_pressed.connect(_on_history_item_pressed)
	
	# Add provider options
	provider_selector.add_item("Gemini", 0)
	provider_selector.add_item("OpenAI / OpenRouter", 1)
	
	# Polling timer
	$PollTimer.timeout.connect(_on_poll_timer_timeout)
	
	# Load saved custom prompt
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("gamedev_ai/custom_system_prompt"):
		custom_prompt_input.text = settings.get_setting("gamedev_ai/custom_system_prompt")
	custom_prompt_input.text_changed.connect(_on_custom_prompt_changed)
	
	# Initial sync of instructions if client is already set
	if gemini_client:
		gemini_client.custom_instructions = custom_prompt_input.text
	
	_load_presets()
	
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
	
	output_display.meta_clicked.connect(_on_meta_clicked)
	
	var fs = EditorInterface.get_resource_filesystem()
	if fs and not fs.filesystem_changed.is_connected(_on_filesystem_changed):
		fs.filesystem_changed.connect(_on_filesystem_changed)


func setup(client, manager, executor):
	context_manager = manager
	_tool_executor = executor
	_tool_executor.tool_output.connect(_on_tool_output)
	_tool_executor.confirmation_needed.connect(_on_confirmation_needed)
	_tool_executor.diff_preview_requested.connect(_on_diff_preview_requested)
	
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
		if gemini_client.token_usage_reported.is_connected(_on_token_usage):
			gemini_client.token_usage_reported.disconnect(_on_token_usage)
	
	gemini_client = client
	
	if gemini_client:
		gemini_client.response_received.connect(_on_ai_response)
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
	preset_edit_panel.visible = false

var _current_font_size: int = 14

func _on_font_minus_pressed():
	_current_font_size = max(10, _current_font_size - 2)
	_apply_font_size()

func _on_font_plus_pressed():
	_current_font_size = min(32, _current_font_size + 2)
	_apply_font_size()

func _apply_font_size():
	output_display.add_theme_font_size_override("normal_font_size", _current_font_size)
	output_display.add_theme_font_size_override("bold_font_size", _current_font_size)
	output_display.add_theme_font_size_override("italics_font_size", _current_font_size)
	output_display.add_theme_font_size_override("bold_italics_font_size", _current_font_size)
	output_display.add_theme_font_size_override("mono_font_size", _current_font_size)

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

func _on_new_chat_pressed():
	if gemini_client:
		gemini_client.new_session()
		output_display.clear()
		output_display.append_text("\n[color=gray]--- New Chat Started ---[/color]\n")
		_update_ui_state(false)

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
		output_display.append_text("\n[color=gray]--- Chat Loaded: " + session.title + " ---[/color]\n")

func _rebuild_chat_from_transcript():
	output_display.clear()
	for entry in gemini_client.transcript:
		if entry.role == "user":
			_log_user_message(entry.text)
		else:
			output_display.append_text("\n[b]Response:[/b]\n")
			output_display.append_text(_markdown_to_bbcode(entry.text) + "\n")

func _on_status_changed(is_requesting: bool):
	_update_ui_state(is_requesting)

func _update_ui_state(busy: bool):
	input_field.editable = !busy
	if busy:
		send_button.text = "⏹ Stop"
		send_button.disabled = false
	else:
		send_button.text = "Send"
		send_button.disabled = false

func _on_send_pressed():
	if gemini_client and gemini_client.is_requesting:
		_stop_ai()
		return
	var text = input_field.text.strip_edges()
	if text.is_empty():
		return
		
	_process_send(text)

func _on_execute_plan_pressed():
	execute_plan_btn.visible = false
	_plan_pending = false
	_process_send("Okay, the plan looks good. Please execute the proposed plan now using the appropriate tools.", true)

func _on_quick_action_pressed(action_text: String):
	_process_send(action_text)

func _stop_ai():
	_is_stopped = true
	batch_queue.clear()
	batch_results.clear()
	current_tool_context = {}
	if gemini_client:
		gemini_client.cancel_request()
	output_display.append_text("\n[color=orange][b]⏹ AI stopped by user.[/b][/color]\n")
	_update_ui_state(false)

func _on_input_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER and event.shift_pressed:
			input_field.get_viewport().set_input_as_handled()
			var text = input_field.text.strip_edges()
			if not text.is_empty() or _pasted_image != null:
				_process_send(text)
		elif event.keycode == KEY_V and event.ctrl_pressed:
			var clipboard_image = DisplayServer.clipboard_get_image()
			if clipboard_image and not clipboard_image.is_empty():
				input_field.get_viewport().set_input_as_handled()
				_pasted_image = clipboard_image
				_image_preview_label.text = "Image attached (" + str(clipboard_image.get_width()) + "x" + str(clipboard_image.get_height()) + ")"
				_image_preview_container.visible = true
				output_display.append_text("\n[color=green][i]Image pasted from clipboard.[/i][/color]\n")

func _on_clear_pasted_image():
	_pasted_image = null
	_image_preview_container.visible = false
	output_display.append_text("[i]Image removed.[/i]\n")

func _is_game_running() -> bool:
	return EditorInterface.is_playing_scene()

func _process_send(prompt_text: String, is_execute_plan: bool = false):
	if _is_game_running():
		output_display.append_text("\n[color=orange][b]Game is running![/b] Close the game before sending commands to the AI, as files may be locked for editing.[/color]\n")
		return
	_is_stopped = false
	_watch_fix_count = 0  # Reset watch mode counter on manual user message
	
	if not is_execute_plan:
		var est_tokens = int(prompt_text.length() / 4.0)
		_log_user_message(prompt_text, est_tokens)
		input_field.text = ""
	else:
		output_display.append_text("\n[color=cyan][b]Executing Plan...[/b][/color]\n")
	
	var selection = {}
	if context_manager:
		selection = context_manager.get_selection_info()
	
	var final_prompt = prompt_text
	if not selection.is_empty() and not is_execute_plan:
		final_prompt = "Selection Context (File: " + selection.path + "):\n```gdscript\n" + selection.text + "\n```\n\nCommand: " + prompt_text
		output_display.append_text("[i]Using selection from " + selection.path.get_file() + "...[/i]\n")

	if plan_first_toggle.button_pressed and not is_execute_plan:
		final_prompt += "\n\nCRITICAL INSTRUCTION: The user has enabled 'Plan First' mode. Do NOT output any tool calls to modify files yet. Instead, output a detailed, numbered step-by-step plan explaining exactly what tools you will use and what you will do. This is your planning phase."
		_plan_pending = true
	else:
		_plan_pending = false
		execute_plan_btn.visible = false

	var context = ""
	if context_toggle.button_pressed and context_manager:
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
	
	var image_data = {}
	# Priority: pasted image > screenshot toggle
	if _pasted_image != null:
		image_data = _encode_image(_pasted_image)
		output_display.append_text("[i]Sending pasted image...[/i]\n")
		_pasted_image = null
		_image_preview_container.visible = false
	elif screenshot_toggle.button_pressed and context_manager:
		image_data = context_manager.get_editor_screenshot()
		if not image_data.is_empty():
			output_display.append_text("[i]Capturing screenshot...[/i]\n")

	var tools = []
	if _tool_executor:
		tools = _tool_executor.get_tool_definitions()
	
	if gemini_client:
		gemini_client.send_prompt(final_prompt, context, tools, image_data)
		output_display.append_text("\n[i]Thinking...[/i]\n")
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
			selection_status.text = "Selection: " + selection.path.get_file()
			selection_status.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2)) # Green
		else:
			selection_status.text = "No selection"
			selection_status.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5)) # Gray
			
	# 2. Watch Mode Logic
	if watch_mode_toggle.button_pressed:
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
					output_display.append_text("\n[color=orange][b]Watch Mode:[/b] Reached max auto-fix limit (" + str(_WATCH_MAX_FIXES) + "). Pausing auto-fix to avoid loops. Send a manual message to reset.[/color]\n")
					return
				
				var now = Time.get_unix_time_from_system()
				if now < _watch_cooldown_until:
					return  # Still in cooldown
				
				_watch_fix_count += 1
				_watch_cooldown_until = now + _WATCH_COOLDOWN_SECS
				output_display.append_text("\n[color=orange][b]Watch Mode:[/b] New error detected! Auto-fixing (" + str(_watch_fix_count) + "/" + str(_WATCH_MAX_FIXES) + ")...[/color]\n")
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
	output_display.append_text("\n[color=yellow]" + progress + "Tool Call: " + tool_name + " " + str(args) + "[/color]\n")
	_tool_executor.execute_tool(tool_name, args)

func _on_tool_output(output: String):
	if _is_stopped:
		return
	output_display.append_text("\n[color=green]Tool Output: " + output + "[/color]\n")
	
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
			output_display.append_text("\n[i]Sending batch results back to AI...[/i]\n")
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
		output_display.append_text("\n[i]Undoing last action...[/i]\n")

func _on_fix_console_pressed():
	var errors = _get_error_logs()
	if errors.is_empty():
		output_display.append_text("\n[i]No recent errors found in the console logs.[/i]\n")
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
	output_display.append_text("\n[b]Response:[/b]\n")
	output_display.append_text(_markdown_to_bbcode(response) + "\n")
	
	if _plan_pending:
		execute_plan_btn.visible = true

func _on_ai_error(error: String):
	output_display.append_text("\n[color=red]Error: " + error + "[/color]\n")

func _log_user_message(msg: String, token_count: int = -1):
	var header = "\n[b]You:[/b] "
	if token_count != -1:
		header += "[i][color=gray](Est. Tokens: ~" + str(token_count) + ")[/color][/i] "
	output_display.append_text(header + msg + "\n")

func _on_log_entry(entry: Dictionary):
	var color = "red" if entry.type == "error" else "gray"
	var msg = "\n[color=" + color + "][b]Engine " + entry.type.capitalize() + ":[/b] " + entry.message
	if entry.has("source") and entry.source.file:
		msg += " (" + entry.source.file.get_file() + ":" + str(entry.source.line) + ")"
	msg += "[/color]\n"
	output_display.append_text(msg)

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
		
		result += line + "\n"
	
	if in_code_block:
		result += "[/code]\n"
	
	return result

func _on_confirmation_needed(message: String, _tool_name: String, _args: Dictionary):
	_confirm_dialog.dialog_text = "⚠️ " + message + "\n\nThis action cannot be undone."
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
	output_display.append_text("[color=gray][i]Tokens — Prompt: " + str(prompt) + " | Completion: " + str(completion) + " | Total: " + str(total) + "[/i][/color]\n")

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
			# Support images as primary image if none set, otherwise add as context
			var ext = f.get_extension().to_lower()
			if (ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "webp") and _pasted_image == null:
				var img = Image.load_from_file(f)
				if img:
					_pasted_image = img
					_image_preview_container.visible = true
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
	else:
		OS.shell_open(meta_str)
