@tool
extends RefCounted

signal db_output(output: String)

var http_request: HTTPRequest
var parent_node: Node
var db_path = "res://.gamedev_ai/vector_db.json"
var embeddings_db = [] # Array of {"path": str, "chunk_name": str, "text": str, "embedding": Array, "hash": str}

var _indexing_queue: Array = []
var _is_indexing: bool = false
var _search_pending_query: String = ""
var _is_searching: bool = false

var _backoff_time: float = 5.0
var _max_backoff: float = 60.0

# Incremental indexing state
var _old_db_by_path: Dictionary = {}
var _old_db_by_hash: Dictionary = {}
var _new_db: Array = []
var _stats_retained: int = 0
var _stats_moved: int = 0
var _stats_queued: int = 0

func setup(node: Node):
	parent_node = node
	http_request = HTTPRequest.new()
	http_request.use_threads = true
	parent_node.add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	_load_db()

func _load_db():
	var file = FileAccess.open(db_path, FileAccess.READ)
	if file:
		var json = JSON.parse_string(file.get_as_text())
		if json and typeof(json) == TYPE_ARRAY:
			embeddings_db = json

func _save_db():
	var dir_path = db_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
		
	var file = FileAccess.open(db_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(embeddings_db))

func _get_active_preset() -> Dictionary:
	var settings = EditorInterface.get_editor_settings()
	if not settings.has_setting("gamedev_ai/presets"): return {}
	var presets = settings.get_setting("gamedev_ai/presets")
	var active = settings.get_setting("gamedev_ai/active_preset")
	if presets.has(active): return presets[active]
	if presets.size() > 0: return presets[presets.keys()[0]]
	return {}

func _prepare_request(text: String) -> Dictionary:
	var preset = _get_active_preset()
	var provider = preset.get("provider", 0)
	var api_key = preset.get("api_key", "")
	var base_url = preset.get("base_url", "")
	
	var url = ""
	var headers = ["Content-Type: application/json"]
	var body = ""
	
	if provider == 0: # Gemini / Vertex
		if base_url != "":
			url = base_url
			if not url.ends_with("/"): url += "/"
			url += "v1beta/models/gemini-embedding-001:embedContent"
		else:
			url = "http://127.0.0.1:8000/v1beta/models/gemini-embedding-001:embedContent"
			
		body = JSON.stringify({
			"model": "models/gemini-embedding-001",
			"content": {
				"parts": [{"text": text}]
			}
		})
	else: # OpenAI / OpenRouter
		if base_url != "":
			url = base_url
			if not url.ends_with("/"): url += "/"
			url += "v1/embeddings"
		else:
			url = "https://api.openai.com/v1/embeddings"
			
		if api_key != "":
			headers.append("Authorization: Bearer " + api_key)
			
		body = JSON.stringify({
			"model": "text-embedding-3-small",
			"input": text
		})
		
	return {"url": url, "headers": headers, "body": body, "provider": provider}

# ----------------- DRY-RUN SCAN (no API calls) -----------------
func scan_changes() -> Dictionary:
	var old_by_path: Dictionary = {}
	var old_by_hash: Dictionary = {}
	for entry in embeddings_db:
		var p = entry.get("path", "")
		var h = entry.get("hash", "")
		if p != "": old_by_path[p] = entry
		if h != "": old_by_hash[h] = entry
	
	var retained: Array = []
	var moved: Array = [] # Array of {"old": old_path, "new": new_path}
	var new_or_modified: Array = []
	var all_current_paths: Dictionary = {}
	
	_scan_changes_dir("res://", old_by_path, old_by_hash, retained, moved, new_or_modified, all_current_paths)
	
	# Detect deleted files (in old DB but not found on disk)
	var deleted: Array = []
	for old_path in old_by_path.keys():
		if not all_current_paths.has(old_path):
			# Check if it was detected as a move (old path consumed)
			var dominated = false
			for m in moved:
				if m["old"] == old_path:
					dominated = true
					break
			if not dominated:
				deleted.append(old_path)
	
	return {
		"retained": retained,
		"moved": moved,
		"new_or_modified": new_or_modified,
		"deleted": deleted
	}

