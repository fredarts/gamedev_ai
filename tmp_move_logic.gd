func _format_moves(moves: Dictionary) -> String:
	var text = ""
	for old_path in moves:
		text += old_path + " -> " + moves[old_path] + "\n"
	return text

func _move_files_batch(moves: Dictionary):
	var moved_count = 0
	var error_msgs = []
	var refactored_files = 0
	
	for old_path in moves:
		var new_path = moves[old_path]
		
		if not FileAccess.file_exists(old_path):
			error_msgs.append("Not found: " + old_path)
			continue
			
		var dir_path = new_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)
			
		var err = DirAccess.rename_absolute(old_path, new_path)
		if err != OK:
			error_msgs.append("Failed to move " + old_path.get_file() + " (Code: " + str(err) + ")")
			continue
		
		# Move .import file if it exists
		if FileAccess.file_exists(old_path + ".import"):
			DirAccess.rename_absolute(old_path + ".import", new_path + ".import")
			
		moved_count += 1
		
	# Now refactor text paths in all .gd and .tscn
	var files_to_check = _recursive_find("res://", ".gd")
	files_to_check.append_array(_recursive_find("res://", ".tscn"))
	files_to_check.append_array(_recursive_find("res://", ".tres"))
	
	for file_path in files_to_check:
		# Don't check files that we just moved out of (they don't exist under old names)
		if file_path in moves:
			continue
		
		var changed = false
		var file = FileAccess.open(file_path, FileAccess.READ)
		if not file: continue
		var content = file.get_as_text()
		file.close()
		
		for old_path in moves:
			var new_path = moves[old_path]
			if old_path in content:
				content = content.replace(old_path, new_path)
				changed = true
				
		if changed:
			var out = FileAccess.open(file_path, FileAccess.WRITE)
			if out:
				out.store_string(content)
				out.close()
				refactored_files += 1
				
	EditorInterface.get_resource_filesystem().scan()
	
	var final_msg = "Batch Move Complete! Moved " + str(moved_count) + " files. Refactored connections in " + str(refactored_files) + " files."
	if not error_msgs.is_empty():
		final_msg += "\nErrors:\n- " + "\n- ".join(error_msgs)
		
	tool_output.emit(final_msg)
