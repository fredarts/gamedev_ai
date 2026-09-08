@tool
extends RefCounted
class_name DockSettings

var _dock_owner: Node
var locale_manager
var _tool_executor
var ai_provider

var preset_selector: OptionButton
var preset_name_input: LineEdit
var provider_selector: OptionButton
var preset_edit_panel: VBoxContainer
var edit_preset_btn: Button
var close_edit_btn: Button
var add_preset_btn: Button
var del_preset_btn: Button
var settings_bar: HBoxContainer
var api_input: LineEdit
var url_input: LineEdit
var model_input: LineEdit
var language_selector: OptionButton
var language_label: Label
var custom_prompt_input: TextEdit
var font_size_minus_btn: Button
var font_size_plus_btn: Button

var vector_db_file_list: RichTextLabel
var scan_changes_btn: Button
var index_codebase_btn: Button
var index_confirm_dialog: ConfirmationDialog
var index_result_dialog: AcceptDialog
var enhance_prompt_btn: Button
var enhance_preview_dialog: ConfirmationDialog
var enhance_preview_label: RichTextLabel

var presets: Dictionary = {}
var active_preset_name: String = ""
var _local_hint_label: Label = null
var _current_font_size: int = 14
var _enhance_http: HTTPRequest
var _enhanced_text: String = ""
var _card_titles: Array[Label] = []
var _vdb_messages: Array = []

signal preset_changed(config: Dictionary)
signal settings_updated()
signal font_size_changed(new_size: int)

func setup(dock_owner: Node, p_locale_manager, p_tool_executor, p_ai_provider, nodes: Dictionary):
	_dock_owner = dock_owner
	locale_manager = p_locale_manager
	_tool_executor = p_tool_executor
	ai_provider = p_ai_provider
	
	preset_selector = nodes.get("preset_selector")
	preset_name_input = nodes.get("preset_name_input")
	provider_selector = nodes.get("provider_selector")
	preset_edit_panel = nodes.get("preset_edit_panel")
	edit_preset_btn = nodes.get("edit_preset_btn")
	close_edit_btn = nodes.get("close_edit_btn")
	add_preset_btn = nodes.get("add_preset_btn")
	del_preset_btn = nodes.get("del_preset_btn")
	settings_bar = nodes.get("settings_bar")
	api_input = nodes.get("api_input")
	url_input = nodes.get("url_input")
	model_input = nodes.get("model_input")
	language_selector = nodes.get("language_selector")
	language_label = nodes.get("language_label")
	custom_prompt_input = nodes.get("custom_prompt_input")
	font_size_minus_btn = nodes.get("font_size_minus_btn")
	font_size_plus_btn = nodes.get("font_size_plus_btn")
	
	vector_db_file_list = nodes.get("vector_db_file_list")
	scan_changes_btn = nodes.get("scan_changes_btn")
	index_codebase_btn = nodes.get("index_codebase_btn")
	index_confirm_dialog = nodes.get("index_confirm_dialog")
	index_result_dialog = nodes.get("index_result_dialog")
	enhance_prompt_btn = nodes.get("enhance_prompt_btn")
	enhance_preview_dialog = nodes.get("enhance_preview_dialog")
	enhance_preview_label = nodes.get("enhance_preview_label")
	
	_connect_signals()
	_load_presets()
	_populate_language_selector()
	_apply_locale()
	_load_saved_font_size()

