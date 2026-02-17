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

var _history_ids: Array = []

func _ready():
	# Setup simple UI layout
	name = "Gamedev AI"
	
	# Get Editor Theme Colors
	var font_color = get_theme_color("font_color", "Editor")

	# API Key & Session Container
	var top_bar = HBoxContainer.new()
	add_child(top_bar)
	
	var api_label = Label.new()
	api_label.text = "API Key:"
	top_bar.add_child(api_label)
	
	var api_input = LineEdit.new()
	api_input.size_flags_horizontal = SIZE_EXPAND_FILL
	api_input.secret = true
	api_input.text_changed.connect(_on_api_key_changed)
	top_bar.add_child(api_input)
	
	new_chat_button = Button.new()
	new_chat_button.text = "New"
	new_chat_button.tooltip_text = "Clear history and start a fresh conversation."
	new_chat_button.pressed.connect(_on_new_chat_pressed)
	top_bar.add_child(new_chat_button)

	history_button = MenuButton.new()
	history_button.text = "History"
	history_button.get_popup().about_to_popup.connect(_on_history_popup_about_to_show)
	history_button.get_popup().id_pressed.connect(_on_history_item_pressed)
	top_bar.add_child(history_button)
	
	# Load saved key
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("gamedev_ai/api_key"):
		api_input.text = settings.get_setting("gamedev_ai/api_key")
	
	# Output Display
	output_display = RichTextLabel.new()
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
	input_field.placeholder_text = "Ask Gamedev AI..."
	input_field.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY


	input_hbox.add_child(input_field)
	
	send_button = Button.new()
	send_button.text = "Send"
	send_button.pressed.connect(_on_send_pressed)
	input_hbox.add_child(send_button)
	
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

	# Selection Polling Timer
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(_on_selection_timer_timeout)
	add_child(timer)

func setup(client, manager, executor):
	gemini_client = client
	context_manager = manager
	_tool_executor = executor
	
	gemini_client.response_received.connect(_on_ai_response)
	gemini_client.error_occurred.connect(_on_ai_error)
	gemini_client.tool_call_received.connect(_on_tool_calls)
	gemini_client.status_changed.connect(_on_status_changed)
	
	_tool_executor.tool_output.connect(_on_tool_output)

	# Initialize client with key if available
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("gamedev_ai/api_key"):
		gemini_client.set_api_key(settings.get_setting("gamedev_ai/api_key"))

func _on_api_key_changed(new_text: String):
	var settings = EditorInterface.get_editor_settings()
	settings.set_setting("gamedev_ai/api_key", new_text)
	
	if gemini_client:
		gemini_client.set_api_key(new_text)

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
			# AI Response
			output_display.append_text("\n[b]Gemini:[/b]\n")
			output_display.append_text(entry.text + "\n")

func _on_status_changed(is_requesting: bool):
	_update_ui_state(is_requesting)

func _update_ui_state(busy: bool):
	input_field.editable = !busy
	send_button.disabled = busy
	if busy:
		send_button.text = "..."
	else:
		send_button.text = "Send"

func _on_send_pressed():
	var text = input_field.text.strip_edges()
	if text.is_empty():
		return
		
	_process_send(text)

func _on_quick_action_pressed(action_text: String):
	_process_send(action_text)

func _process_send(prompt_text: String):
	_log_user_message(prompt_text)
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
		context += "Project Settings:\n" + context_manager.get_project_settings_dump() + "\n"
		context += "Current Scene:\n" + context_manager.get_scene_tree_dump() + "\n"
		context += "Current Script:\n" + context_manager.get_current_script() + "\n"
	
	var image_data = {}
	if screenshot_toggle.button_pressed and context_manager:
		image_data = context_manager.get_editor_screenshot()
		if not image_data.is_empty():
			output_display.append_text("[i]Capturing screenshot...[/i]\n")

	var tools = []
	if _tool_executor:
		tools = _tool_executor.get_tool_definitions()
	
	if gemini_client:
		gemini_client.send_prompt(final_prompt, context, tools, image_data)
		output_display.append_text("\n[i]Thinking...[/i]\n")

