@tool
extends RefCounted

signal response_received(response)
signal error_occurred(error_msg)
signal tool_call_received(tool_calls)
signal status_changed(is_requesting)

var api_key: String = ""
var http_request: HTTPRequest
var history: Array = [] # Stores the conversation history (Technical Gemini format)
var transcript: Array = [] # Stores user-friendly text for UI display
var is_requesting: bool = false : set = _set_is_requesting
var current_session_id: String = ""
const MAX_HISTORY_TURNS = 100 
const HISTORY_DIR = "res://.gamedev_ai/history/"

func _init():
	pass

func setup(node: Node):
	# Create HTTPRequest node and add it to the scene tree
	http_request = HTTPRequest.new()
	node.add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Fix for API Error 0 (SSL/TLS issues)
	# In production, use proper certificates. For this dev tool, we can be more lenient or ensure we rely on system.
	# Godot 4 sometimes needs this for HTTPS to work reliably on Windows/Editor
	http_request.use_threads = true 
	# http_request.set_tls_options(TLSOptions.client_unsafe()) # Uncomment if still failing
	
	# Try to load API key from environment variable or extensive config
	var env = OS.get_environment("GEMINI_API_KEY")
	if env != "":
		api_key = env
	else:
		# Key might be set in Editor Settings later, so just print a friendly message or check EditorSettings if possible.
		# specific checker for editor settings creates dependency, so we just soften the warning.
		print("GEMINI_API_KEY not found in environment. Please ensure it is set in Editor Settings > Gamedev AI.")

func set_api_key(key: String):
	api_key = key

func clear_history():
	history.clear()
	transcript.clear()
	current_session_id = ""
	is_requesting = false

func new_session():
	clear_history()
	current_session_id = str(Time.get_unix_time_from_system()).replace(".", "_")
	save_session()

func _ensure_history_dir():
	if not DirAccess.dir_exists_absolute(HISTORY_DIR):
		DirAccess.make_dir_recursive_absolute(HISTORY_DIR)

