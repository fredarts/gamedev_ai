@tool
extends "res://addons/gamedev_ai/ai_provider.gd"

var base_url: String = "https://api.openai.com/v1"
var model_name: String = "gpt-4o"
var custom_headers: Dictionary = {}
var _cancelled: bool = false
var _last_tools: Array = []

func setup(node: Node):
	super.setup(node)
	
	# Try to load API key from environment variable
	var env = OS.get_environment("OPENAI_API_KEY")
	if env != "":
		api_key = env

func send_prompt(prompt: String, context: String = "", tools: Array = [], files: Array = []):
	var is_local = ("localhost" in base_url or "127.0.0.1" in base_url or "11434" in base_url)
	if api_key == "" and not is_local:
		error_occurred.emit("API Key is missing.")
		return

	if history.is_empty():
		var system_text = _get_system_instruction()
		if context != "":
			system_text += "\n\nContext:\n" + context
		history.append({"role": "system", "content": system_text})
	
	var user_content = []
	user_content.append({"type": "text", "text": prompt})
	
	for file_data in files:
		if not file_data.is_empty():
			if file_data.get("mime_type", "").begins_with("image/"):
				user_content.append({
					"type": "image_url",
					"image_url": {
						"url": "data:" + file_data["mime_type"] + ";base64," + file_data["data"]
					}
				})
			else:
				print("Warning: OpenAI provider currently ignores non-image attachments like ", file_data.get("mime_type", ""))

	history.append({"role": "user", "content": user_content})
	transcript.append({"role": "user", "text": prompt})
	
	if current_session_id == "":
		current_session_id = str(Time.get_unix_time_from_system()).replace(".", "_")
	
	_send_request(tools)

func _get_system_instruction() -> String:
	var SysPrompt = preload("res://addons/gamedev_ai/system_prompt.gd")
	var info = Engine.get_version_info()
	var version_str = "Godot Engine " + str(info.major) + "." + str(info.minor) + "." + str(info.patch)
	var status = info.get("status", "")
	if status != "":
		version_str += " (" + status + ")"
	return SysPrompt.get_system_instruction(version_str, custom_instructions, response_language_instruction, transcript, screenshot_enabled)

func generate_tool_response(_tool_name: String, output: String, tool_call_id: String = "") -> Dictionary:
	return {
		"role": "tool",
		"tool_call_id": tool_call_id,
		"content": output
	}

func send_tool_responses(responses: Array, tools: Array = [], files: Array = []):
	for resp in responses:
		history.append(resp)
	
	if not files.is_empty():
		var user_content = []
		user_content.append({"type": "text", "text": "Here is the captured screenshot/file from the tool."})
		for file_data in files:
			if not file_data.is_empty() and file_data.get("mime_type", "").begins_with("image/"):
				user_content.append({
					"type": "image_url",
					"image_url": {
						"url": "data:" + file_data["mime_type"] + ";base64," + file_data["data"]
					}
				})
		if user_content.size() > 1:
			history.append({"role": "user", "content": user_content})
			transcript.append({"role": "user", "text": "[System auto-attached file directly after tool response]"})

	_send_request(tools)

func cancel_request():
	_cancelled = true
	super.cancel_request()

func _send_request(tools: Array = []):
	_cancelled = false
	_last_tools = tools
	var url = base_url + "/chat/completions"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	# Add OpenRouter specific headers if needed
	for key in custom_headers:
		headers.append(key + ": " + custom_headers[key])
	
	# Dynamically update the system instruction before sending
	if not history.is_empty() and history[0].get("role") == "system":
		history[0]["content"] = _get_system_instruction()
		
		# Fallback: Inject tools directly into the system prompt for local models without native API wrapping
		if ("localhost" in base_url or "127.0.0.1" in base_url or "11434" in base_url) and not tools.is_empty():
			var tools_text = "## SYSTEM CRITICAL OVERRIDE: YOU ARE AN AUTONOMOUS AGENT\n"
			tools_text += "You are executing in an environment that requires you to use JSON tool calls to interact with files. NEVER ask the user to run commands like 'find' or 'ls'. YOU must do it. To use a tool, you MUST output a raw JSON block:\n```json\n{\"name\": \"function_name\", \"parameters\": {\"arg\": \"val\"}}\n```\n"
			tools_text += "AVAILABLE TOOLS:\n"
			for t in tools:
				tools_text += "- **" + t.get("name", "") + "**: Schema: " + JSON.stringify(t.get("parameters", {})) + "\n"
			history[0]["content"] = tools_text + "\n==== END OF TOOLS ====\n\n" + history[0]["content"]
			
	var body = {
		"model": model_name,
		"messages": history
	}
	
	if not tools.is_empty():
		var openai_tools = []
		for t in tools:
			var params = t.get("parameters", { "type": "object", "properties": {} })
			# Duplicate to avoid modifying the original array from tool_executor
			params = params.duplicate(true)
			_fix_schema_types(params)
			
			openai_tools.append({
				"type": "function",
				"function": {
					"name": t.get("name", ""),
					"description": t.get("description", ""),
					"parameters": params
				}
			})
		body["tools"] = openai_tools
	
	is_requesting = true
	_start_timeout()
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		_stop_timeout()
		is_requesting = false
		error_occurred.emit("Failed to send request: " + str(error))