func _on_selection_timer_timeout():
	if context_manager:
		var selection = context_manager.get_selection_info()
		if not selection.is_empty():
			selection_status.text = "Selection: " + selection.path.get_file()
			selection_status.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2)) # Green
		else:
			selection_status.text = "No selection"
			selection_status.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5)) # Gray

var batch_queue: Array = []
var batch_results: Array = []
var current_tool_context: Dictionary = {}

# Deprecated: Use _on_tool_calls for batch processing
func _on_tool_call(tool_name: String, args: Dictionary):
	# This is a wrapper for backward compatibility if a signal is still connected to the old signature
	# It will treat a single call as a batch of one.
	_on_tool_calls([{"name": tool_name, "args": args}])

func _on_tool_calls(tool_calls: Array):
	# Arguments changed from (name, args) to (tool_calls_array)
	# This function handles the batch start
	batch_queue = tool_calls.duplicate()
	batch_results.clear()
	
	if not batch_queue.is_empty():
		var first_tool = batch_queue[0]
		var action_name = "AI Batch: " + first_tool.get("name", "Unknown")
		if _tool_executor.has_method("start_composite_action"):
			_tool_executor.start_composite_action(action_name)
			
		_process_next_batch_item()

func _process_next_batch_item():
	if batch_queue.is_empty():
		return
		
	var call_data = batch_queue.pop_front()
	current_tool_context = call_data # Store for response mapping
	
	var tool_name = call_data["name"]
	var args = call_data["args"]
	
	output_display.append_text("\n[color=yellow]Tool Call: " + tool_name + " " + str(args) + "[/color]\n")
	_tool_executor.execute_tool(tool_name, args)

func _on_tool_output(output: String):
	output_display.append_text("\n[color=green]Tool Output: " + output + "[/color]\n")
	
	# Construct response object
	if not current_tool_context.is_empty():
		var response_part = {
			"functionResponse": {
				"name": current_tool_context["name"],
				"response": {
					"output": output
				}
			}
		}
		batch_results.append(response_part)
		current_tool_context = {}
	
	# Check if we have more tools to run
	if not batch_queue.is_empty():
		# Small delay to let UI update/Godot process (optional but good for safety)
		await get_tree().process_frame
		_process_next_batch_item()
	else:
		# Batch complete! Send all results back
		if gemini_client and not batch_results.is_empty():
			output_display.append_text("\n[i]Sending batch results back to Gemini...[/i]\n")
			
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
	
	# Session Isolation: Find the LAST occurrence of startup header (usually starts with "Godot Engine v")
	var session_start_index = content.rfind("Godot Engine v")
	if session_start_index != -1:
		content = content.substr(session_start_index)
	
	var lines = content.split("\n")
	var unique_errors = {}
	var filtered_errors = []
	
	for line in lines:
		if "ERROR" in line or "SCRIPT ERROR" in line or "WARNING" in line:
			# Simple deduplication based on exact line text
			if not unique_errors.has(line):
				unique_errors[line] = true
				filtered_errors.append(line)
	
	if filtered_errors.is_empty():
		return ""
		
	return "\n".join(filtered_errors)


func _on_ai_response(response: String):
	# Remove "Thinking..." (simple naive way, better to use unique tags or IDs in real app)
	# For now just append
	output_display.append_text("\n[b]Gemini:[/b]\n")
	output_display.append_text(response + "\n")
	
	# Here we would also check for tool calls in the response if we implemented function calling parsing
	# For now, we assume direct text response

func _on_ai_error(error: String):
	output_display.append_text("\n[color=red]Error: " + error + "[/color]\n")

func _log_user_message(msg: String):
	output_display.append_text("\n[b]You:[/b] " + msg + "\n")

func _on_log_entry(entry: Dictionary):
	var color = "red" if entry.type == "error" else "gray"
	var msg = "\n[color=" + color + "][b]Engine " + entry.type.capitalize() + ":[/b] " + entry.message
	if entry.has("source") and entry.source.file:
		msg += " (" + entry.source.file.get_file() + ":" + str(entry.source.line) + ")"
	msg += "[/color]\n"
	output_display.append_text(msg)
