import os

script_dir = os.path.dirname(os.path.abspath(__file__))
path = os.path.join(script_dir, 'tools', 'node_tools.gd')
append_code = """

func _analyze_node_children(node_path: String, max_depth: int = 5):
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		_emit_output("Error: No scene open.")
		return
		
	var node = root.get_node(node_path) if node_path != "." else root
	if not node:
		_emit_output("Error: Node not found: '" + node_path + "'")
		return
		
	var dump = "Analysis of '" + node.name + "' tree (Max Depth: " + str(max_depth) + "):\\n"
	dump += _node_to_string_detailed(node, 0, max_depth)
	_emit_output(dump)

func _node_to_string_detailed(node: Node, current_depth: int, max_depth: int) -> String:
	if current_depth > max_depth:
		return "  ".repeat(current_depth) + "... (max depth reached, " + str(node.get_child_count()) + " children hidden)\\n"
		
	var s = "  ".repeat(current_depth)
	s += node.name + " (" + node.get_class() + ")"
	
	var extras: Array = []
	if node.get_script(): extras.append("script:" + node.get_script().resource_path.get_file())
	if "position" in node: extras.append("pos:" + str(node.get("position")))
	if node is Control: extras.append("size:" + str(node.size))
	if node is CanvasItem and not node.visible: extras.append("hidden")
	if "text" in node and node.get("text") != null and str(node.get("text")) != "": 
		var text = str(node.get("text"))
		if text.length() > 15: text = text.substr(0, 15) + "..."
		extras.append("text:'" + text.replace("\\n", " ").replace("\\r", "") + "'")
	
	if not extras.is_empty():
		s += " [" + ", ".join(extras) + "]"
	s += "\\n"
	
	for child in node.get_children():
		s += _node_to_string_detailed(child, current_depth + 1, max_depth)
	return s
"""

with open(path, 'a', encoding='utf-8') as f:
    f.write(append_code)
print("Done appending")
