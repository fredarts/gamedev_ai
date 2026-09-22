@tool
extends "res://addons/gamedev_ai/tools/base_tool_handler.gd"

## OmniTools
## Provides dynamic reflection, arbitrary GDScript evaluation, ClassDB inspection,
## and runtime debugger interrogation for LLMs via MCP.

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"omni_eval":
			_omni_eval(args.get("code", ""), args.get("context_node_path", ""))
			return true
		"omni_manage":
			_omni_manage(args)
			return true
		"get_runtime_errors":
			_get_runtime_errors(args.get("clear_after_read", false))
			return true
		"get_runtime_status":
			_get_runtime_status()
			return true
	return false

# --- Omni Eval ---

func _omni_eval(code: String, context_node_path: String = ""):
	if code.strip_edges().is_empty():
		_emit_output("Error: 'code' parameter cannot be empty.")
		return

	var context_node: Node = null
	if not context_node_path.is_empty():
		var root = EditorInterface.get_edited_scene_root()
		if root:
			context_node = root.get_node_or_null(context_node_path)
	if not context_node and Engine.is_editor_hint():
		context_node = EditorInterface.get_edited_scene_root()

	# Try 1: Expression evaluation (ideal for one-liners and calculations)
	var expr = Expression.new()
	var parse_err = expr.parse(code, ["node", "editor"])
	if parse_err == OK:
		var result = expr.execute([context_node, EditorInterface], context_node, false)
		if not expr.has_execute_failed():
			_emit_output(JSON.stringify({
				"status": "success",
				"mode": "expression",
				"result": result,
				"context_node": context_node.name if context_node else "none"
			}, "\t"))
			return

	# Try 2: Dynamic GDScript execution block
	var script = GDScript.new()
	var wrapped_code = "@tool\nextends RefCounted\n\n"
	wrapped_code += "func _eval_block(node, editor):\n"
	
	# Indent lines
	for line in code.split("\n"):
		wrapped_code += "\t" + line + "\n"
		
	# Add a fallback return if not specified
	if not code.contains("return "):
		wrapped_code += "\treturn \"Execution completed successfully.\"\n"
		
	script.source_code = wrapped_code
	var reload_err = script.reload()
	if reload_err != OK:
		_emit_output(JSON.stringify({
			"status": "compile_error",
			"code": reload_err,
			"error_message": "Failed to compile GDScript expression block.",
			"raw_code": code
		}, "\t"))
		return
		
	var instance = script.new()
	if not instance:
		_emit_output("Error: Could not instantiate dynamic evaluation script.")
		return
		
	var eval_result = instance.call("_eval_block", context_node, EditorInterface)
	_emit_output(JSON.stringify({
		"status": "success",
		"mode": "gdscript_block",
		"result": str(eval_result),
		"context_node": context_node.name if context_node else "none"
	}, "\t"))

# --- Omni Manage ---