func _fix_schema_types(schema: Dictionary):
	if schema.has("type") and typeof(schema["type"]) == TYPE_STRING:
		schema["type"] = schema["type"].to_lower()
		
	if schema.has("properties") and typeof(schema["properties"]) == TYPE_DICTIONARY:
		for key in schema["properties"]:
			var prop = schema["properties"][key]
			if typeof(prop) == TYPE_DICTIONARY:
				_fix_schema_types(prop)
				
	if schema.has("items") and typeof(schema["items"]) == TYPE_DICTIONARY:
		_fix_schema_types(schema["items"])

func _on_request_completed(_result, response_code, _headers, body):
	_stop_timeout()
	if _cancelled:
		return
	if response_code != 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		# Retry on transient errors (429 rate limit, 5xx server errors)
		if (response_code == 429 or response_code >= 500) and _retry_count < MAX_RETRIES:
			_retry_count += 1
			var wait_secs = pow(2, _retry_count)
			error_occurred.emit("⚠️ Transient error (" + str(response_code) + "). Retrying in " + str(int(wait_secs)) + "s... (" + str(_retry_count) + "/" + str(MAX_RETRIES) + ")")
			await http_request.get_tree().create_timer(wait_secs).timeout
			_send_request(_last_tools)
			return
		_retry_count = 0
		error_occurred.emit("API Error: " + str(response_code) + " - " + str(json))
		is_requesting = false
		return
		
	_retry_count = 0
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	# Extract token usage metadata
	if json and json.has("usage"):
		var usage = json["usage"]
		token_usage_reported.emit({
			"prompt_tokens": usage.get("prompt_tokens", 0),
			"completion_tokens": usage.get("completion_tokens", 0),
			"total_tokens": usage.get("total_tokens", 0)
		})
	
	if json and json.has("choices"):
		var choice = json["choices"][0]
		var message = choice.get("message", {})
		
		# Sanitize Ollama specific non-standard injected fields before saving to history
		if message.has("tool_calls"):
			for tc in message["tool_calls"]:
				if tc.has("index"):
					tc.erase("index")
					
		history.append(message)
		
		if message.has("tool_calls"):
			var tool_calls = []
			for tc in message["tool_calls"]:
				var function = tc.get("function", {})
				tool_calls.append({
					"name": function.get("name", ""),
					"args": JSON.parse_string(function.get("arguments", "{}")),
					"id": tc.get("id", "")
				})
			tool_call_received.emit(tool_calls)
			return
		
		var text = message.get("content", "")
		if typeof(text) != TYPE_STRING:
			text = ""
			
		# --- Fallback to parse manual tool calls hidden in content (Ollama, Gemma 4) ---
		if text != "" and not message.has("tool_calls"):
			var potential_json = ""
			if "<tool_call>" in text:
				var t_start = text.find("<tool_call>") + 11
				var t_end = text.find("</tool_call>", t_start)
				if t_end != -1: potential_json = text.substr(t_start, t_end - t_start).strip_edges()
			elif "<|tool_call|>" in text:
				var t_start = text.find("<|tool_call|>") + 14
				potential_json = text.substr(t_start).strip_edges()
			elif "```json" in text and '"name"' in text and '"parameters"' in text:
				var t_start = text.find("```json") + 7
				var t_end = text.find("```", t_start)
				if t_end != -1: potential_json = text.substr(t_start, t_end - t_start).strip_edges()
			elif text.strip_edges().begins_with('{"name"'):
				potential_json = text.strip_edges()

			if potential_json != "":
				var parsed = JSON.parse_string(potential_json)
				if parsed and parsed is Dictionary and parsed.has("name") and parsed.has("parameters"):
					var params = parsed.get("parameters", {})
					if typeof(params) == TYPE_STRING:
						params = JSON.parse_string(params)
					var tool_calls = [{
						"name": parsed["name"],
						"args": params if typeof(params) == TYPE_DICTIONARY else {},
						"id": "manual_call_" + str(Time.get_ticks_msec())
					}]
					tool_call_received.emit(tool_calls)
					return
		# -------------------------------------------------------------------------------
			
		if text != "":
			is_requesting = false
			transcript.append({"role": "assistant", "text": text})
			save_session()
			response_received.emit(text)
		else:
			if _retry_count < MAX_RETRIES:
				_retry_count += 1
				var wait_secs = 2.0
				error_occurred.emit("⚠️ Empty response from model. Emitting continue prompt... (" + str(_retry_count) + "/" + str(MAX_RETRIES) + ")")
				
				# Record the empty model turn
				history.append({"role": "assistant", "content": " "})
				
				# Add continue prompt
				var continue_msg = "Your last response was empty. Please reiterate your plan and try to continue what you were doing."
				transcript.append({"role": "user", "text": continue_msg})
				history.append({"role": "user", "content": continue_msg})
				
				await http_request.get_tree().create_timer(wait_secs).timeout
				
				if not _cancelled:
					_send_request(_last_tools)
				return
			else:
				_retry_count = 0
				is_requesting = false
				error_occurred.emit("Empty response from model.")
	else:
		is_requesting = false
		error_occurred.emit("Invalid response format.")
