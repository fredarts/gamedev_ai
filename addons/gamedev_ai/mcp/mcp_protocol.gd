@tool
extends RefCounted

## MCP Protocol Handler (JSON-RPC 2.0 & Model Context Protocol Spec 2024-11-05)
## Bridges Antigravity / external AI clients with Godot tools, resources, and skills.

var tool_executor: RefCounted
var memory_manager: RefCounted
var context_manager: RefCounted

const PROTOCOL_VERSION = "2024-11-05"
const SERVER_NAME = "gamedev-ai-godot"
const SERVER_VERSION = "1.0.0"

func setup(_tool_executor: RefCounted, _memory_manager: RefCounted = null, _context_manager: RefCounted = null):
	tool_executor = _tool_executor
	memory_manager = _memory_manager
	context_manager = _context_manager

## Process a single incoming JSON-RPC request dictionary and return response dictionary
func handle_request(req: Dictionary) -> Dictionary:
	var id = req.get("id", null)
	if id is float and is_finite(id) and floor(id) == id:
		id = int(id)
	var method = req.get("method", "")
	var params = req.get("params", {})
	
	if not req.has("jsonrpc") or req.get("jsonrpc") != "2.0":
		if not req.has("id"):
			return {}
		return _error_response(id, -32600, "Invalid Request: jsonrpc must be '2.0'")
	
	match method:
		"initialize":
			return _handle_initialize(id, params)
		"notifications/initialized", "initialized", "notifications/cancelled":
			return {} # Notification, no response needed
		"ping":
			return _success_response(id, {})
		"tools/list":
			return _handle_tools_list(id, params)
		"tools/call":
			return _handle_tools_call(id, params)
		"resources/list":
			return _handle_resources_list(id, params)
		"resources/read":
			return _handle_resources_read(id, params)
		"prompts/list":
			return _handle_prompts_list(id, params)
		"prompts/get":
			return _handle_prompts_get(id, params)
		_:
			return _error_response(id, -32601, "Method not found: " + method)

func _handle_initialize(id, _params: Dictionary) -> Dictionary:
	return _success_response(id, {
		"protocolVersion": PROTOCOL_VERSION,
		"capabilities": {
			"tools": {
				"listChanged": false
			},
			"resources": {
				"subscribe": false,
				"listChanged": false
			},
			"prompts": {
				"listChanged": false
			},
			"logging": {}
		},
		"serverInfo": {
			"name": SERVER_NAME,
			"version": SERVER_VERSION
		},
		"instructions": "Godot 4 Engine Game Development MCP Server. Provides tools to create nodes, edit scripts, paint tilemaps, inspect scenes, and build complete games in Godot."
	})

func _handle_tools_list(id, _params: Dictionary) -> Dictionary:
	var tools_list: Array = []
	
	if tool_executor:
		var raw_declarations: Array = []
		if tool_executor.has_method("get_tool_definitions"):
			raw_declarations = tool_executor.get_tool_definitions()
		elif tool_executor.has_method("get_declarations"):
			raw_declarations = tool_executor.get_declarations()
		elif tool_executor.has_method("get_tools"):
			raw_declarations = tool_executor.get_tools()
			
		for decl in raw_declarations:
			var tool_name = decl.get("name", "")
			var desc = decl.get("description", "")
			var params_obj = decl.get("parameters", {})
			
			# Convert to JSON Schema format expected by MCP
			var mcp_tool = {
				"name": tool_name,
				"description": desc,
				"inputSchema": _convert_to_json_schema(params_obj)
			}
			tools_list.append(mcp_tool)
	
	return _success_response(id, {
		"tools": tools_list
	})

func _convert_to_json_schema(godot_params: Dictionary) -> Dictionary:
	var schema = {
		"type": "object",
		"properties": {},
		"required": godot_params.get("required", [])
	}
	
	var props = godot_params.get("properties", {})
	for prop_name in props.keys():
		var prop_def = props[prop_name]
		var prop_type = prop_def.get("type", "STRING").to_lower()
		
		var json_type = "string"
		match prop_type:
			"string": json_type = "string"
			"integer", "int": json_type = "integer"
			"number", "float": json_type = "number"
			"boolean", "bool": json_type = "boolean"
			"array": json_type = "array"
			"object": json_type = "object"
			_: json_type = "string"
			
		var schema_prop = {
			"type": json_type,
			"description": prop_def.get("description", "")
		}
		
		if prop_def.has("enum"):
			schema_prop["enum"] = prop_def["enum"]
		if prop_def.has("items"):
			schema_prop["items"] = prop_def["items"]
			
		schema["properties"][prop_name] = schema_prop
		
	return schema