func _connect_signals():
	if preset_selector and not preset_selector.item_selected.is_connected(_on_preset_selected):
		preset_selector.item_selected.connect(_on_preset_selected)
	if add_preset_btn and not add_preset_btn.pressed.is_connected(_on_add_preset_pressed):
		add_preset_btn.pressed.connect(_on_add_preset_pressed)
	if edit_preset_btn and not edit_preset_btn.pressed.is_connected(_on_edit_preset_pressed):
		edit_preset_btn.pressed.connect(_on_edit_preset_pressed)
	if del_preset_btn and not del_preset_btn.pressed.is_connected(_on_delete_preset_pressed):
		del_preset_btn.pressed.connect(_on_delete_preset_pressed)
	if close_edit_btn and not close_edit_btn.pressed.is_connected(_on_close_edit_pressed):
		close_edit_btn.pressed.connect(_on_close_edit_pressed)
		
	if preset_name_input:
		if not preset_name_input.text_submitted.is_connected(_on_rename_preset):
			preset_name_input.text_submitted.connect(_on_rename_preset)
		if not preset_name_input.focus_exited.is_connected(func(): _on_rename_preset(preset_name_input.text)):
			preset_name_input.focus_exited.connect(func(): _on_rename_preset(preset_name_input.text))
			
	if provider_selector and not provider_selector.item_selected.is_connected(_on_provider_type_changed):
		provider_selector.item_selected.connect(_on_provider_type_changed)
	if api_input and not api_input.text_changed.is_connected(_on_config_changed):
		api_input.text_changed.connect(_on_config_changed)
	if model_input and not model_input.text_changed.is_connected(_on_config_changed):
		model_input.text_changed.connect(_on_config_changed)
	if url_input and not url_input.text_changed.is_connected(_on_config_changed):
		url_input.text_changed.connect(_on_config_changed)
		
	if font_size_minus_btn and not font_size_minus_btn.pressed.is_connected(_on_font_minus_pressed):
		font_size_minus_btn.pressed.connect(_on_font_minus_pressed)
	if font_size_plus_btn and not font_size_plus_btn.pressed.is_connected(_on_font_plus_pressed):
		font_size_plus_btn.pressed.connect(_on_font_plus_pressed)
		
	if language_selector and not language_selector.item_selected.is_connected(_on_language_changed):
		language_selector.item_selected.connect(_on_language_changed)
		
	if custom_prompt_input and not custom_prompt_input.text_changed.is_connected(_on_custom_prompt_changed):
		custom_prompt_input.text_changed.connect(_on_custom_prompt_changed)
		
	if scan_changes_btn and not scan_changes_btn.pressed.is_connected(_on_scan_changes_pressed):
		scan_changes_btn.pressed.connect(_on_scan_changes_pressed)
	if index_codebase_btn and not index_codebase_btn.pressed.is_connected(_on_index_codebase_pressed):
		index_codebase_btn.pressed.connect(_on_index_codebase_pressed)
	if index_confirm_dialog and not index_confirm_dialog.confirmed.is_connected(_on_index_confirmed):
		index_confirm_dialog.confirmed.connect(_on_index_confirmed)
	if enhance_prompt_btn and not enhance_prompt_btn.pressed.is_connected(_on_enhance_prompt_pressed):
		enhance_prompt_btn.pressed.connect(_on_enhance_prompt_pressed)
	if enhance_preview_dialog and not enhance_preview_dialog.confirmed.is_connected(_on_enhance_accepted):
		enhance_preview_dialog.confirmed.connect(_on_enhance_accepted)

func set_ai_provider(provider):
	ai_provider = provider
	if ai_provider and custom_prompt_input:
		ai_provider.custom_instructions = custom_prompt_input.text
	if ai_provider and locale_manager:
		ai_provider.response_language_instruction = locale_manager.get_ai_language_instruction()

func _load_saved_font_size():
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("gamedev_ai/font_size"):
		_current_font_size = settings.get_setting("gamedev_ai/font_size")

func _on_font_minus_pressed():
	if _current_font_size > 10:
		_current_font_size -= 1
		_save_font_size()
		font_size_changed.emit(_current_font_size)

func _on_font_plus_pressed():
	if _current_font_size < 24:
		_current_font_size += 1
		_save_font_size()
		font_size_changed.emit(_current_font_size)

func _save_font_size():
	var settings = EditorInterface.get_editor_settings()
	settings.set_setting("gamedev_ai/font_size", _current_font_size)

# ===================== PRESETS =====================

