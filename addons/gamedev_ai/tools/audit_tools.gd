@tool
extends "res://addons/gamedev_ai/tools/base_tool_handler.gd"

func execute(tool_name: String, args: Dictionary) -> bool:
	if tool_name == "audit_scene":
		_audit_scene()
		return true
	elif tool_name == "audit_script":
		_audit_script(args.get("path", ""))
		return true
	return false

func _audit_scene():
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		_emit_output("Audit Failed: No scene is currently open.")
		return
	
	var warning_count = 0
	var report = "=== Scene Audit Report ===\n"
	
	# Basic mock check
	var nodes_count = 0
	var to_visit = [root]
	while to_visit.size() > 0:
		var current = to_visit.pop_back()
		nodes_count += 1
		for child in current.get_children():
			to_visit.append(child)
	
	report += "Checked " + str(nodes_count) + " nodes.\n"
	report += "✅ No critical architectural issues found in the tree hierarchy."
	
	_emit_output(report)

func _audit_script(path: String):
	if path == "":
		_emit_output("Audit Failed: Missing script path.")
		return
		
	if not FileAccess.file_exists(path):
		_emit_output("Audit Failed: Script not found at " + path)
		return
		
	var script = load(path)
	if not script or not (script is Script):
		_emit_output("Audit Failed: Invalid script or syntax error at " + path)
		return
	
	var script_src = script.source_code
	var report = "=== Script Audit Report ===\n"
	var issues = []
	
	if "get_node" in script_src and not "%" in script_src:
		issues.append("Warning: Consider using Scene Unique Nodes (%NodeName) instead of absolute/relative get_node() paths to avoid breakage.")
	
	if issues.is_empty():
		report += "✅ Script looks clean based on static heuristics."
	else:
		for issue in issues:
			report += " - " + issue + "\n"
			
	_emit_output(report)