func save_session():
	if current_session_id == "": return
	_ensure_history_dir()
	
	var data = {
		"id": current_session_id,
		"history": history,
		"transcript": transcript,
		"last_modified": Time.get_datetime_dict_from_system()
	}
	
	var file = FileAccess.open(HISTORY_DIR + current_session_id + ".json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_session(session_id: String) -> bool:
	var path = HISTORY_DIR + session_id + ".json"
	if not FileAccess.file_exists(path): return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data:
		history = data.get("history", [])
		transcript = data.get("transcript", [])
		current_session_id = data.get("id", session_id)
		return true
	return false

func list_sessions() -> Array:
	_ensure_history_dir()
	var sessions = []
	var dir = DirAccess.open(HISTORY_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var session_data = _read_session_metadata(HISTORY_DIR + file_name)
				if not session_data.is_empty():
					sessions.append(session_data)
			file_name = dir.get_next()
	
	# Sort by last modified descending
	sessions.sort_custom(func(a, b): return _datetime_to_unix(a.last_modified) > _datetime_to_unix(b.last_modified))
	return sessions

func _read_session_metadata(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	if data:
		var title = "New Chat"
		var t = data.get("transcript", [])
		if not t.is_empty():
			title = t[0].get("text", "New Chat").left(40).strip_edges() + "..."
		
		return {
			"id": data.get("id"),
			"title": title,
			"last_modified": data.get("last_modified")
		}
	return {}

func _datetime_to_unix(dt: Dictionary) -> int:
	# Simple helper for sorting
	return Time.get_unix_time_from_datetime_dict(dt)

func _set_is_requesting(value: bool):
	is_requesting = value
	status_changed.emit(is_requesting)

func send_prompt(prompt: String, context: String = "", tools: Array = [], image_data: Dictionary = {}):
	if api_key == "":
		error_occurred.emit("API Key is missing.")
		return

	# If this is the start of a new topic (or history cleared), add context

	var parts = []
	
	# Add context if provided (and history empty)
	if history.is_empty() and context != "":
		parts.append({"text": context})
		
	# Add text prompt
	parts.append({"text": prompt})
	
	# Add image if provided
	if not image_data.is_empty():
		parts.append({
			"inline_data": {
				"mime_type": image_data["mime_type"],
				"data": image_data["data"]
			}
		})

	var user_content = {
		"role": "user",
		"parts": parts
	}
	
	# Add to transcript for UI mapping
	transcript.append({"role": "user", "text": prompt})
	if current_session_id == "":
		current_session_id = str(Time.get_unix_time_from_system()).replace(".", "_")
	
	_append_to_history(user_content)
	_send_request(tools)

func _prune_history():
	while history.size() > MAX_HISTORY_TURNS:
		history.remove_at(0)
	
	# After pruning, we MUST ensure the first message is a 'user' turn.
	# The Gemini API (v1beta) is strict about history starting with 'user'.
	while not history.is_empty() and history[0].get("role") != "user":
		history.remove_at(0)

func _append_to_history(content: Dictionary):
	# Ensure alternating roles for User/Model
	# If we are adding a 'user' role and the last role was also 'user', merge or replace.
	# Gemini REST API rejects consecutive identical roles.
	if not history.is_empty():
		var last = history[-1]
		if last.get("role") == content.get("role"):
			if content.get("role") == "user":
				# Merge parts instead of creating new turn
				last["parts"].append_array(content["parts"])
				return
			else:
				# Consecutive model calls - this shouldn't happen normally, 
				# but if it does, replacing is safer than consecutive identical roles.
				history[-1] = content
				return
	
	history.append(content)
	_prune_history()

func send_tool_response(tool_name: String, output: String, tools: Array = []):
	# Construct the function response part
	var response_content = {
		"role": "function",
		"parts": [{
			"functionResponse": {
				"name": tool_name,
				"response": {
					"output": output
				}
			}
		}]
	}
	_append_to_history(response_content)
	# We send the request again with the updated history and tools so the model can continue
	_send_request(tools)

func _send_request(tools: Array = []):
	var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent?key=" + api_key
	var headers = ["Content-Type: application/json"]
	
	var body = {
		"contents": history
	}
	
	# We only send tools if they were provided (usually on the first turn or always?)
	# Best practice: send tools if available.
	# But tools are usually static. We should probably store them.
	# For now, let's assume we pass them or need to store them.
	# Let's simple check if the LAST message was user, passing tools is fine.
	# Actually, persistent tools is better.
	# System Instruction to guide the model behavior
	body["system_instruction"] = {
		"parts": {
			"text": "You are a Godot Game Development Assistant integrated directly into the Godot Editor. Your goal is to help the user build their game VISUALLY in the editor.\n" +
			"When asked to create a scene, level, or object, you should PRIMARY use the `add_node` tool to construct the node hierarchy in the currently open scene.\n" +
			"If no scene is open, or you want to create a NEW standalone scene file (e.g. 'enemy.tscn'), you MUST use the `create_scene` tool FIRST. This will create and open the scene. The ROOT node of this new scene is represented by '.' path.\n" +
			"CRITICAL: After `create_scene`, do NOT call `add_node` to add a node with the same name/type as the root. You are already IN the root. Use '.' as the parent_path to add children to it.\n" +
			"UI & LAYOUT: NEVER use `Node.new()` (e.g. `Label.new()`) to build UI in a script's `_ready()` function. You MUST build the UI hierarchy using `add_node` in the editor.\n" +
			"To configure the visual state (position, size, text, color, texture), use the `set_property` tool (e.g. `set_property('HUD/Bar', 'size', [200, 20])`).\n" +
			"Use `set_theme_override` for theme-specific settings like `font_size` or `font_color` on Control nodes.\n" +
			"Use `instance_scene` to place your custom `.tscn` files inside other scenes. Do NOT reconstruct the hierarchy of a custom scene using `add_node` if a `.tscn` already exists.\n" +
			"INLINE EDITING: If the user message contains 'Selection Context:', it means they have selected code in the Godot script editor. You MUST use the `replace_selection` tool if your task is to Refactor, Fix, or Modify that specific code block.\n" +
			"Do NOT rewrite the whole file if only a selection is provided; just use `replace_selection` with the updated code for that block.\n" +
			"Do NOT write a script that instantiates nodes at runtime unless the user explicitly asks for a procedural generation script.\n" +
			"Instead, call `add_node` for each part of the scene (e.g. `add_node('.', 'Sprite2D', 'Icon')`).\n" +
			"Only use `create_script` for game logic (movement, health, etc) and attach it to the nodes you created.\n" +
			"When you create a script for a node, you MUST attach it. You can do this by passing `script_path` to `add_node` OR by using the `attach_script` tool.\n" +
			"To modify an existing script (WITHOUT a selection), first use `read_file` to understand its content, then use `edit_script` with the FULL updated code.\n" +
			"The user message might contain 'Project Structure:', which lists all classes and scenes in the project. Use this to avoid hallucinating file paths or class names.\n" +
			"If you are unsure about properties or methods for a specific node type, use the `get_class_info` tool to inspect it.\n" +
			"Always prefer `add_node`, `instance_scene`, and `set_property` over creating nodes via code for static scene elements and UI."
		}
	}
	
	if not tools.is_empty():
		body["tools"] = [{
			"function_declarations": tools
		}]
	
	is_requesting = true
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		is_requesting = false
		error_occurred.emit("Failed to send request: " + str(error))

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		error_occurred.emit("API Error: " + str(response_code) + " - " + str(json))
		return
		
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json and json.has("candidates"):
		var candidate = json["candidates"][0]
		var content = candidate.get("content", {})
		
		# Validation: Check if content is empty or malformed (safety block)
		if not content.has("parts") or content["parts"].is_empty():
			is_requesting = false
			var finish_reason = candidate.get("finishReason", "UNKNOWN")
			error_occurred.emit("Model failed to respond. Reason: " + finish_reason)
			# Do NOT append empty content to history
			return

		# Save model response to history using safe helper
		_append_to_history(content)
		
		var parts = content.get("parts", [])
		
		# Check for text response
		var text = ""
		var tool_calls = []
		
		for part in parts:
			if part.has("text"):
				text += part["text"]
			if part.has("functionCall"):
				tool_calls.append(part["functionCall"])
				
		if not tool_calls.is_empty():
			# Emit all tool calls at once
			tool_call_received.emit(tool_calls)
			# We wait for the tool execution(s)
			return
		
		if text != "":
			is_requesting = false
			transcript.append({"role": "model", "text": text})
			save_session()
			response_received.emit(text)
		else:
			# If no tools AND no text, it might be an empty response or unexpected format
			is_requesting = false
			# Don't emit error if we already emitted tool calls, but here tool_calls IS empty
			error_occurred.emit("Empty response from model.")
	else:
		is_requesting = false
		error_occurred.emit("Invalid response format.")

func send_tool_responses(responses: Array, tools: Array = []):
	# responses is an array of objects: { "functionResponse": { "name": ..., "response": ... } }
	# We need to structure it correctly for the API
	
	var parts = []
	for resp in responses:
		parts.append(resp)
		
	var response_content = {
		"role": "function",
		"parts": parts
	}
	
	_append_to_history(response_content)
	# We send the request again with the updated history and tools so the model can continue
	_send_request(tools)