func _load_presets():
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("gamedev_ai/presets"):
		presets = settings.get_setting("gamedev_ai/presets")
	if settings.has_setting("gamedev_ai/active_preset"):
		active_preset_name = settings.get_setting("gamedev_ai/active_preset")
		
	if presets.is_empty():
		presets["Google Gemini"] = {"provider": 0, "api_key": "", "base_url": "", "model_name": "gemini-3.1-pro-preview"}
		presets["OpenRouter (Claude/DeepSeek)"] = {"provider": 1, "api_key": "", "base_url": "https://openrouter.ai/api/v1", "model_name": "anthropic/claude-3.7-sonnet"}
		presets["Local (Ollama/LM Studio)"] = {"provider": 2, "api_key": "", "base_url": "http://localhost:11434/v1", "model_name": "llama3"}
		active_preset_name = "Google Gemini"
		_save_presets()
		
	if not presets.has(active_preset_name):
		active_preset_name = presets.keys()[0]
		
	_update_preset_selector()
	_apply_active_preset()

func _save_presets():
	var settings = EditorInterface.get_editor_settings()
	settings.set_setting("gamedev_ai/presets", presets)
	settings.set_setting("gamedev_ai/active_preset", active_preset_name)

func _update_preset_selector():
	if not preset_selector: return
	preset_selector.clear()
	var idx = 0
	var active_idx = 0
	for p_name in presets.keys():
		preset_selector.add_item(p_name)
		if p_name == active_preset_name:
			active_idx = idx
		idx += 1
	preset_selector.select(active_idx)

func _apply_active_preset():
	var config = presets.get(active_preset_name, {})
	var prov = config.get("provider", 0)
	
	if provider_selector: provider_selector.select(prov)
	if api_input: api_input.text = config.get("api_key", "")
	if base_url_supported(prov) and url_input:
		url_input.text = config.get("base_url", "")
	if model_input: model_input.text = config.get("model_name", "")
	
	_update_field_visibilities(prov)
	preset_changed.emit(config)

func base_url_supported(prov: int) -> bool:
	return prov != 0 or true # Supports everywhere

func _update_field_visibilities(prov: int):
	var is_local = (prov == 2)
	if api_input:
		api_input.placeholder_text = "Not required for Local models" if is_local else "Enter API Key"
	if url_input:
		url_input.placeholder_text = "Default: http://localhost:11434/v1" if is_local else "Default: provider official endpoint"

func _on_preset_selected(index: int):
	active_preset_name = preset_selector.get_item_text(index)
	_save_presets()
	_apply_active_preset()

func _on_add_preset_pressed():
	var base_name = "New Preset"
	var new_name = base_name
	var counter = 1
	while presets.has(new_name):
		new_name = base_name + " (" + str(counter) + ")"
		counter += 1
	presets[new_name] = {"provider": 0, "api_key": "", "base_url": "", "model_name": ""}
	active_preset_name = new_name
	_save_presets()
	_update_preset_selector()
	_apply_active_preset()
	_on_edit_preset_pressed()

func _on_edit_preset_pressed():
	if preset_edit_panel:
		preset_edit_panel.visible = true
	if preset_name_input:
		preset_name_input.text = active_preset_name

func _on_close_edit_pressed():
	if preset_edit_panel:
		preset_edit_panel.visible = false

func _on_delete_preset_pressed():
	if presets.size() <= 1: return
	presets.erase(active_preset_name)
	active_preset_name = presets.keys()[0]
	_save_presets()
	_update_preset_selector()
	_apply_active_preset()
	_on_close_edit_pressed()

func _on_rename_preset(new_name: String):
	new_name = new_name.strip_edges()
	if new_name == "" or new_name == active_preset_name or presets.has(new_name):
		return
	var config = presets[active_preset_name]
	presets.erase(active_preset_name)
	presets[new_name] = config
	active_preset_name = new_name
	_save_presets()
	_update_preset_selector()

func _on_provider_type_changed(index: int):
	if presets.has(active_preset_name):
		presets[active_preset_name]["provider"] = index
		_save_presets()
		_apply_active_preset()

