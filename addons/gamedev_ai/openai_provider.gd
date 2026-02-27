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

func send_prompt(prompt: String, context: String = "", tools: Array = [], images: Array = []):
	if api_key == "":
		error_occurred.emit("API Key is missing.")
		return

	if history.is_empty():
		var system_text = _get_system_instruction()
		if context != "":
			system_text += "\n\nContext:\n" + context
		history.append({"role": "system", "content": system_text})
	
	var user_content = []
	user_content.append({"type": "text", "text": prompt})
	
	for img_data in images:
		if not img_data.is_empty():
			user_content.append({
				"type": "image_url",
				"image_url": {
					"url": "data:" + img_data["mime_type"] + ";base64," + img_data["data"]
				}
			})

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
	return SysPrompt.get_system_instruction(version_str, custom_instructions)

func generate_tool_response(_tool_name: String, output: String, tool_call_id: String = "") -> Dictionary:
	return {
		"role": "tool",
		"tool_call_id": tool_call_id,
		"content": output
	}

func send_tool_responses(responses: Array, tools: Array = []):
	for resp in responses:
		history.append(resp)
	
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
	
	var body = {
		"model": model_name,
		"messages": history
	}
	
	if not tools.is_empty():
		var openai_tools = []
		for t in tools:
			openai_tools.append({
				"type": "function",
				"function": {
					"name": t["name"],
					"description": t["description"],
					"parameters": t["parameters"]
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
		if text != "":
			is_requesting = false
			transcript.append({"role": "assistant", "text": text})
			save_session()
			response_received.emit(text)
		else:
			is_requesting = false
			error_occurred.emit("Empty response from model.")
	else:
		is_requesting = false
		error_occurred.emit("Invalid response format.")
