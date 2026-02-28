@tool
extends "res://addons/gamedev_ai/ai_provider.gd"

var model_name: String = "gemini-1.5-pro"
var _cancelled: bool = false
var _last_tools: Array = []

var tts_http_request: HTTPRequest
var _tts_thread: Thread

func setup(node: Node):
	super.setup(node)
	
	tts_http_request = HTTPRequest.new()
	node.add_child(tts_http_request)
	tts_http_request.request_completed.connect(_on_tts_request_completed)
	tts_http_request.use_threads = true
	
	# Try to load API key from environment variable
	var env = OS.get_environment("GEMINI_API_KEY")
	if env != "":
		api_key = env

func request_tts(text: String):
	if api_key == "":
		error_occurred.emit("API Key is missing for TTS.")
		return
		
	var tts_model = "gemini-2.5-flash-preview-tts"
	var url = "https://generativelanguage.googleapis.com/v1beta/models/" + tts_model + ":generateContent?key=" + api_key
	var headers = ["Content-Type: application/json"]
	
	var body = {
		"contents": [{"role": "user", "parts": [{"text": "Read aloud the following text naturally:\n" + text}]}],
		"generationConfig": {
			"responseModalities": ["AUDIO"],
			"speechConfig": {
				"voiceConfig": {
					"prebuiltVoiceConfig": {
						"voiceName": "Kore"
					}
				}
			}
		}
	}
	
	print("Sending TTS HTTP Request (model: ", tts_model, "). Text length: ", text.length())
	var error = tts_http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		error_occurred.emit("Failed to send TTS request: " + str(error))

func _on_tts_request_completed(_result, response_code, _headers, body):
	print("TTS HTTP Request completed. Code: ", response_code)
	if response_code != 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		print("TTS API Error payload: ", json)
		error_occurred.emit("TTS API Error (" + str(response_code) + "): " + str(json))
		return
		
	var payload = body.get_string_from_utf8()
	
	if _tts_thread and _tts_thread.is_started():
		_tts_thread.wait_to_finish()
		
	_tts_thread = Thread.new()
	_tts_thread.start(_process_tts_payload.bind(payload))

func _process_tts_payload(payload: String):
	var json = JSON.parse_string(payload)
	print("TTS JSON Response Parsed in Background")
	
	if json and json.has("candidates"):
		var candidate = json["candidates"][0]
		var content = candidate.get("content", {})
		var parts = content.get("parts", [])
		
		for part in parts:
			if part.has("inlineData"):
				var inline_data = part["inlineData"]
				if inline_data.has("data"):
					var base64_audio = inline_data["data"]
					var raw_data = Marshalls.base64_to_raw(base64_audio)
					call_deferred("emit_signal", "audio_received", raw_data)
					return
	
	call_deferred("emit_signal", "error_occurred", "Failed to parse TTS response data.")

func send_prompt(prompt: String, context: String = "", tools: Array = [], files: Array = []):
	if api_key == "":
		error_occurred.emit("API Key is missing.")
		return

	var parts = []
	if history.is_empty() and context != "":
		parts.append({"text": context})
	parts.append({"text": prompt})
	
	for file_data in files:
		if not file_data.is_empty():
			parts.append({
				"inline_data": {
					"mime_type": file_data["mime_type"],
					"data": file_data["data"]
				}
			})

	var user_content = {
		"role": "user",
		"parts": parts
	}
	
	transcript.append({"role": "user", "text": prompt})
	if current_session_id == "":
		current_session_id = str(Time.get_unix_time_from_system()).replace(".", "_")
	
	_append_to_history(user_content)
	_send_request(tools)

func _append_to_history(content: Dictionary):
	if not history.is_empty():
		var last = history[-1]
		if last.get("role") == content.get("role"):
			if content.get("role") == "user":
				last["parts"].append_array(content["parts"])
				return
			else:
				history[-1] = content
				return
	
	history.append(content)
	while history.size() > MAX_HISTORY_TURNS:
		history.remove_at(0)
	while not history.is_empty() and history[0].get("role") != "user":
		history.remove_at(0)

func send_tool_responses(responses: Array, tools: Array = []):
	var parts = []
	for resp in responses:
		parts.append(resp)
		
	var response_content = {
		"role": "function",
		"parts": parts
	}
	
	_append_to_history(response_content)
	_send_request(tools)

func generate_tool_response(tool_name: String, output: String, _tool_call_id: String = "") -> Dictionary:
	return {
		"functionResponse": {
			"name": tool_name,
			"response": {
				"output": output
			}
		}
	}