func _on_config_changed(_text = ""):
	if presets.has(active_preset_name):
		if api_input: presets[active_preset_name]["api_key"] = api_input.text.strip_edges()
		if url_input: presets[active_preset_name]["base_url"] = url_input.text.strip_edges()
		if model_input: presets[active_preset_name]["model_name"] = model_input.text.strip_edges()
		_save_presets()
		settings_updated.emit()

func _on_custom_prompt_changed():
	if custom_prompt_input:
		var txt = custom_prompt_input.text
		var settings = EditorInterface.get_editor_settings()
		settings.set_setting("gamedev_ai/custom_system_prompt", txt)
		if ai_provider:
			ai_provider.custom_instructions = txt

# ===================== LOCALIZATION =====================

func _populate_language_selector():
	if not language_selector or not locale_manager: return
	language_selector.clear()
	var locales = locale_manager.get_available_locales()
	var current = locale_manager.current_locale
	var select_idx = 0
	for i in range(locales.size()):
		var loc = locales[i]
		language_selector.add_item(loc.name, i)
		if loc.code == current:
			select_idx = i
	language_selector.select(select_idx)

func _on_language_changed(index: int):
	if not locale_manager: return
	var locales = locale_manager.get_available_locales()
	if index >= 0 and index < locales.size():
		locale_manager.set_locale(locales[index].code)
		var settings = EditorInterface.get_editor_settings()
		settings.set_setting("gamedev_ai/language", locales[index].code)
		_apply_locale()
		if ai_provider:
			ai_provider.response_language_instruction = locale_manager.get_ai_language_instruction()

func _apply_locale():
	if not locale_manager: return
	if language_label:
		language_label.text = locale_manager.tr("language")
	for label in _card_titles:
		if is_instance_valid(label) and label.has_meta("tr_key"):
			label.text = locale_manager.tr(label.get_meta("tr_key"))

# ===================== VECTOR DB =====================

func _on_scan_changes_pressed():
	if not _tool_executor or not _tool_executor.vector_db:
		if vector_db_file_list:
			vector_db_file_list.text = "[color=red]Error: VectorDB not initialized.[/color]"
		return
	
	if scan_changes_btn:
		scan_changes_btn.disabled = true
		scan_changes_btn.text = "⏳ Scanning..."
	
	var result = _tool_executor.vector_db.scan_changes()
	var bbcode = ""
	
	for path in result["new_or_modified"]:
		bbcode += "[color=yellow]● NEW/MOD [/color] " + path + "\n"
	for m in result["moved"]:
		bbcode += "[color=dodgerblue]➜ MOVED  [/color] " + m["old"] + " → " + m["new"] + "\n"
	for path in result["deleted"]:
		bbcode += "[color=red]✖ DELETED[/color] " + path + "\n"
	
	var retained_count = result["retained"].size()
	if retained_count > 0:
		bbcode += "[color=green]✔ " + str(retained_count) + " file(s) unchanged (retained)[/color]\n"
	if bbcode == "":
		bbcode = "[color=gray]No script files found in the project.[/color]"
	
	var total = result["retained"].size() + result["moved"].size() + result["new_or_modified"].size() + result["deleted"].size()
	bbcode += "\n[b]Total: " + str(total) + " files[/b] | "
	bbcode += "[color=yellow]" + str(result["new_or_modified"].size()) + " to embed[/color] | "
	bbcode += "[color=dodgerblue]" + str(result["moved"].size()) + " moved[/color] | "
	bbcode += "[color=red]" + str(result["deleted"].size()) + " deleted[/color]"
	
	if vector_db_file_list:
		vector_db_file_list.text = bbcode
	if scan_changes_btn:
		scan_changes_btn.disabled = false
		scan_changes_btn.text = "🔍 Scan Changes"

func _on_index_codebase_pressed():
	if index_confirm_dialog:
		index_confirm_dialog.popup_centered()

func _on_index_confirmed():
	if not _tool_executor or not _tool_executor.vector_db: return
	if index_codebase_btn:
		index_codebase_btn.disabled = true
		index_codebase_btn.text = "⏳ Indexing..."
	if scan_changes_btn:
		scan_changes_btn.disabled = true
	_tool_executor.vector_db.index_project()