func _scan_changes_dir(dir_path: String, old_by_path: Dictionary, old_by_hash: Dictionary, retained: Array, moved: Array, new_or_modified: Array, all_current_paths: Dictionary):
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("."):
				pass
			elif dir.current_is_dir() and not file_name in ["addons", ".godot", "export"]:
				_scan_changes_dir(dir_path + "/" + file_name if dir_path != "res://" else dir_path + file_name, old_by_path, old_by_hash, retained, moved, new_or_modified, all_current_paths)
			elif file_name.ends_with(".gd"):
				var full_path = dir_path + "/" + file_name if dir_path != "res://" else dir_path + file_name
				_classify_file(full_path, old_by_path, old_by_hash, retained, moved, new_or_modified, all_current_paths)
			file_name = dir.get_next()

func _classify_file(path: String, old_by_path: Dictionary, old_by_hash: Dictionary, retained: Array, moved: Array, new_or_modified: Array, all_current_paths: Dictionary):
	var file_hash = FileAccess.get_md5(path)
	if file_hash == "": return
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return
	var content = file.get_as_text()
	if content.strip_edges() == "": return
	
	all_current_paths[path] = true
	
	# 1) Same path + same hash => retained
	if old_by_path.has(path):
		if old_by_path[path].get("hash", "") == file_hash:
			retained.append(path)
			return
	
	# 2) Different path, same hash => moved/renamed
	if old_by_hash.has(file_hash):
		var old_entry = old_by_hash[file_hash]
		moved.append({"old": old_entry.get("path", ""), "new": path})
		return
	
	# 3) New or modified
	new_or_modified.append(path)

# ----------------- SEARCH -----------------
func search(query: String, top_k: int = 5):
	if _is_searching or _is_indexing:
		call_deferred("emit_signal", "db_output", "Error: VectorDB is currently busy.")
		return
		
	if embeddings_db.is_empty():
		call_deferred("emit_signal", "db_output", "Database is empty. Please run index_codebase first.")
		return
		
	_is_searching = true
	_search_pending_query = query
	
	var req = _prepare_request(query)
	var err = http_request.request(req["url"], req["headers"], HTTPClient.METHOD_POST, req["body"])
	if err != OK:
		_is_searching = false
		call_deferred("emit_signal", "db_output", "Error sending embedding request.")

# ----------------- INDEXING -----------------
func index_project():
	if _is_searching or _is_indexing:
		call_deferred("emit_signal", "db_output", "Error: VectorDB is currently busy.")
		return
		
	_is_indexing = true
	_indexing_queue.clear()
	_new_db.clear()
	_old_db_by_path.clear()
	_old_db_by_hash.clear()
	_stats_retained = 0
	_stats_moved = 0
	_stats_queued = 0
	_backoff_time = 5.0
	
	# Build lookup maps from the existing database
	for entry in embeddings_db:
		var p = entry.get("path", "")
		var h = entry.get("hash", "")
		if p != "":
			_old_db_by_path[p] = entry
		if h != "":
			_old_db_by_hash[h] = entry
	
	_scan_dir_for_indexing("res://")
	
	var total_scanned = _stats_retained + _stats_moved + _indexing_queue.size()
	call_deferred("emit_signal", "db_output", "Scan complete: %d files found. %d retained, %d moved/renamed, %d to embed." % [total_scanned, _stats_retained, _stats_moved, _indexing_queue.size()])
	
	if _indexing_queue.is_empty():
		# Nothing new to embed; finalize immediately
		embeddings_db = _new_db
		_save_db()
		_is_indexing = false
		call_deferred("emit_signal", "db_output", "Incremental index complete! No new embeddings needed.")
		return
		
	_process_next_index_queue()

