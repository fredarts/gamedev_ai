@tool
extends SceneTree

func _init():
	print("==================================================")
	print("🧪 RUNNING OMNI TOOLS & DEBUGGER PLUGIN TEST SUITE")
	print("==================================================")
	
	var passed = 0
	var failed = 0
	
	var ToolExecutor = load("res://addons/gamedev_ai/tool_executor.gd")
	var AIDebuggerPluginScript = load("res://addons/gamedev_ai/debugger/ai_debugger_plugin.gd")
	var MCPProtocolScript = load("res://addons/gamedev_ai/mcp/mcp_protocol.gd")
	
	var executor = ToolExecutor.new()
	executor.setup(null)
	
	var debugger_plugin = AIDebuggerPluginScript.new()
	executor.debugger_plugin = debugger_plugin
	
	var protocol = MCPProtocolScript.new()
	protocol.setup(executor)
	
	# Helper output catcher
	var last_output = ""
	executor.tool_output.connect(func(out):
		last_output = str(out)
	)
	
	# Test 1: omni_eval - Expression math
	print("\n[Test 1] Testing omni_eval with basic expression...")
	last_output = ""
	executor.execute_tool("omni_eval", {"code": "2 + 2 * 10"})
	if "22" in last_output and "success" in last_output:
		print("  ✅ PASS: Expression evaluated correctly (result=22)")
		passed += 1
	else:
		print("  ❌ FAIL: Output was: " + last_output)
		failed += 1

	# Test 2: omni_eval - GDScript multi-line block
	print("\n[Test 2] Testing omni_eval with multi-line GDScript block...")
	last_output = ""
	var code_block = "var x = [10, 20, 30]\nvar total = 0\nfor i in x:\n\ttotal += i\nreturn total"
	executor.execute_tool("omni_eval", {"code": code_block})
	if "60" in last_output and "success" in last_output:
		print("  ✅ PASS: GDScript block executed and returned 60")
		passed += 1
	else:
		print("  ❌ FAIL: Output was: " + last_output)
		failed += 1

	# Test 3: omni_manage - inspect_class on Node2D
	print("\n[Test 3] Testing omni_manage inspect_class...")
	last_output = ""
	executor.execute_tool("omni_manage", {"action": "inspect_class", "class_name": "Node2D"})
	if "Node2D" in last_output and "CanvasItem" in last_output and "methods" in last_output:
		print("  ✅ PASS: ClassDB inspection returned class hierarchy and methods")
		passed += 1
	else:
		print("  ❌ FAIL: Output was: " + last_output)
		failed += 1

	# Test 4: AIDebuggerPlugin - status and simulated error injection
	print("\n[Test 4] Testing AIDebuggerPlugin simulated error capture...")
	debugger_plugin.inject_simulated_error("Test runtime null reference exception in player.gd:42", ["stack_trace_item"])
	var status = debugger_plugin.get_runtime_status()
	var errors = debugger_plugin.get_runtime_errors()
	if status["total_errors_recorded"] == 1 and errors.size() == 1 and "player.gd:42" in errors[0]["raw_message"]:
		print("  ✅ PASS: Debugger plugin captured and recorded runtime error")
		passed += 1
	else:
		print("  ❌ FAIL: Debugger status: " + str(status))
		failed += 1

	# Test 5: MCP Tool Execution - get_runtime_errors via MCP
	print("\n[Test 5] Testing get_runtime_errors through MCP Protocol...")
	var mcp_req = {
		"jsonrpc": "2.0",
		"id": 101,
		"method": "tools/call",
		"params": {
			"name": "get_runtime_errors",
			"arguments": {}
		}
	}
	var mcp_res = protocol.handle_request(mcp_req)
	if mcp_res.has("result") and "player.gd:42" in mcp_res["result"]["content"][0]["text"]:
		print("  ✅ PASS: MCP tools/call for get_runtime_errors returned runtime error info")
		passed += 1
	else:
		print("  ❌ FAIL: MCP response: " + str(mcp_res))
		failed += 1

	# Test 6: MCP Resources - Read godot://debugger/runtime_logs
	print("\n[Test 6] Testing resources/read for godot://debugger/runtime_logs...")
	var res_req = {
		"jsonrpc": "2.0",
		"id": 102,
		"method": "resources/read",
		"params": {
			"uri": "godot://debugger/runtime_logs"
		}
	}
	var res_resp = protocol.handle_request(res_req)
	if res_resp.has("result") and res_resp["result"]["contents"].size() > 0 and "errors" in res_resp["result"]["contents"][0]["text"]:
		print("  ✅ PASS: MCP resources/read returned debugger runtime logs resource")
		passed += 1
	else:
		print("  ❌ FAIL: Resource read failed: " + str(res_resp))
		failed += 1

	print("\n==================================================")
	print("📊 RESULTS: " + str(passed) + " PASSED, " + str(failed) + " FAILED")
	print("==================================================")
	
	if failed == 0:
		print("🎉 ALL TESTS COMPLETED SUCCESSFULLY!")
	
	quit(0 if failed == 0 else 1)
