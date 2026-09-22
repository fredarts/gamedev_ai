@tool
extends SceneTree

func _init():
	print("--- Running Godot MCP Server Unit Tests ---")
	
	var ToolExecutor = load("res://addons/gamedev_ai/tool_executor.gd")
	var MCPProtocol = load("res://addons/gamedev_ai/mcp/mcp_protocol.gd")
	
	var tool_exec = ToolExecutor.new()
	tool_exec.setup(null)
	
	var mcp = MCPProtocol.new()
	mcp.setup(tool_exec)
	
	# Test 1: initialize
	print("\n[Test 1] Testing 'initialize' request...")
	var init_req = {
		"jsonrpc": "2.0",
		"id": 1,
		"method": "initialize",
		"params": {"protocolVersion": "2024-11-05"}
	}
	var init_res = mcp.handle_request(init_req)
	assert(init_res.has("result"), "Expected 'result' in initialize response")
	assert(init_res["result"]["serverInfo"]["name"] == "gamedev-ai-godot", "Incorrect server name")
	print("  PASS: Initialized server: " + str(init_res["result"]["serverInfo"]["name"]))
	
	# Test 2: tools/list
	print("\n[Test 2] Testing 'tools/list' request...")
	var tools_req = {
		"jsonrpc": "2.0",
		"id": 2,
		"method": "tools/list",
		"params": {}
	}
	var tools_res = mcp.handle_request(tools_req)
	assert(tools_res.has("result"), "Expected 'result' in tools/list response")
	var tools = tools_res["result"]["tools"]
	assert(tools.size() > 10, "Expected at least 10 tools, found: " + str(tools.size()))
	print("  PASS: Found " + str(tools.size()) + " registered MCP tools.")
	
	# Test 3: prompts/list (Skills)
	print("\n[Test 3] Testing 'prompts/list' (Skills) request...")
	var prompts_req = {
		"jsonrpc": "2.0",
		"id": 3,
		"method": "prompts/list",
		"params": {}
	}
	var prompts_res = mcp.handle_request(prompts_req)
	assert(prompts_res.has("result"), "Expected 'result' in prompts/list response")
	var prompts = prompts_res["result"]["prompts"]
	assert(prompts.size() > 0, "Expected skills to be listed as prompts")
	print("  PASS: Found " + str(prompts.size()) + " registered MCP Skills/Prompts.")
	
	# Test 4: prompts/get
	print("\n[Test 4] Testing 'prompts/get' request...")
	var get_prompt_req = {
		"jsonrpc": "2.0",
		"id": 4,
		"method": "prompts/get",
		"params": {"name": "gdscript_modern_features"}
	}
	var get_prompt_res = mcp.handle_request(get_prompt_req)
	assert(get_prompt_res.has("result"), "Expected 'result' in prompts/get response")
	var messages = get_prompt_res["result"]["messages"]
	assert(messages.size() > 0, "Expected prompt message content")
	print("  PASS: Loaded skill content for 'gdscript_modern_features' (" + str(messages[0]["content"]["text"].length()) + " chars)")
	
	# Test 5: resources/list & resources/read
	print("\n[Test 5] Testing 'resources/list' and 'resources/read'...")
	var res_list_req = {
		"jsonrpc": "2.0",
		"id": 5,
		"method": "resources/list",
		"params": {}
	}
	var res_list_res = mcp.handle_request(res_list_req)
	assert(res_list_res.has("result"), "Expected 'result' in resources/list response")
	
	var read_res_req = {
		"jsonrpc": "2.0",
		"id": 6,
		"method": "resources/read",
		"params": {"uri": "godot://project/info"}
	}
	var read_res_res = mcp.handle_request(read_res_req)
	assert(read_res_res.has("result"), "Expected 'result' in resources/read response")
	print("  PASS: Read resource 'godot://project/info' successfully.")
	
	print("\n[SUCCESS] ALL MCP UNIT TESTS PASSED!")
	quit(0)