func _handle_tools_call(id, params: Dictionary) -> Dictionary:
	var tool_name = params.get("name", "")
	var arguments = params.get("arguments", {})
	
	if tool_name == "":
		return _error_response(id, -32602, "Missing tool name in arguments")
		
	if not tool_executor:
		return _error_response(id, -32000, "ToolExecutor not initialized")
	
	# Capture output via signal listener
	var captured_output: Array = []
	var output_callable = func(out):
		# Strip BBCode tags for clean JSON output
		var clean_out = _strip_bbcode(str(out))
		captured_output.append(clean_out)
		
	if tool_executor.has_signal("tool_output"):
		tool_executor.tool_output.connect(output_callable)
	
	# Execute the tool
	tool_executor.execute_tool(tool_name, arguments)
	
	if tool_executor.has_signal("tool_output") and tool_executor.tool_output.is_connected(output_callable):
		tool_executor.tool_output.disconnect(output_callable)
		
	var result_text = "\n".join(captured_output)
	if result_text.strip_edges().is_empty():
		result_text = "Tool '" + tool_name + "' executed successfully."
		
	var is_error = result_text.begins_with("Error:") or result_text.contains("Failed") or result_text.contains("Invalid")
	
	return _success_response(id, {
		"content": [
			{
				"type": "text",
				"text": result_text
			}
		],
		"isError": is_error
	})

func _handle_resources_list(id, _params: Dictionary) -> Dictionary:
	var resources = [
		{
			"uri": "godot://scene/active",
			"name": "Active Edited Scene",
			"description": "Hierarchy and node structure of the currently active scene in Godot editor.",
			"mimeType": "application/json"
		},
		{
			"uri": "godot://project/info",
			"name": "Project Information",
			"description": "Godot project name, version, main scene, and settings.",
			"mimeType": "application/json"
		},
		{
			"uri": "godot://lsp/diagnostics",
			"name": "LSP Diagnostics",
			"description": "Active compilation errors, warnings, and type diagnostics from Godot LSP.",
			"mimeType": "application/json"
		},
		{
			"uri": "godot://memory/all",
			"name": "Project Architectural Memory",
			"description": "Persisted design decisions, mechanics, and notes stored in memory manager.",
			"mimeType": "application/json"
		},
		{
			"uri": "godot://debugger/runtime_logs",
			"name": "Godot Runtime Debugger Logs",
			"description": "Real-time error logs, exceptions, and execution states from running game instances.",
			"mimeType": "application/json"
		}
	]
	
	return _success_response(id, {
		"resources": resources
	})

func _handle_resources_read(id, params: Dictionary) -> Dictionary:
	var uri = params.get("uri", "")
	var contents: Array = []
	
	match uri:
		"godot://scene/active":
			var scene_data = _get_active_scene_data()
			contents.append({
				"uri": uri,
				"mimeType": "application/json",
				"text": JSON.stringify(scene_data, "\t")
			})
		"godot://project/info":
			var proj_data = _get_project_info()
			contents.append({
				"uri": uri,
				"mimeType": "application/json",
				"text": JSON.stringify(proj_data, "\t")
			})
		"godot://lsp/diagnostics":
			var lsp_data = _get_lsp_diagnostics()
			contents.append({
				"uri": uri,
				"mimeType": "application/json",
				"text": JSON.stringify(lsp_data, "\t")
			})
		"godot://memory/all":
			var mem_data = _get_memories_data()
			contents.append({
				"uri": uri,
				"mimeType": "application/json",
				"text": JSON.stringify(mem_data, "\t")
			})
		"godot://debugger/runtime_logs":
			var dbg_data = _get_runtime_debugger_logs()
			contents.append({
				"uri": uri,
				"mimeType": "application/json",
				"text": JSON.stringify(dbg_data, "\t")
			})
		_:
			return _error_response(id, -32002, "Resource not found: " + uri)
			
	return _success_response(id, {
		"contents": contents
	})

