@tool
extends BaseToolHandler
class_name FileTools

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"remove_file":
			var file_path = args.get("path", "")
			_request_confirmation("Delete file '" + file_path + "' permanently?", tool_name, args)
			return true
		"list_dir":
			_list_dir(args.get("path"))
			return true
		"read_file":
			_read_file(args.get("path"))
			return true
		"find_file":
			_find_file(args.get("pattern"))
			return true
		"grep_search":
			_grep_search(args.get("query"), args.get("include", ""), args.get("max_results", 20))
			return true
		"search_in_files":
			_search_in_files(args.get("pattern"), 20)
			return true
		"move_files_batch":
			_request_confirmation("Execute the following file moves/refactors?\n\n" + _format_moves(args.get("moves", {})), tool_name, args)
			return true
	return false

# --- Utility ---

func _format_moves(moves: Dictionary) -> String:
	var text = ""
	for old_path in moves:
		text += old_path + " -> " + str(moves[old_path]) + "\n"
	return text

func _recursive_find(path: String, pattern: String) -> Array:
	var results = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					results.append_array(_recursive_find(path + file_name + "/", pattern))
			else:
				if pattern in file_name:
					results.append(path + file_name)
			file_name = dir.get_next()
	return results

func _grep_recursive(dir_path: String, query_lower: String, extensions: Array, results: Array, max_results: int):
	if results.size() >= max_results:
		return
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "" and results.size() < max_results:
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path = dir_path + file_name
		if dir.current_is_dir():
			_grep_recursive(full_path + "/", query_lower, extensions, results, max_results)
		else:
			var ext = file_name.get_extension()
			if ext in extensions:
				_grep_file(full_path, query_lower, results, max_results)
		file_name = dir.get_next()

func _grep_file(file_path: String, query_lower: String, results: Array, max_results: int):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file: return
	var line_num = 0
	while not file.eof_reached() and results.size() < max_results:
		line_num += 1
		var line = file.get_line()
		if line.to_lower().find(query_lower) != -1:
			results.append({"path": file_path, "line": line_num, "content": line})

func _search_in_files_recursive(dir_path: String, regex: RegEx, results: Array, max_results: int):
	if results.size() >= max_results: return
	var dir = DirAccess.open(dir_path)
	if not dir: return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "" and results.size() < max_results:
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path = dir_path + file_name
		if dir.current_is_dir():
			_search_in_files_recursive(full_path + "/", regex, results, max_results)
		elif file_name.ends_with(".gd"):
			var file = FileAccess.open(full_path, FileAccess.READ)
			if file:
				var line_num = 0
				while not file.eof_reached() and results.size() < max_results:
					line_num += 1
					var line = file.get_line()
					if regex.search(line) != null:
						results.append({"path": full_path, "line": line_num, "content": line})
		file_name = dir.get_next()

# --- Actions ---

func _list_dir(path: String):
	if not path.begins_with("res://"):
		_emit_output("Error: Path must start with res://")
		return
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var files = []
		while file_name != "":
			if dir.current_is_dir(): files.append(file_name + "/")
			else: files.append(file_name)
			file_name = dir.get_next()
		_emit_output("Directory contents of " + path + ":\n" + str(files))
	else:
		_emit_output("Error: Could not open directory " + path)

func _read_file(path: String):
	if not path.begins_with("res://"):
		_emit_output("Error: Path must start with res://")
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		_emit_output("Content of " + path + ":\n" + content)
	else:
		var err = FileAccess.get_open_error()
		_emit_output("Error: Could not open file " + path + ". Code: " + str(err))

func _find_file(pattern: String):
	var contents = _recursive_find("res://", pattern)
	if contents.is_empty():
		_emit_output("No files found matching '" + pattern + "'")
	else:
		_emit_output("Found files:\n" + str(contents))

func _grep_search(query: String, include: String = "", max_results: int = 20):
	max_results = clampi(max_results, 1, 50)
	var results: Array = []
	var extensions: Array = []
	if include != "":
		extensions.append(include.replace("*", "").replace(".", ""))
	else:
		extensions = ["gd", "tscn", "tres", "cfg", "json", "txt", "md", "shader", "gdshader"]
	
	_grep_recursive("res://", query.to_lower(), extensions, results, max_results)
	
	if results.is_empty():
		_emit_output("No matches found for '" + query + "'" + (" in *." + extensions[0] if extensions.size() == 1 else "") + ".")
		return
	
	var output = "Found " + str(results.size()) + " match(es) for '" + query + "':\n\n"
	for r in results:
		output += r.path + ":" + str(r.line) + ": " + r.content.strip_edges() + "\n"
	
	if results.size() >= max_results:
		output += "\n(Results capped at " + str(max_results) + ". Narrow your query or use 'include' filter.)"
	_emit_output(output)

