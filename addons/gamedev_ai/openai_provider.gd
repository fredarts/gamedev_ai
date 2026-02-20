@tool
extends "res://addons/gamedev_ai/ai_provider.gd"

var base_url: String = "https://api.openai.com/v1"
var model_name: String = "gpt-4o"
var custom_headers: Dictionary = {}
var _cancelled: bool = false

func setup(node: Node):
	super.setup(node)
	
	# Try to load API key from environment variable
	var env = OS.get_environment("OPENAI_API_KEY")
	if env != "":
		api_key = env

func send_prompt(prompt: String, context: String = "", tools: Array = [], image_data: Dictionary = {}):
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
	
	if not image_data.is_empty():
		user_content.append({
			"type": "image_url",
			"image_url": {
				"url": "data:" + image_data["mime_type"] + ";base64," + image_data["data"]
			}
		})

	history.append({"role": "user", "content": user_content})
	transcript.append({"role": "user", "text": prompt})
	
	if current_session_id == "":
		current_session_id = str(Time.get_unix_time_from_system()).replace(".", "_")
	
	_send_request(tools)

func _get_system_instruction() -> String:
	var SysPrompt = preload("res://addons/gamedev_ai/system_prompt.gd")
	return SysPrompt.get_system_instruction()

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
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		is_requesting = false
		error_occurred.emit("Failed to send request: " + str(error))

func _on_request_completed(_result, response_code, _headers, body):
	if _cancelled:
		return
	if response_code != 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		error_occurred.emit("API Error: " + str(response_code) + " - " + str(json))
		is_requesting = false
		return
		
	var json = JSON.parse_string(body.get_string_from_utf8())
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
