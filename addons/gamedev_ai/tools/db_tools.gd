@tool
extends BaseToolHandler
class_name DBTools

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"index_codebase":
			if executor.vector_db:
				executor.vector_db.index_project()
			else:
				_emit_output("Error: VectorDB not initialized.")
			return true
		"semantic_search":
			if executor.vector_db:
				executor.vector_db.search(args.get("query", ""))
			else:
				_emit_output("Error: VectorDB not initialized.")
			return true
	return false
