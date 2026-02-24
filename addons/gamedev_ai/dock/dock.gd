@tool
extends VBoxContainer

var gemini_client
var context_manager
var _tool_executor

var output_display: RichTextLabel
var input_field: TextEdit
var send_button: Button
var context_toggle: CheckButton
var screenshot_toggle: CheckButton
var selection_status: Label
var history_button: MenuButton
var new_chat_button: Button
var watch_mode_toggle: CheckButton

var _history_ids: Array = []
var _pasted_image: Image = null
var _image_preview_container: HBoxContainer
var _image_preview_label: Label
var _image_clear_btn: Button

var preset_selector: OptionButton
var preset_name_input: LineEdit
var provider_selector: OptionButton
var settings_bar: HBoxContainer
var api_input: LineEdit
var url_input: LineEdit
var model_input: LineEdit

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

# Precompiled regex for markdown parser
var _regex_bold_italic: RegEx
var _regex_bold: RegEx
var _regex_italic: RegEx
var _regex_code: RegEx

signal preset_changed(config)
signal settings_updated()

func _ready():
	# Setup simple UI layout
	name = "Gamedev AI"
	
	# Get Editor Theme Colors
	var font_color = get_theme_color("font_color", "Editor")

	# Preset Bar
	var preset_bar = HBoxContainer.new()
	add_child(preset_bar)
	
	var preset_label = Label.new()
	preset_label.text = "Preset:"
	preset_bar.add_child(preset_label)
	
	preset_selector = OptionButton.new()
	preset_selector.size_flags_horizontal = SIZE_EXPAND_FILL
	preset_selector.item_selected.connect(_on_preset_selected)
	preset_bar.add_child(preset_selector)
	
	var add_preset_btn = Button.new()
	add_preset_btn.text = "+"
	add_preset_btn.tooltip_text = "Add new preset"
	add_preset_btn.pressed.connect(_on_add_preset_pressed)
	preset_bar.add_child(add_preset_btn)
	
	var del_preset_btn = Button.new()
	del_preset_btn.text = "-"
	del_preset_btn.tooltip_text = "Delete current preset"
	del_preset_btn.pressed.connect(_on_delete_preset_pressed)
	preset_bar.add_child(del_preset_btn)

	# Config Section
	var config_grid = GridContainer.new()
	config_grid.columns = 2
	add_child(config_grid)
	
	var name_label = Label.new()
	name_label.text = "Preset Name:"
	config_grid.add_child(name_label)
	
	preset_name_input = LineEdit.new()
	preset_name_input.size_flags_horizontal = SIZE_EXPAND_FILL
	preset_name_input.tooltip_text = "Press Enter to rename current preset"
	preset_name_input.text_submitted.connect(_on_rename_preset)
	config_grid.add_child(preset_name_input)
	
	var provider_label = Label.new()
	provider_label.text = "Provider:"
	config_grid.add_child(provider_label)
	
	provider_selector = OptionButton.new()
	provider_selector.add_item("Gemini", 0)
	provider_selector.add_item("OpenAI / OpenRouter", 1)
	provider_selector.item_selected.connect(_on_provider_type_changed)
	config_grid.add_child(provider_selector)
	
	var api_label = Label.new()
	api_label.text = "API Key:"
	config_grid.add_child(api_label)
	
	api_input = LineEdit.new()
	api_input.size_flags_horizontal = SIZE_EXPAND_FILL
	api_input.secret = true
	api_input.text_changed.connect(_on_config_changed)
	config_grid.add_child(api_input)

	var model_label = Label.new()
	model_label.text = "Model Name:"
	config_grid.add_child(model_label)
	
	model_input = LineEdit.new()
	model_input.size_flags_horizontal = SIZE_EXPAND_FILL
	model_input.placeholder_text = "gemini-1.5-pro or gpt-4o"
	model_input.text_changed.connect(_on_config_changed)
	config_grid.add_child(model_input)
	
	# OpenAI Specific Settings (Base URL only)
	settings_bar = HBoxContainer.new()
	settings_bar.visible = false
	add_child(settings_bar)
	
	var url_label = Label.new()
	url_label.text = "Base URL:"
	settings_bar.add_child(url_label)
	
	url_input = LineEdit.new()
	url_input.size_flags_horizontal = SIZE_EXPAND_FILL
	url_input.placeholder_text = "https://openrouter.ai/api/v1"
	url_input.text_changed.connect(_on_config_changed)
	settings_bar.add_child(url_input)

	var session_bar = HBoxContainer.new()
	add_child(session_bar)
	
	new_chat_button = Button.new()
	new_chat_button.text = "New Chat"
	new_chat_button.pressed.connect(_on_new_chat_pressed)
	session_bar.add_child(new_chat_button)

	history_button = MenuButton.new()
	history_button.text = "History"
	history_button.get_popup().about_to_popup.connect(_on_history_popup_about_to_show)
	history_button.get_popup().id_pressed.connect(_on_history_item_pressed)
	session_bar.add_child(history_button)
	
	_load_presets()
	
	# Output Display
	output_display = RichTextLabel.new()
	output_display.bbcode_enabled = true
	output_display.size_flags_vertical = SIZE_EXPAND_FILL
	output_display.fit_content = false
	output_display.scroll_following = true
	output_display.selection_enabled = true
	output_display.add_theme_color_override("default_color", font_color)
	add_child(output_display)
	
	# Selection Status Label (Above input)
	selection_status = Label.new()
	selection_status.text = "No selection"
	selection_status.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	selection_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(selection_status)
	
	# Quick Actions Container
	var actions_container = HBoxContainer.new()
	add_child(actions_container)
	
	var refactor_btn = Button.new()
	refactor_btn.text = "Refactor"
	refactor_btn.pressed.connect(func(): _on_quick_action_pressed("Refactor this code"))
	actions_container.add_child(refactor_btn)
	
	var fix_btn = Button.new()
	fix_btn.text = "Fix"
	fix_btn.pressed.connect(func(): _on_quick_action_pressed("Fix errors in this code"))
	actions_container.add_child(fix_btn)
	
	var explain_btn = Button.new()
	explain_btn.text = "Explain"
	explain_btn.pressed.connect(func(): _on_quick_action_pressed("Explain what this code does"))
	actions_container.add_child(explain_btn)

	var undo_btn = Button.new()
	undo_btn.text = "Undo Last"
	undo_btn.tooltip_text = "Undo the last AI action batch"
	undo_btn.pressed.connect(_on_undo_pressed)
	actions_container.add_child(undo_btn)
	
	var fix_console_btn = Button.new()
	fix_console_btn.text = "Fix Console"
	fix_console_btn.tooltip_text = "Analyze latest console errors and propose fixes"
	fix_console_btn.pressed.connect(_on_fix_console_pressed)
	actions_container.add_child(fix_console_btn)
	
	# Input Container (Standard layout with field on left, button on right)
	var input_hbox = HBoxContainer.new()
	input_hbox.custom_minimum_size.y = 80
	add_child(input_hbox)
	
	input_field = TextEdit.new()
	input_field.size_flags_horizontal = SIZE_EXPAND_FILL
	input_field.placeholder_text = "Ask Gamedev AI... (Shift+Enter to send)"
	input_field.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	input_field.gui_input.connect(_on_input_gui_input)

	input_hbox.add_child(input_field)
	
	send_button = Button.new()
	send_button.text = "Send"
	send_button.pressed.connect(_on_send_pressed)
	input_hbox.add_child(send_button)
	
	# Image Paste Preview (hidden by default)
	_image_preview_container = HBoxContainer.new()
	_image_preview_container.visible = false
	add_child(_image_preview_container)
	
	_image_preview_label = Label.new()
	_image_preview_label.text = "Image attached"
	_image_preview_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
	_image_preview_container.add_child(_image_preview_label)
	
	_image_clear_btn = Button.new()
	_image_clear_btn.text = "X"
	_image_clear_btn.tooltip_text = "Remove attached image"
	_image_clear_btn.pressed.connect(_on_clear_pasted_image)
	_image_preview_container.add_child(_image_clear_btn)
	
	# Options Toggles
	var toggle_container = HBoxContainer.new()
	add_child(toggle_container)
	
	context_toggle = CheckButton.new()
	context_toggle.text = "Context"
	context_toggle.button_pressed = true
	toggle_container.add_child(context_toggle)

	screenshot_toggle = CheckButton.new()
	screenshot_toggle.text = "Screenshot"
	screenshot_toggle.button_pressed = false
	toggle_container.add_child(screenshot_toggle)
	
	watch_mode_toggle = CheckButton.new()
	watch_mode_toggle.text = "Watch Mode"
	watch_mode_toggle.tooltip_text = "Monitor console for new errors and auto-prompt fix."
	watch_mode_toggle.button_pressed = false
	toggle_container.add_child(watch_mode_toggle)

	# Polling Timer (Selection + Watch Mode)
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(_on_poll_timer_timeout)
	add_child(timer)
	
	# Precompile regex for markdown parser (avoids re-creation per line)
	_regex_bold_italic = RegEx.new()
	_regex_bold_italic.compile("\\*\\*\\*(.+?)\\*\\*\\*")
	_regex_bold = RegEx.new()
	_regex_bold.compile("\\*\\*(.+?)\\*\\*")
	_regex_italic = RegEx.new()
	_regex_italic.compile("(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)")
	_regex_code = RegEx.new()
	_regex_code.compile("`([^`]+)`")

