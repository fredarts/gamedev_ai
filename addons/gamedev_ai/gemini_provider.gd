@tool
extends "res://addons/gamedev_ai/ai_provider.gd"

var model_name: String = "gemini-3.1-pro-preview"
var _cancelled: bool = false
var _last_tools: Array = []
var base_url: String = ""

var tts_http_request: HTTPRequest
var _tts_thread: Thread

func setup(node: Node):
	super.setup(node)
	
	tts_http_request = HTTPRequest.new()
	tts_http_request.use_threads = true
	node.add_child(tts_http_request)
	tts_http_request.request_completed.connect(_on_tts_request_completed)
	
	# Try to load API key from environment variable
	var env = OS.get_environment("GEMINI_API_KEY")
	if env != "":
		api_key = env

func cleanup():
	if _tts_thread and _tts_thread.is_started():
		_tts_thread.wait_to_finish()
	if tts_http_request and is_instance_valid(tts_http_request):
		tts_http_request.queue_free()
	super.cleanup()

func request_tts(text: String):
	if api_key == "" and base_url == "":
		error_occurred.emit("API Key is missing for TTS.")
		return
		
	var tts_model = "gemini-2.5-flash-preview-tts"
	var url = "https://generativelanguage.googleapis.com/v1beta/models/" + tts_model + ":generateContent?key=" + api_key
	if base_url != "":
		url = base_url
		if not url.ends_with("/"):
			url += "/"
		url += "v1beta/models/" + tts_model + ":generateContent"
		if not url.begins_with("http://127.0.0.1") and not url.begins_with("http://localhost") and api_key != "":
			url += "?key=" + api_key
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
	if api_key == "" and base_url == "":
		error_occurred.emit("API Key is missing.")
		return

	var parts = []
	if history.is_empty() and context != "":
		parts.append({"text": context})
	parts.append({"text": prompt})
	
	for file_data in files:
		if not file_data.is_empty():
			parts.append({
				"inlineData": {
					"mimeType": file_data.get("mime_type", "image/png"),
					"data": file_data.get("data", "")
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

func _is_func_call_msg(msg: Dictionary) -> bool:
	if msg.get("role") != "model":
		return false
	for p in msg.get("parts", []):
		if p is Dictionary and p.has("functionCall"):
			return true
	return false

func _is_func_resp_msg(msg: Dictionary) -> bool:
	for p in msg.get("parts", []):
		if p is Dictionary and p.has("functionResponse"):
			return true
	return false

func _append_to_history(content: Dictionary):
	if not history.is_empty():
		var last = history[-1]
		if last.get("role") == content.get("role"):
			var last_has_func = _is_func_call_msg(last) or _is_func_resp_msg(last)
			var content_has_func = _is_func_call_msg(content) or _is_func_resp_msg(content)
					
			# Only merge identical text turns if neither contains function calls/responses
			if not last_has_func and not content_has_func:
				if content.get("role") == "user":
					last["parts"].append_array(content["parts"])
					prune_history()
					return
				elif content.get("role") == "model":
					history[-1] = content
					prune_history()
					return
	
	history.append(content)
	prune_history()

func send_tool_responses(responses: Array, tools: Array = [], files: Array = []):
	var parts = []
	for resp in responses:
		parts.append(resp)
		
	for file_data in files:
		if not file_data.is_empty():
			parts.append({
				"inlineData": {
					"mimeType": file_data.get("mime_type", "image/png"),
					"data": file_data.get("data", "")
				}
			})
			
	var response_content = {
		"role": "user",
		"parts": parts
	}
	
	if history.is_empty():
		error_occurred.emit("Cannot send tool response: history is empty")
		return

	_append_to_history(response_content)
	_send_request(tools)

func generate_tool_response(tool_name: String, output: String, tool_call_id: String = "") -> Dictionary:
	var func_resp: Dictionary = {
		"name": tool_name,
		"response": {
			"result": output
		}
	}
	if tool_call_id != "" and tool_call_id != null:
		func_resp["id"] = str(tool_call_id)
	return {
		"functionResponse": func_resp
	}

func cancel_request():
	_cancelled = true
	super.cancel_request()

func _get_last_user_prompt_from_transcript() -> String:
	for idx in range(transcript.size() - 1, -1, -1):
		var entry = transcript[idx]
		if entry is Dictionary and entry.get("role") == "user" and str(entry.get("text", "")).strip_edges() != "":
			return str(entry.get("text"))
	return "Continue"

func _sanitize_gemini_history():
	if history.is_empty():
		var prompt_text = _get_last_user_prompt_from_transcript()
		history.append({
			"role": "user",
			"parts": [{"text": prompt_text}]
		})
		return
		
	# 1. Normalize all roles and filter out invalid non-dictionary turns
	var raw: Array = []
	for item in history:
		if not (item is Dictionary):
			continue
		var copy = item.duplicate(true)
		var role = copy.get("role", "")
		if role == "assistant":
			copy["role"] = "model"
		elif role in ["function", "tool"] or _is_func_resp_msg(copy):
			copy["role"] = "user"
		elif role == "system":
			# Gemini uses systemInstruction at top level, skip system messages from contents
			continue
		elif role == "" or role == null:
			copy["role"] = "model" if _is_func_call_msg(copy) else "user"
			
		if copy.has("parts") and not copy["parts"].is_empty():
			var clean_parts: Array = []
			for p in copy["parts"]:
				if not (p is Dictionary):
					continue
				if p.has("functionCall") and p["functionCall"] is Dictionary:
					var fc = p["functionCall"]
					var clean_fc: Dictionary = {
						"name": fc.get("name", ""),
						"args": fc.get("args", {})
					}
					var fc_id = fc.get("id", p.get("id", ""))
					if fc_id != "" and fc_id != null:
						clean_fc["id"] = str(fc_id)
					var clean_p: Dictionary = {
						"functionCall": clean_fc
					}
					var sig = p.get("thoughtSignature", p.get("thought_signature", ""))
					if sig == "" or sig == null:
						sig = "skip_thought_signature_validator"
					clean_p["thoughtSignature"] = str(sig)
					clean_parts.append(clean_p)
				elif p.has("functionResponse") and p["functionResponse"] is Dictionary:
					var fr = p["functionResponse"]
					var clean_fr: Dictionary = {
						"name": fr.get("name", ""),
						"response": fr.get("response", {})
					}
					var fr_id = fr.get("id", p.get("id", ""))
					if fr_id != "" and fr_id != null:
						clean_fr["id"] = str(fr_id)
					clean_parts.append({
						"functionResponse": clean_fr
					})
				elif p.has("text"):
					clean_parts.append({
						"text": str(p["text"])
					})
				elif p.has("inlineData") and p["inlineData"] is Dictionary:
					clean_parts.append({
						"inlineData": p["inlineData"]
					})
				elif p.has("fileData") and p["fileData"] is Dictionary:
					clean_parts.append({
						"fileData": p["fileData"]
					})
			
			if not clean_parts.is_empty():
				copy["parts"] = clean_parts
				raw.append(copy)
		
	# 2. Reconstruct clean, strictly valid turn sequence
	var validated: Array = []
	var i = 0
	while i < raw.size():
		var msg = raw[i]
		
		if _is_func_call_msg(msg):
			# A function call turn MUST be preceded by a user turn (or previous function response turn)
			if validated.is_empty() or validated[-1].get("role") != "user":
				var prompt_text = _get_last_user_prompt_from_transcript()
				validated.append({
					"role": "user",
					"parts": [{"text": prompt_text}]
				})
				
			# Check if followed by function response
			if i + 1 < raw.size() and _is_func_resp_msg(raw[i + 1]):
				validated.append(msg)
				validated.append(raw[i + 1])
				i += 2
				continue
			else:
				# Unanswered function call at end: drop to prevent schema error
				i += 1
				continue
		elif _is_func_resp_msg(msg):
			# An orphan function response cannot appear without a preceding function call turn!
			if not validated.is_empty() and _is_func_call_msg(validated[-1]):
				validated.append(msg)
			i += 1
			continue
		else:
			# Normal user or model message
			if not validated.is_empty():
				var prev = validated[-1]
				var prev_role = prev.get("role", "")
				var curr_role = msg.get("role", "")
				# Only merge consecutive turns of the same role if neither is involved in tool calling
				if prev_role == curr_role and not _is_func_call_msg(prev) and not _is_func_resp_msg(prev):
					var prev_parts = prev.get("parts", [])
					var curr_parts = msg.get("parts", [])
					prev_parts.append_array(curr_parts)
					prev["parts"] = prev_parts
					i += 1
					continue
			validated.append(msg)
			i += 1
			
	# 3. Ensure history starts with a real user prompt (NOT a function response, and NOT a model turn)
	while not validated.is_empty():
		var first = validated[0]
		if first.get("role") != "user" or _is_func_resp_msg(first):
			validated.remove_at(0)
		else:
			break
			
	# If validated became empty or lacks a user prompt at the front, guarantee a valid user prompt
	if validated.is_empty():
		var prompt_text = _get_last_user_prompt_from_transcript()
		validated.append({
			"role": "user",
			"parts": [{"text": prompt_text}]
		})
	elif validated[0].get("role") != "user" or _is_func_resp_msg(validated[0]):
		var prompt_text = _get_last_user_prompt_from_transcript()
		validated.push_front({
			"role": "user",
			"parts": [{"text": prompt_text}]
		})
		
	history = validated

func _send_request(tools: Array = []):
	_last_tools = tools
	_sanitize_gemini_history()
	
	if history.is_empty():
		var prompt_text = _get_last_user_prompt_from_transcript()
		history.append({
			"role": "user",
			"parts": [{"text": prompt_text}]
		})
	
	var clean_model = model_name.strip_edges()
	if clean_model.begins_with("models/"):
		clean_model = clean_model.substr(7)
	if clean_model == "":
		clean_model = "gemini-3.1-pro-preview"
	var url = "https://generativelanguage.googleapis.com/v1beta/models/" + clean_model + ":generateContent?key=" + api_key
	if base_url != "":
		url = base_url
		if not url.ends_with("/"):
			url += "/"
		url += "v1beta/models/" + clean_model + ":generateContent"
		if not url.begins_with("http://127.0.0.1") and not url.begins_with("http://localhost") and api_key != "":
			url += "?key=" + api_key
	var headers = ["Content-Type: application/json"]

	var body = {
		"contents": history
	}
	
	if history.is_empty():
		history.append({
			"role": "user",
			"parts": [{"text": "Continue"}]
		})
		body["contents"] = history
	
	_inject_full_system_instruction(body)

	if not tools.is_empty():
		body["tools"] = [{"functionDeclarations": tools}]
	
	is_requesting = true
	_start_timeout()
	print_rich("[color=cyan]🤖 Gamedev AI: Sending request to Gemini (model: [b]" + clean_model + "[/b], history turns: " + str(history.size()) + ")[/color]")
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		_stop_timeout()
		is_requesting = false
		var err_str = "Failed to send HTTP request (code: " + str(error) + ")"
		print_rich("[color=red]❌ Gamedev AI: " + err_str + "[/color]")
		error_occurred.emit(err_str)


func _inject_full_system_instruction(body: Dictionary):
	var SysPrompt = preload("res://addons/gamedev_ai/system_prompt.gd")
	var info = Engine.get_version_info()
	var version_str = "Godot Engine " + str(info.major) + "." + str(info.minor) + "." + str(info.patch)
	var status = info.get("status", "")
	if status != "":
		version_str += " (" + status + ")"
	body["systemInstruction"] = {
		"parts": [
			{ "text": SysPrompt.get_system_instruction(version_str, custom_instructions, response_language_instruction, transcript, screenshot_enabled) }
		]
	}

func _on_request_completed(_result, response_code, _headers, body):
	_stop_timeout()
	if _cancelled:
		return
	if response_code != 200:
		is_requesting = false
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		# Rollback failed function response turn to prevent corrupting next user turns
		if not history.is_empty() and _is_func_resp_msg(history[-1]):
			history.pop_back()
			if not history.is_empty() and _is_func_call_msg(history[-1]):
				history.pop_back()
		
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
		print_rich("[color=red]❌ Gamedev AI Gemini API Error (" + str(response_code) + "): " + str(error_msg) + "[/color]")
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

		var parts = content.get("parts", [])
		var text = ""
		var tool_calls = []
		var func_call_parts = []
		
		# Find if candidate or any part has a thoughtSignature
		var global_signature = ""
		for p in parts:
			if p is Dictionary:
				if p.has("thoughtSignature") and str(p["thoughtSignature"]) != "":
					global_signature = str(p["thoughtSignature"])
					break
				elif p.has("thought_signature") and str(p["thought_signature"]) != "":
					global_signature = str(p["thought_signature"])
					break
		if global_signature == "":
			global_signature = "skip_thought_signature_validator"
			
		for part in parts:
			if part.has("text"):
				text += part["text"]
			if part.has("functionCall"):
				var call = part["functionCall"].duplicate(true)
				var call_id = ""
				if call.has("id"):
					call_id = str(call["id"])
				elif part.has("id"):
					call_id = str(part["id"])
					call["id"] = call_id
				elif call.has("call_id"):
					call_id = str(call["call_id"])
					call["id"] = call_id
				tool_calls.append(call)
				
				var clean_fc: Dictionary = {
					"name": call.get("name", ""),
					"args": call.get("args", {})
				}
				if call_id != "":
					clean_fc["id"] = call_id
					
				var clean_part: Dictionary = {
					"functionCall": clean_fc
				}
				var sig = part.get("thoughtSignature", part.get("thought_signature", global_signature))
				if sig == "" or sig == null:
					sig = "skip_thought_signature_validator"
				clean_part["thoughtSignature"] = str(sig)
				func_call_parts.append(clean_part)
				
		if not tool_calls.is_empty():
			_append_to_history({
				"role": "model",
				"parts": func_call_parts
			})
			tool_call_received.emit(tool_calls)
			return

		_append_to_history(content)
		
		if text != "":
			is_requesting = false
			transcript.append({"role": "model", "text": text})
			save_session()
			response_received.emit(text)
		else:
			if _retry_count < MAX_RETRIES:
				_retry_count += 1
				var wait_secs = 2.0
				error_occurred.emit("⚠️ Empty response from model. Emitting continue prompt... (" + str(_retry_count) + "/" + str(MAX_RETRIES) + ")")
				
				# Record the empty model turn
				_append_to_history({
					"role": "model",
					"parts": [{"text": " "}]
				})
				
				# Add continue prompt
				var continue_msg = "Your last response was empty. Please reiterate your plan and try to continue what you were doing."
				transcript.append({"role": "user", "text": continue_msg})
				_append_to_history({
					"role": "user",
					"parts": [{"text": continue_msg}]
				})
				
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

func _format_api_error(code: int, json: Variant) -> String:
	if json == null or not (json is Dictionary):
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
