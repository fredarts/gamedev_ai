@tool
extends RefCounted
class_name MemoryManager

const MEMORY_DIR = "res://.gamedev_ai/memory/"
const FACTS_FILE = "project_facts.json"

var _memories: Array = []

func _init():
	load_memories()

# --- Public API ---

func load_memories() -> Array:
	_ensure_dir()
	var path = MEMORY_DIR + FACTS_FILE
	if not FileAccess.file_exists(path):
		_memories = []
		return _memories
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		_memories = []
		return _memories
	
	var content = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(content)
	if parsed is Array:
		_memories = parsed
	else:
		_memories = []
	
	return _memories

func save_memory(category: String, content: String, source: String = "ai") -> Dictionary:
	load_memories()  # Reload to avoid overwrites
	
	# Check for duplicates (same category + very similar content)
	for mem in _memories:
		if mem.get("category") == category and mem.get("content") == content:
			return mem  # Already exists
	
	var fact = {
		"id": "fact_" + str(int(Time.get_unix_time_from_system())),
		"category": category,
		"content": content,
		"created": Time.get_datetime_string_from_system(),
		"source": source
	}
	
	_memories.append(fact)
	_save_to_disk()
	return fact

func delete_memory(fact_id: String) -> bool:
	load_memories()
	for i in range(_memories.size()):
		if _memories[i].get("id") == fact_id:
			_memories.remove_at(i)
			_save_to_disk()
			return true
	return false

func get_all_memories_formatted() -> String:
	if _memories.is_empty():
		return ""
	
	var sections = {
		"architecture": [],
		"convention": [],
		"preference": [],
		"bug_fix": [],
		"project_info": []
	}
	
	for mem in _memories:
		var cat = mem.get("category", "project_info")
		if not sections.has(cat):
			cat = "project_info"
		sections[cat].append(mem.get("content", ""))
	
	var result = "=== Project Memory (Persistent) ===\n"
	var has_content = false
	
	var labels = {
		"project_info": "Project Info",
		"architecture": "Architecture Decisions",
		"convention": "Code Conventions",
		"preference": "User Preferences",
		"bug_fix": "Resolved Bugs"
	}
	
	for cat in labels.keys():
		if not sections[cat].is_empty():
			has_content = true
			result += "\n[" + labels[cat] + "]\n"
			for item in sections[cat]:
				result += "- " + item + "\n"
	
	if not has_content:
		return ""
	
	result += "=== End of Project Memory ===\n"
	return result

func list_memories_text() -> String:
	if _memories.is_empty():
		return "No memories stored yet."
	
	var text = "Stored memories (" + str(_memories.size()) + "):\n"
	for mem in _memories:
		text += "- [" + mem.get("id", "?") + "] (" + mem.get("category", "?") + ") " + mem.get("content", "") + "\n"
	return text

# --- Internal ---

func _ensure_dir():
	if not DirAccess.dir_exists_absolute(MEMORY_DIR):
		DirAccess.make_dir_recursive_absolute(MEMORY_DIR)

func _save_to_disk():
	_ensure_dir()
	var path = MEMORY_DIR + FACTS_FILE
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_memories, "\t"))
		file.close()