func _omni_manage(args: Dictionary):
	var action = args.get("action", "")
	var target_path = args.get("target_path", "")
	var method_name = args.get("method_name", "")
	var method_args = args.get("args", [])
	var prop_name = args.get("property", "")
	var prop_val = args.get("value", null)
	var target_class = args.get("class_name", "")
	
	var root = EditorInterface.get_edited_scene_root()
	var target_node: Node = null
	if not target_path.is_empty() and root:
		if target_path == "." or target_path == "root":
			target_node = root
		else:
			target_node = root.get_node_or_null(target_path)
			if not target_node:
				target_node = root.find_child(target_path.get_file(), true, false)

	match action:
		"call_method":
			if not target_node:
				_emit_output("Error: Target node not found for call_method: " + target_path)
				return
			if not target_node.has_method(method_name):
				_emit_output("Error: Node '" + target_node.name + "' does not have method '" + method_name + "'.")
				return
				
			var res = target_node.callv(method_name, method_args)
			_emit_output(JSON.stringify({
				"status": "success",
				"action": "call_method",
				"node": target_node.name,
				"method": method_name,
				"returned": str(res)
			}, "\t"))

		"get_property":
			if not target_node:
				_emit_output("Error: Target node not found: " + target_path)
				return
			var val = target_node.get(prop_name)
			_emit_output(JSON.stringify({
				"status": "success",
				"node": target_node.name,
				"property": prop_name,
				"value": val
			}, "\t"))

		"set_property":
			if not target_node:
				_emit_output("Error: Target node not found: " + target_path)
				return
			
			var old_val = target_node.get(prop_name)
			var ur = _get_undo_redo()
			if ur:
				var scene_root = EditorInterface.get_edited_scene_root()
				ur.create_action("Omni Set Property: " + prop_name, UndoRedo.MERGE_DISABLE, scene_root)
				ur.add_do_property(target_node, prop_name, prop_val)
				ur.add_undo_property(target_node, prop_name, old_val)
				ur.commit_action()
			else:
				target_node.set(prop_name, prop_val)
				
			_emit_output(JSON.stringify({
				"status": "success",
				"node": target_node.name,
				"property": prop_name,
				"previous_value": old_val,
				"new_value": prop_val,
				"undo_supported": ur != null
			}, "\t"))

		"inspect_class":
			var cls = target_class
			if cls.is_empty() and target_node:
				cls = target_node.get_class()
			if cls.is_empty():
				_emit_output("Error: Provide either 'class_name' or a valid 'target_path'.")
				return
				
			if not ClassDB.class_exists(cls):
				_emit_output("Error: Class '" + cls + "' does not exist in ClassDB.")
				return
				
			var methods_raw = ClassDB.class_get_method_list(cls, true)
			var methods: Array = []
			for m in methods_raw:
				methods.append(m.name)
				
			var signals_raw = ClassDB.class_get_signal_list(cls, true)
			var signals: Array = []
			for s in signals_raw:
				signals.append(s.name)
				
			var properties_raw = ClassDB.class_get_property_list(cls, true)
			var props: Array = []
			for p in properties_raw:
				props.append({"name": p.name, "type": p.type, "hint_string": p.hint_string})
				
			_emit_output(JSON.stringify({
				"class": cls,
				"parent_class": ClassDB.get_parent_class(cls),
				"can_instantiate": ClassDB.can_instantiate(cls),
				"methods_count": methods.size(),
				"methods": methods.slice(0, 50),
				"signals": signals,
				"properties_count": props.size(),
				"properties": props.slice(0, 50)
			}, "\t"))

		"list_methods":
			var methods: Array = []
			if target_node:
				for m in target_node.get_method_list():
					methods.append(m.name)
			elif not target_class.is_empty() and ClassDB.class_exists(target_class):
				for m in ClassDB.class_get_method_list(target_class, true):
					methods.append(m.name)
			else:
				_emit_output("Error: Must provide a valid target_node or class_name.")
				return
				
			_emit_output(JSON.stringify({"methods": methods}, "\t"))

		"list_properties":
			if not target_node:
				_emit_output("Error: Target node required to list properties.")
				return
			var props: Array = []
			for p in target_node.get_property_list():
				props.append({"name": p.name, "type": p.type, "current_value": str(target_node.get(p.name))})
			_emit_output(JSON.stringify({"node": target_node.name, "properties": props}, "\t"))

		_:
			_emit_output("Error: Unknown omni_manage action '" + action + "'. Valid actions: call_method, get_property, set_property, inspect_class, list_methods, list_properties")

# --- Runtime Debugger Tools ---

func _get_runtime_errors(clear_after_read: bool = false):
	var dbg = executor.debugger_plugin if executor and "debugger_plugin" in executor else null
	if not dbg:
		_emit_output("Error: AIDebuggerPlugin is not attached to tool executor.")
		return
		
	var errors = dbg.get_runtime_errors()
	var status = dbg.get_runtime_status()
	
	if clear_after_read:
		dbg.clear_runtime_errors()
		
	_emit_output(JSON.stringify({
		"status": status,
		"errors_count": errors.size(),
		"errors": errors
	}, "\t"))

func _get_runtime_status():
	var dbg = executor.debugger_plugin if executor and "debugger_plugin" in executor else null
	if not dbg:
		_emit_output("Error: AIDebuggerPlugin is not attached to tool executor.")
		return
		
	var status = dbg.get_runtime_status()
	_emit_output(JSON.stringify(status, "\t"))