func _scan_dir_for_indexing(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("."):
				pass # Ignore hidden
			elif dir.current_is_dir() and not file_name in ["addons", ".godot", "export"]:
				_scan_dir_for_indexing(dir_path + "/" + file_name if dir_path != "res://" else dir_path + file_name)
			elif file_name.ends_with(".gd"):
				var full_path = dir_path + "/" + file_name if dir_path != "res://" else dir_path + file_name
				_chunk_and_queue_script(full_path)
			file_name = dir.get_next()

func _chunk_and_queue_script(path: String):
	var file_hash = FileAccess.get_md5(path)
	if file_hash == "": return
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return
	var content = file.get_as_text()
	if content.strip_edges() == "": return
	
	# --- Incremental check ---
	# 1) Same path + same hash => file unchanged, retain it
	if _old_db_by_path.has(path):
		var old_entry = _old_db_by_path[path]
		if old_entry.get("hash", "") == file_hash:
			_new_db.append(old_entry)
			_stats_retained += 1
			return
	
	# 2) Different path but same hash => file was moved or renamed
	if _old_db_by_hash.has(file_hash):
		var old_entry = _old_db_by_hash[file_hash].duplicate()
		old_entry["path"] = path # Update to new path
		_new_db.append(old_entry)
		_stats_moved += 1
		return
	
	# 3) Truly new or modified => queue for embedding
	_indexing_queue.append({
		"path": path,
		"chunk_name": "Full Script",
		"text": content.substr(0, 8000), # Safety limit
		"hash": file_hash
	})

func _process_next_index_queue():
	if _indexing_queue.is_empty():
		embeddings_db = _new_db
		_is_indexing = false
		_save_db()
		call_deferred("emit_signal", "db_output", "Incremental index complete! %d retained, %d moved, %d newly embedded. Total: %d files." % [_stats_retained, _stats_moved, _stats_queued, embeddings_db.size()])
		return
		
	var item = _indexing_queue[0]
	var req = _prepare_request("File mapping: " + item["path"] + "\n\n" + item["text"])
	var err = http_request.request(req["url"], req["headers"], HTTPClient.METHOD_POST, req["body"])
	
	if err != OK:
		# Just skip bad files
		_indexing_queue.pop_front()
		call_deferred("_process_next_index_queue")

# ----------------- RESPONSE HANDLER -----------------
func _on_http_request_completed(_result, response_code, _headers, body):
	if not _is_searching and not _is_indexing:
		return
		
	var payload = body.get_string_from_utf8()
	var json = JSON.parse_string(payload)
	
	var vector = []
	
	if response_code == 200 and json:
		# Detect standard Gemini format
		if json.has("embedding") and json["embedding"].has("values"):
			vector = json["embedding"]["values"]
		# Detect OpenAI format
		elif json.has("data") and typeof(json["data"]) == TYPE_ARRAY and json["data"].size() > 0:
			vector = json["data"][0].get("embedding", [])
	else:
		print("VectorDB API Error ", response_code, ": ", payload)
	
	if _is_searching:
		_is_searching = false
		if vector.is_empty():
			call_deferred("emit_signal", "db_output", "Error: Failed to embed search query. Status: " + str(response_code))
			return
		_execute_search_similarity(vector)
		
	elif _is_indexing:
		if response_code == 429: # Rate limit
			print("Rate limit hit during indexing. Waiting " + str(_backoff_time) + " seconds...")
			# DON'T pop queue, just wait and retry
			var timer = Engine.get_main_loop().create_timer(_backoff_time)
			timer.timeout.connect(_process_next_index_queue)
			
			_backoff_time = min(_backoff_time * 2.0, _max_backoff)
			return
			
		_backoff_time = 5.0 # Reset on success
		var item = _indexing_queue.pop_front()
		if not vector.is_empty():
			item["embedding"] = vector
			_new_db.append(item)
			_stats_queued += 1
			
		# Small delay to prevent hitting RPM limits on free tiers
		var timer = Engine.get_main_loop().create_timer(1.0)
		timer.timeout.connect(_process_next_index_queue)

func _execute_search_similarity(query_vector: Array):
	var results = []
	for db_item in embeddings_db:
		if db_item.has("embedding"):
			var sim = _cosine_similarity(query_vector, db_item["embedding"])
			results.append({
				"sim": sim,
				"path": db_item["path"],
				"text": db_item["text"]
			})
			
	# Sort descending
	results.sort_custom(func(a, b): return a["sim"] > b["sim"])
	
	var top_k = 5
	var out_text = "Top Semantic Search Results for: '" + _search_pending_query + "'\n\n"
	
	for i in range(min(top_k, results.size())):
		var r = results[i]
		out_text += "====== " + r["path"] + " (Match: " + str(snapped(r["sim"] * 100, 0.1)) + "%) ======\n"
		var snippet = r["text"].substr(0, 500)
		if r["text"].length() > 500: snippet += "... (truncated)"
		out_text += snippet + "\n\n"
		
	call_deferred("emit_signal", "db_output", out_text)

func _cosine_similarity(vec1: Array, vec2: Array) -> float:
	var dot = 0.0
	var norm1 = 0.0
	var norm2 = 0.0
	var limit = min(vec1.size(), vec2.size())
	for i in range(limit):
		var v1 = float(vec1[i])
		var v2 = float(vec2[i])
		dot += v1 * v2
		norm1 += v1 * v1
		norm2 += v2 * v2
		
	if norm1 == 0.0 or norm2 == 0.0: return 0.0
	return dot / (sqrt(norm1) * sqrt(norm2))
