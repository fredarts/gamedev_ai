@tool
extends RefCounted

var task_description: String = ""
var resources: Array[Dictionary] = [] # [{path, class_name, description}]
var scenes: Array[Dictionary] = []    # [{path, root_type, node_paths}]
var scripts: Array[Dictionary] = []   # [{path, functions, signals}]
var signals_connected: Array[Dictionary] = [] # [{source, signal, target, method}]
var test_suites: Array[Dictionary] = [] # [{path, passed, failed, errors}]
var metadata: Dictionary = {}

func clear():
	task_description = ""
	resources.clear()
	scenes.clear()
	scripts.clear()
	signals_connected.clear()
	test_suites.clear()
	metadata.clear()

func register_resource(path: String, p_class_name: String = "", description: String = ""):
	for r in resources:
		if r.get("path") == path:
			r["class_name"] = p_class_name
			r["description"] = description
			return
	resources.append({
		"path": path,
		"class_name": p_class_name,
		"description": description
	})

func register_scene(path: String, root_type: String = "", node_paths: Array = []):
	for s in scenes:
		if s.get("path") == path:
			s["root_type"] = root_type
			s["node_paths"] = node_paths
			return
	scenes.append({
		"path": path,
		"root_type": root_type,
		"node_paths": node_paths
	})

func register_script(path: String, functions: Array = [], signals: Array = []):
	for sc in scripts:
		if sc.get("path") == path:
			sc["functions"] = functions
			sc["signals"] = signals
			return
	scripts.append({
		"path": path,
		"functions": functions,
		"signals": signals
	})

func register_signal(source_path: String, signal_name: String, target_path: String, method_name: String):
	signals_connected.append({
		"source": source_path,
		"signal": signal_name,
		"target": target_path,
		"method": method_name
	})

func register_test_result(path: String, passed: int, failed: int, errors: Array = []):
	test_suites.append({
		"path": path,
		"passed": passed,
		"failed": failed,
		"errors": errors
	})

func to_condensed_prompt() -> String:
	var out = "### 📋 Pipeline Blackboard (Artifacts & Contracts)\n"
	out += "**Task:** " + task_description + "\n\n"
	
	if not resources.is_empty():
		out += "**Data Models & Resources Created:**\n"
		for r in resources:
			out += "- `" + r.get("path", "") + "`"
			if r.get("class_name", "") != "":
				out += " (class_name: " + r.get("class_name", "") + ")"
			if r.get("description", "") != "":
				out += " — " + r.get("description", "")
			out += "\n"
		out += "\n"
		
	if not scenes.is_empty():
		out += "**Scenes & UI Hierarchies Built:**\n"
		for s in scenes:
			out += "- `" + s.get("path", "") + "` (Root: " + s.get("root_type", "Node") + ")\n"
			var np = s.get("node_paths", [])
			if not np.is_empty():
				out += "  Nodes: " + ", ".join(np.slice(0, 8))
				if np.size() > 8:
					out += "... (+" + str(np.size() - 8) + " more)"
				out += "\n"
		out += "\n"
		
	if not scripts.is_empty():
		out += "**Scripts & Game Logic Implemented:**\n"
		for sc in scripts:
			out += "- `" + sc.get("path", "") + "`"
			var sigs = sc.get("signals", [])
			if not sigs.is_empty():
				out += " [Signals: " + ", ".join(sigs) + "]"
			out += "\n"
		out += "\n"
		
	if not signals_connected.is_empty():
		out += "**Connected Signals:**\n"
		for sig in signals_connected:
			out += "- `" + sig.get("source", "") + "." + sig.get("signal", "") + " -> " + sig.get("target", "") + "." + sig.get("method", "") + "()`\n"
		out += "\n"
		
	if not test_suites.is_empty():
		out += "**QA Test Suite Results:**\n"
		for t in test_suites:
			var status = "✅ PASSED" if t.get("failed", 0) == 0 else "❌ FAILED"
			out += "- " + status + " `" + t.get("path", "") + "` (" + str(t.get("passed", 0)) + " passed, " + str(t.get("failed", 0)) + " failed)\n"
		out += "\n"
		
	return out

func to_dict() -> Dictionary:
	return {
		"task_description": task_description,
		"resources": resources,
		"scenes": scenes,
		"scripts": scripts,
		"signals_connected": signals_connected,
		"test_suites": test_suites,
		"metadata": metadata
	}

func from_dict(d: Dictionary):
	task_description = d.get("task_description", "")
	resources = []
	for r in d.get("resources", []):
		resources.append(r)
	scenes = []
	for s in d.get("scenes", []):
		scenes.append(s)
	scripts = []
	for sc in d.get("scripts", []):
		scripts.append(sc)
	signals_connected = []
	for sig in d.get("signals_connected", []):
		signals_connected.append(sig)
	test_suites = []
	for t in d.get("test_suites", []):
		test_suites.append(t)
	metadata = d.get("metadata", {})