func setup(client, manager, executor):
	context_manager = manager
	_tool_executor = executor
	_tool_executor.tool_output.connect(_on_tool_output)
	
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
	
	gemini_client = client
	
	if gemini_client:
		gemini_client.response_received.connect(_on_ai_response)
		gemini_client.error_occurred.connect(_on_ai_error)
		gemini_client.tool_call_received.connect(_on_tool_calls)
		gemini_client.status_changed.connect(_on_status_changed)

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
	_on_preset_selected(idx)

func _update_preset_selector():
	preset_selector.clear()
	for p_name in presets.keys():
		preset_selector.add_item(p_name)

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
	
	_save_presets()
	preset_changed.emit(config)

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

func _process_send(prompt_text: String):
	if _is_game_running():
		output_display.append_text("\n[color=orange][b]Game is running![/b] Close the game before sending commands to the AI, as files may be locked for editing.[/color]\n")
		return
	_is_stopped = false
	_watch_fix_count = 0  # Reset watch mode counter on manual user message
	
	var est_tokens = int(prompt_text.length() / 4.0)
	_log_user_message(prompt_text, est_tokens)
	input_field.text = ""
	
	var selection = {}
	if context_manager:
		selection = context_manager.get_selection_info()
	
	var final_prompt = prompt_text
	if not selection.is_empty():
		final_prompt = "Selection Context (File: " + selection.path + "):\n```gdscript\n" + selection.text + "\n```\n\nCommand: " + prompt_text
		output_display.append_text("[i]Using selection from " + selection.path.get_file() + "...[/i]\n")

	var context = ""
	if context_toggle.button_pressed and context_manager:
		context += "Engine Info:\n" + context_manager.get_engine_version_context() + "\n"
		context += "Project Structure:\n" + context_manager.get_project_index() + "\n"
		context += "Project Settings:\n" + context_manager.get_project_settings_dump() + "\n"
		context += "Current Scene tree:\n" + context_manager.get_scene_tree_dump() + "\n"
		context += "Current Script content:\n" + context_manager.get_current_script() + "\n"
	
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
	
	output_display.append_text("\n[color=yellow]Tool Call: " + tool_name + " " + str(args) + "[/color]\n")
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
