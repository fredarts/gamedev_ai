@tool
extends BaseToolHandler
class_name MemoryTools

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"save_memory":
			_save_memory(args.get("category"), args.get("content"))
			return true
		"list_memories":
			_list_memories()
			return true
		"delete_memory":
			_delete_memory(args.get("id"))
			return true
	return false

func _save_memory(category: String, content: String):
	if not executor.memory_manager:
		_emit_output("Error: Memory Manager not available.")
		return
	
	var valid_categories = ["architecture", "convention", "preference", "bug_fix", "project_info"]
	if category not in valid_categories:
		_emit_output("Error: Invalid category '" + category + "'. Valid categories: " + str(valid_categories))
		return
	
	var fact = executor.memory_manager.save_memory(category, content, "ai")
	_emit_output("Memory saved: [" + fact.get("id", "?") + "] (" + category + ") " + content)

func _list_memories():
	if not executor.memory_manager:
		_emit_output("Error: Memory Manager not available.")
		return
	
	_emit_output(executor.memory_manager.list_memories_text())

func _delete_memory(fact_id: String):
	if not executor.memory_manager:
		_emit_output("Error: Memory Manager not available.")
		return
	
	if executor.memory_manager.delete_memory(fact_id):
		_emit_output("Memory deleted: " + fact_id)
	else:
		_emit_output("Error: Memory not found with id '" + fact_id + "'. Use list_memories to see available memories.")