func _handle_prompts_list(id, _params: Dictionary) -> Dictionary:
	var prompts: Array = []
	var skills_dir = "res://addons/gamedev_ai/skills/"
	
	if DirAccess.dir_exists_absolute(skills_dir):
		var dir = DirAccess.open(skills_dir)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir() and file_name.ends_with(".md"):
					var prompt_name = file_name.trim_suffix(".md")
					var title = prompt_name.replace("_", " ").capitalize()
					prompts.append({
						"name": prompt_name,
						"description": "Godot 4 Best Practice Skill: " + title,
						"arguments": []
					})
				file_name = dir.get_next()
	
	return _success_response(id, {
		"prompts": prompts
	})

func _handle_prompts_get(id, params: Dictionary) -> Dictionary:
	var prompt_name = params.get("name", "")
	var skill_path = "res://addons/gamedev_ai/skills/" + prompt_name + ".md"
	
	if not FileAccess.file_exists(skill_path):
		return _error_response(id, -32001, "Skill prompt not found: " + prompt_name)
		
	var file = FileAccess.open(skill_path, FileAccess.READ)
	if not file:
		return _error_response(id, -32000, "Could not open skill file: " + skill_path)
		
	var content = file.get_as_text()
	file.close()
	
	return _success_response(id, {
		"description": "Skill instructions for " + prompt_name,
		"messages": [
			{
				"role": "user",
				"content": {
					"type": "text",
					"text": content
				}
			}
		]
	})

# --- Resource Helper Functions ---

func _get_active_scene_data() -> Dictionary:
	if not Engine.is_editor_hint():
		return {"error": "Not running in Godot editor"}
		
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		return {"status": "no_scene_open", "nodes": []}
		
	return {
		"scene_file_path": root.scene_file_path,
		"root_name": root.name,
		"root_type": root.get_class(),
		"tree": _serialize_node_recursive(root)
	}

func _serialize_node_recursive(node: Node, depth: int = 0) -> Dictionary:
	if depth > 8 or not is_instance_valid(node):
		return {}
		
	var node_info = {
		"name": node.name,
		"type": node.get_class(),
		"path": str(node.get_path()),
		"script": node.get_script().resource_path if node.get_script() else "",
		"children": []
	}
	
	for child in node.get_children():
		node_info["children"].append(_serialize_node_recursive(child, depth + 1))
		
	return node_info

func _get_project_info() -> Dictionary:
	return {
		"name": ProjectSettings.get_setting("application/config/name", "Unnamed Godot Project"),
		"main_scene": ProjectSettings.get_setting("application/run/main_scene", ""),
		"features": ProjectSettings.get_setting("application/config/features", []),
		"viewport_width": ProjectSettings.get_setting("display/window/size/viewport_width", 1152),
		"viewport_height": ProjectSettings.get_setting("display/window/size/viewport_height", 648)
	}

func _get_lsp_diagnostics() -> Dictionary:
	if tool_executor and "lsp_client" in tool_executor and tool_executor.lsp_client:
		return {
			"connected": tool_executor.lsp_client.is_connected_to_lsp(),
			"diagnostics": tool_executor.lsp_client.get_cached_diagnostics() if tool_executor.lsp_client.has_method("get_cached_diagnostics") else {}
		}
	return {"connected": false, "diagnostics": {}}

func _get_memories_data() -> Array:
	if memory_manager and memory_manager.has_method("get_all_memories"):
		return memory_manager.get_all_memories()
	return []

func _get_runtime_debugger_logs() -> Dictionary:
	if tool_executor and "debugger_plugin" in tool_executor and tool_executor.debugger_plugin:
		return {
			"status": tool_executor.debugger_plugin.get_runtime_status(),
			"errors": tool_executor.debugger_plugin.get_runtime_errors()
		}
	return {"status": {"is_active": false}, "errors": []}

func _strip_bbcode(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[[^\\]]*\\]")
	return regex.sub(text, "", true)

func _success_response(id, result: Dictionary) -> Dictionary:
	return {
		"jsonrpc": "2.0",
		"id": id,
		"result": result
	}

func _error_response(id, code: int, message: String) -> Dictionary:
	return {
		"jsonrpc": "2.0",
		"id": id,
		"error": {
			"code": code,
			"message": message
		}
	}