func _search_in_files(pattern: String, max_results: int = 20):
	max_results = clampi(max_results, 1, 50)
	var regex = RegEx.new()
	var err = regex.compile(pattern)
	if err != OK:
		_emit_output("Error: Invalid regular expression pattern.")
		return
		
	var results: Array = []
	_search_in_files_recursive("res://", regex, results, max_results)
	
	if results.is_empty():
		_emit_output("No matches found for pattern '" + pattern + "' in .gd files.")
		return
		
	var output = "Found " + str(results.size()) + " match(es) for pattern '" + pattern + "':\n\n"
	for r in results:
		output += r.path + ":" + str(r.line) + ": " + r.content.strip_edges() + "\n"
		
	if results.size() >= max_results:
		output += "\n(Results capped at " + str(max_results) + ". Narrow your pattern if needed.)"
	_emit_output(output)

func _remove_file(path: String):
	if not path.begins_with("res://"):
		_emit_output("Error: Path must start with res://")
		return
		
	if path == "res://" or path == "res://addons/":
		_emit_output("Error: Safety block - Cannot delete project root or addons folder.")
		return
		
	if DirAccess.dir_exists_absolute(path):
		var err = DirAccess.remove_absolute(path)
		if err == OK:
			EditorInterface.get_resource_filesystem().scan()
			_emit_output("Success: Directory " + path + " deleted.")
		else:
			_emit_output("Error: Could not delete directory. Code: " + str(err))
	elif FileAccess.file_exists(path):
		var err = DirAccess.remove_absolute(path) # DirAccess removes files too in Godot 4
		if err == OK:
			EditorInterface.get_resource_filesystem().scan()
			_emit_output("Success: File " + path + " deleted.")
		else:
			_emit_output("Error: Could not delete file. Code: " + str(err))
	else:
		_emit_output("Error: Path not found: " + path)


func _move_files_batch(moves: Dictionary):
	var moved_count = 0
	var error_msgs = []
	var refactored_files = 0
	
	if _get_undo_redo():
		if not _is_composite():
			_get_undo_redo().create_action("Organize " + str(moves.size()) + " files", UndoRedo.MERGE_DISABLE, executor)
			
	for old_path in moves:
		var new_path = str(moves[old_path])
		if old_path == new_path:
			continue
			
		if not FileAccess.file_exists(old_path):
			error_msgs.append("Not found: " + old_path)
			continue
			
		var dir_path = new_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)
			
		if _get_undo_redo():
			_get_undo_redo().add_do_method(DirAccess, "rename_absolute", old_path, new_path)
			_get_undo_redo().add_undo_method(DirAccess, "rename_absolute", new_path, old_path)
			
			if FileAccess.file_exists(old_path + ".import"):
				_get_undo_redo().add_do_method(DirAccess, "rename_absolute", old_path + ".import", new_path + ".import")
				_get_undo_redo().add_undo_method(DirAccess, "rename_absolute", new_path + ".import", old_path + ".import")
			
			moved_count += 1
		else:
			var err = DirAccess.rename_absolute(old_path, new_path)
			if err != OK:
				error_msgs.append("Failed to move " + old_path.get_file() + " (Code: " + str(err) + ")")
				continue
			
			if FileAccess.file_exists(old_path + ".import"):
				DirAccess.rename_absolute(old_path + ".import", new_path + ".import")
			
			moved_count += 1
		
	# Now refactor text paths in all .gd, .tscn, .tres
	var files_to_check = _recursive_find("res://", ".gd")
	files_to_check.append_array(_recursive_find("res://", ".tscn"))
	files_to_check.append_array(_recursive_find("res://", ".tres"))
	
	for file_path in files_to_check:
		# Don't check files that we just moved out of under their OLD names
		if file_path in moves:
			continue
			
		# Wait, if a file WAS moved, its current path during refactor checking is the NEW path.
		var actual_path = file_path
		for old_p in moves:
			if file_path == old_p:
				actual_path = moves[old_p]
				break
		
		if not FileAccess.file_exists(actual_path):
			continue
			
		var changed = false
		var file = FileAccess.open(actual_path, FileAccess.READ)
		if not file: continue
		var content = file.get_as_text()
		file.close()
		
		for old_p in moves:
			var new_p = str(moves[old_p])
			# Be careful around extensions. E.g. res://old.tscn -> res://new.tscn
			# Standard replace is fine since Godot paths are unique.
			if old_p in content:
				content = content.replace(old_p, new_p)
				changed = true
				
		if changed:
			if _get_undo_redo():
				# Store old state for undo
				var old_content_file = FileAccess.open(actual_path, FileAccess.READ)
				var old_content = old_content_file.get_as_text() if old_content_file else ""
				if old_content_file: old_content_file.close()
				
				_get_undo_redo().add_do_method(executor, "_create_file_undoable", actual_path, content)
				_get_undo_redo().add_undo_method(executor, "_create_file_undoable", actual_path, old_content)
			else:
				var out = FileAccess.open(actual_path, FileAccess.WRITE)
				if out:
					out.store_string(content)
					out.close()
			refactored_files += 1
			
	if _get_undo_redo():
		if not _is_composite():
			_get_undo_redo().commit_action()
			
	EditorInterface.get_resource_filesystem().scan()
	
	var final_msg = "Batch Move Complete! Moved " + str(moved_count) + " files. Refactored connections in " + str(refactored_files) + " files."
	if not error_msgs.is_empty():
		final_msg += "\nErrors:\n- " + "\n- ".join(error_msgs)
		
	_emit_output(final_msg)