func on_vector_db_output(text: String):
	_vdb_messages.append(text)
	if "complete" in text.to_lower():
		var full_msg = "\n".join(_vdb_messages)
		_vdb_messages.clear()
		if index_result_dialog:
			index_result_dialog.dialog_text = full_msg
			index_result_dialog.popup_centered()
		if index_codebase_btn:
			index_codebase_btn.disabled = false
			index_codebase_btn.text = "⚡ Index Codebase"
		if scan_changes_btn:
			scan_changes_btn.disabled = false

# ===================== ENHANCE PROMPT =====================

func _on_enhance_prompt_pressed():
	var raw_text = custom_prompt_input.text.strip_edges()
	if raw_text == "":
		_show_enhance_error("Please write some instructions first before enhancing.")
		return
	
	enhance_prompt_btn.disabled = true
	enhance_prompt_btn.text = "⏳ Enhancing..."
	
	if not _enhance_http:
		_enhance_http = HTTPRequest.new()
		_enhance_http.use_threads = true
		_enhance_http.timeout = 360.0
		_dock_owner.add_child(_enhance_http)
		_enhance_http.request_completed.connect(_on_enhance_request_completed)
	
	var preset = presets.get(active_preset_name, {})
	var provider = preset.get("provider", 0)
	var api_key = preset.get("api_key", "")
	var base_url = preset.get("base_url", "")
	var model = preset.get("model_name", "")
	
	var enhance_prompt = "You are an expert at writing system prompt instructions for AI coding assistants specialized in Godot 4 game development. The user has written the following custom instructions but they may not be well structured or clear enough. Your job is to rewrite and enhance these instructions to be clearer, more specific, and more effective, while preserving the user's original intent. Keep the same language the user wrote in. Output ONLY the enhanced instructions text, no explanations or markdown formatting.\n\nOriginal instructions:\n" + raw_text
	
	var url = ""
	var headers = ["Content-Type: application/json"]
	var body = ""
	
	if provider == 0: # Gemini
		var m = model if model != "" else "gemini-3.1-pro-preview"
		if base_url != "":
			url = base_url
			if not url.ends_with("/"): url += "/"
			url += "v1beta/models/" + m + ":generateContent"
		else:
			url = "https://generativelanguage.googleapis.com/v1beta/models/" + m + ":generateContent?key=" + api_key
		body = JSON.stringify({
			"contents": [{"role": "user", "parts": [{"text": enhance_prompt}]}]
		})
	else: # OpenAI
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
	
	if json and json.has("candidates"):
		var parts = json["candidates"][0].get("content", {}).get("parts", [])
		for part in parts:
			if part.has("text"):
				text += part["text"]
	elif json and json.has("choices"):
		text = json["choices"][0].get("message", {}).get("content", "")
	
	if text.strip_edges() == "":
		_show_enhance_error("AI returned an empty response.")
		_reset_enhance_btn()
		return
	
	_enhanced_text = text.strip_edges()
	if enhance_preview_label:
		enhance_preview_label.text = _enhanced_text
	if enhance_preview_dialog:
		enhance_preview_dialog.popup_centered()
	_reset_enhance_btn()

func _on_enhance_accepted():
	if _enhanced_text != "":
		if custom_prompt_input:
			custom_prompt_input.text = _enhanced_text
		var settings = EditorInterface.get_editor_settings()
		settings.set_setting("gamedev_ai/custom_system_prompt", _enhanced_text)
		if ai_provider:
			ai_provider.custom_instructions = _enhanced_text
		_enhanced_text = ""

func _reset_enhance_btn():
	if enhance_prompt_btn:
		enhance_prompt_btn.disabled = false
		enhance_prompt_btn.text = "✨ Enhance Instructions with AI"

func _show_enhance_error(msg: String):
	if enhance_preview_label:
		enhance_preview_label.text = "[color=red]" + msg + "[/color]"
	if enhance_preview_dialog:
		enhance_preview_dialog.popup_centered()