func cancel_request():
	_cancelled = true
	super.cancel_request()

func _send_request(tools: Array = []):
	_cancelled = false
	_last_tools = tools
	var url = "https://generativelanguage.googleapis.com/v1beta/models/" + model_name + ":generateContent?key=" + api_key
	var headers = ["Content-Type: application/json"]
	
	var body = {
		"contents": history
	}
	
	_inject_full_system_instruction(body)

	if not tools.is_empty():
		body["tools"] = [{"function_declarations": tools}]
	
	is_requesting = true
	_start_timeout()
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		_stop_timeout()
		is_requesting = false
		error_occurred.emit("Failed to send request: " + str(error))

func _inject_full_system_instruction(body: Dictionary):
	var SysPrompt = preload("res://addons/gamedev_ai/system_prompt.gd")
	var info = Engine.get_version_info()
	var version_str = "Godot Engine " + str(info.major) + "." + str(info.minor) + "." + str(info.patch)
	var status = info.get("status", "")
	if status != "":
		version_str += " (" + status + ")"
	body["system_instruction"] = {
		"parts": {
			"text": SysPrompt.get_system_instruction(version_str, custom_instructions)
		}
	}

func _on_request_completed(_result, response_code, _headers, body):
	_stop_timeout()
	if _cancelled:
		return
	if response_code != 200:
		is_requesting = false
		var json = JSON.parse_string(body.get_string_from_utf8())
		# Retry on transient errors (429 rate limit, 5xx server errors)
		if (response_code == 429 or response_code >= 500) and _retry_count < MAX_RETRIES:
			_retry_count += 1
			var wait_secs = pow(2, _retry_count) # Exponential backoff: 2s, 4s
			error_occurred.emit("⚠️ Transient error (" + str(response_code) + "). Retrying in " + str(int(wait_secs)) + "s... (" + str(_retry_count) + "/" + str(MAX_RETRIES) + ")")
			await http_request.get_tree().create_timer(wait_secs).timeout
			_send_request(_last_tools)
			return
		_retry_count = 0
		var error_msg = _format_api_error(response_code, json)
		error_occurred.emit(error_msg)
		return
	
	_retry_count = 0
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	# Extract token usage metadata
	if json and json.has("usageMetadata"):
		var usage = json["usageMetadata"]
		token_usage_reported.emit({
			"prompt_tokens": usage.get("promptTokenCount", 0),
			"completion_tokens": usage.get("candidatesTokenCount", 0),
			"total_tokens": usage.get("totalTokenCount", 0)
		})
	
	if json and json.has("candidates"):
		var candidate = json["candidates"][0]
		var content = candidate.get("content", {})
		
		if not content.has("parts") or content["parts"].is_empty():
			is_requesting = false
			var finish_reason = candidate.get("finishReason", "UNKNOWN")
			error_occurred.emit("Model failed to respond. Reason: " + finish_reason)
			return

		_append_to_history(content)
		
		var parts = content.get("parts", [])
		var text = ""
		var tool_calls = []
		
		for part in parts:
			if part.has("text"):
				text += part["text"]
			if part.has("functionCall"):
				tool_calls.append(part["functionCall"])
				
		if not tool_calls.is_empty():
			tool_call_received.emit(tool_calls)
			return
		
		if text != "":
			is_requesting = false
			transcript.append({"role": "model", "text": text})
			save_session()
			response_received.emit(text)
		else:
			is_requesting = false
			error_occurred.emit("Empty response from model.")
	else:
		is_requesting = false
		error_occurred.emit("Invalid response format.")

func _format_api_error(code: int, json: Dictionary) -> String:
	if json == null:
		return "API Error: " + str(code) + " (Unknown response)"

	var error_node = json.get("error", {})
	var message = error_node.get("message", "Unknown error")
	var status = error_node.get("status", "")
	
	if code == 429 or status == "RESOURCE_EXHAUSTED":
		return "⚠️ Quota Exceeded\n\nYou have reached the free tier limit for the Gemini API.\nPlease check your billing details or wait a few minutes before trying again."
	
	if code == 400:
		if "API key not valid" in message:
			return "⚠️ Invalid API Key\n\nPlease check your API key in Editor Settings > Gamedev AI."
		return "⚠️ Bad Request (" + str(code) + ")\n\n" + message
	
	if code == 401 or code == 403:
		return "⚠️ Authorization Error (" + str(code) + ")\n\nPlease check your API key permissions."
		
	return "API Error (" + str(code) + ")\n\n" + message
