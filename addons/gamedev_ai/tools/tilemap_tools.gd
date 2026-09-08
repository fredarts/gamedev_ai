@tool
extends BaseToolHandler
class_name TileMapTools

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"configure_tileset_atlas":
			_configure_tileset_atlas(
				args.get("texture_path", ""),
				args.get("tile_size", [16, 16]),
				args.get("save_path", ""),
				args.get("terrain_set_config", {}),
				args.get("physics_config", {})
			)
			return true
		"build_tilemap_layout":
			_build_tilemap_layout(
				args.get("layer_node_path", "."),
				args.get("layout_matrix", []),
				args.get("source_id", 0)
			)
			return true
		"paint_terrain_cells":
			_paint_terrain_cells(
				args.get("layer_node_path", "."),
				args.get("terrain_set", 0),
				args.get("terrain_id", 0),
				args.get("cell_coordinates", []),
				args.get("ignore_empty_terrains", true)
			)
			return true
		"read_tilemap_layout":
			_read_tilemap_layout(
				args.get("layer_node_path", "."),
				args.get("bounding_box", [])
			)
			return true
		"clear_tilemap_region":
			_clear_tilemap_region(
				args.get("layer_node_path", "."),
				args.get("rect", []),
				args.get("cell_coordinates", [])
			)
			return true
	return false

# --- Tool Implementations ---

func _configure_tileset_atlas(texture_path: String, tile_size: Array, save_path: String, terrain_set_config: Dictionary, physics_config: Dictionary):
	if texture_path.strip_edges() == "":
		_emit_output("[color=red]Error: 'texture_path' cannot be empty.[/color]")
		return
	
	if not ResourceLoader.exists(texture_path):
		_emit_output("[color=red]Error: Texture file not found at '" + texture_path + "'.[/color]")
		return
	
	var texture = load(texture_path)
	if not texture is Texture2D:
		_emit_output("[color=red]Error: Resource at '" + texture_path + "' is not a Texture2D.[/color]")
		return
	
	var tw = 16
	var th = 16
	if tile_size.size() >= 2:
		tw = int(tile_size[0])
		th = int(tile_size[1])
	if tw <= 0 or th <= 0:
		tw = 16
		th = 16
	
	var tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(tw, th)
	
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(tw, th)
	
	var tex_w = texture.get_width()
	var tex_h = texture.get_height()
	var cols = int(tex_w / tw)
	var rows = int(tex_h / th)
	
	var total_tiles = 0
	for r in range(rows):
		for c in range(cols):
			var coords = Vector2i(c, r)
			atlas_source.create_tile(coords)
			total_tiles += 1
	
	# Configure Terrains if provided
	var terrain_configured = false
	if not terrain_set_config.is_empty():
		var terrain_set_idx = int(terrain_set_config.get("terrain_set_index", 0))
		while tile_set.get_terrain_sets_count() <= terrain_set_idx:
			tile_set.add_terrain_set()
		
		var mode_str = String(terrain_set_config.get("mode", "match_corners_and_sides")).to_lower()
		var mode = TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES
		if mode_str == "match_corners":
			mode = TileSet.TERRAIN_MODE_MATCH_CORNERS
		elif mode_str == "match_sides":
			mode = TileSet.TERRAIN_MODE_MATCH_SIDES
		tile_set.set_terrain_set_mode(terrain_set_idx, mode)
		
		var terrains = terrain_set_config.get("terrains", [])
		for t in terrains:
			var t_id = int(t.get("id", 0))
			while tile_set.get_terrains_count(terrain_set_idx) <= t_id:
				tile_set.add_terrain(terrain_set_idx)
			
			if t.has("name"):
				tile_set.set_terrain_name(terrain_set_idx, t_id, String(t.get("name")))
			if t.has("color"):
				var col_arr = t.get("color")
				if col_arr is Array and col_arr.size() >= 3:
					var a = col_arr[3] if col_arr.size() > 3 else 1.0
					tile_set.set_terrain_color(terrain_set_idx, t_id, Color(col_arr[0], col_arr[1], col_arr[2], a))
			
			# Configure peering bits for specified tiles
			var tile_mappings = t.get("tiles", [])
			for tm in tile_mappings:
				var pos = tm.get("pos", [0, 0])
				var coords = Vector2i(int(pos[0]), int(pos[1]))
				if atlas_source.has_tile(coords):
					var tile_data = atlas_source.get_tile_data(coords, 0)
					if tile_data:
						tile_data.terrain_set = terrain_set_idx
						tile_data.terrain = t_id
						var peering = tm.get("peering", {})
						_apply_peering_bits(tile_data, peering, t_id)
		terrain_configured = true
	
	# Configure Physics Layer if provided
	if not physics_config.is_empty():
		tile_set.add_physics_layer()
		var collision_tiles = physics_config.get("collision_tiles", [])
		for ct in collision_tiles:
			var pos = ct.get("pos", [0, 0])
			var coords = Vector2i(int(pos[0]), int(pos[1]))
			if atlas_source.has_tile(coords):
				var tile_data = atlas_source.get_tile_data(coords, 0)
				if tile_data:
					var polygon = PackedVector2Array()
					var half_w = float(tw) / 2.0
					var half_h = float(th) / 2.0
					if ct.has("polygon"):
						for pt in ct.get("polygon"):
							polygon.append(Vector2(pt[0], pt[1]))
					else:
						polygon.append(Vector2(-half_w, -half_h))
						polygon.append(Vector2(half_w, -half_h))
						polygon.append(Vector2(half_w, half_h))
						polygon.append(Vector2(-half_w, half_h))
					tile_data.add_collision_polygon(0)
					tile_data.set_collision_polygon_points(0, 0, polygon)
	
	var source_id = tile_set.add_source(atlas_source)
	
	# Determine save path
	var target_path = save_path.strip_edges()
	if target_path == "":
		var base_name = texture_path.get_file().get_basename()
		target_path = "res://tilesets/tileset_" + base_name + ".tres"
	elif not target_path.begins_with("res://"):
		target_path = "res://" + target_path
	if not target_path.ends_with(".tres"):
		target_path += ".tres"
	
	var dir_path = target_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	var err = ResourceSaver.save(tile_set, target_path)
	if err != OK:
		_emit_output("[color=red]Error saving TileSet resource to '" + target_path + "' (Code: " + str(err) + ").[/color]")
		return
	
	var msg = "🗺️ [b]TileSet Atlas Created Successfully![/b]\n"
	msg += "• [b]Resource Path:[/b] `" + target_path + "`\n"
	msg += "• [b]Texture:[/b] `" + texture_path + "` (" + str(tex_w) + "x" + str(tex_h) + ")\n"
	msg += "• [b]Tile Grid Size:[/b] " + str(tw) + "x" + str(th) + " (" + str(cols) + " cols x " + str(rows) + " rows)\n"
	msg += "• [b]Total Sliced Tiles:[/b] " + str(total_tiles) + "\n"
	msg += "• [b]Source ID:[/b] " + str(source_id) + "\n"
	if terrain_configured:
		msg += "• [b]Terrains:[/b] Configured with autotile peering bits.\n"
	_emit_output(msg)

func _apply_peering_bits(tile_data: TileData, peering: Dictionary, terrain_id: int):
	var neighbor_map = {
		"right": TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
		"bottom_right": TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
		"bottom": TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
		"bottom_left": TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
		"left": TileSet.CELL_NEIGHBOR_LEFT_SIDE,
		"top_left": TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
		"top": TileSet.CELL_NEIGHBOR_TOP_SIDE,
		"top_right": TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER
	}
	for key in peering:
		var side_val = int(peering[key])
		var k_lower = String(key).to_lower()
		if neighbor_map.has(k_lower):
			tile_data.set_terrain_peering_bit(neighbor_map[k_lower], side_val)

func _build_tilemap_layout(layer_node_path: String, layout_matrix: Array, default_source_id: int):
	var target_node = _resolve_layer_node(layer_node_path)
	if not target_node:
		return
	
	if layout_matrix.is_empty():
		_emit_output("[color=yellow]Warning: 'layout_matrix' is empty. No tiles painted.[/color]")
		return
	
	var is_tilemap_layer = target_node.has_method("set_cell")
	if not is_tilemap_layer:
		_emit_output("[color=red]Error: Node '" + target_node.name + "' does not support 'set_cell'. Must be a TileMapLayer or TileMap.[/color]")
		return
	
	var painted_count = 0
	var min_pos = Vector2i(999999, 999999)
	var max_pos = Vector2i(-999999, -999999)
	
	# Execute painting
	for entry in layout_matrix:
		var pos = Vector2i.ZERO
		var atlas = Vector2i.ZERO
		var src_id = default_source_id
		var alt = 0
		
		if entry is Dictionary:
			if entry.has("pos") and entry["pos"] is Array:
				pos = Vector2i(int(entry["pos"][0]), int(entry["pos"][1]))
			elif entry.has("x") and entry.has("y"):
				pos = Vector2i(int(entry["x"]), int(entry["y"]))
				
			if entry.has("atlas") and entry["atlas"] is Array:
				atlas = Vector2i(int(entry["atlas"][0]), int(entry["atlas"][1]))
			elif entry.has("atlas_x") and entry.has("atlas_y"):
				atlas = Vector2i(int(entry["atlas_x"]), int(entry["atlas_y"]))
				
			if entry.has("source_id"):
				src_id = int(entry["source_id"])
			if entry.has("alt"):
				alt = int(entry["alt"])
		elif entry is Array and entry.size() >= 4:
			# Format: [pos_x, pos_y, atlas_x, atlas_y, (opt) src_id, (opt) alt]
			pos = Vector2i(int(entry[0]), int(entry[1]))
			atlas = Vector2i(int(entry[2]), int(entry[3]))
			if entry.size() >= 5:
				src_id = int(entry[4])
			if entry.size() >= 6:
				alt = int(entry[5])
		
		target_node.set_cell(pos, src_id, atlas, alt)
		painted_count += 1
		
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
	
	_save_scene_changes()
	
	var msg = "🧱 [b]TileMap Layout Painted Successfully![/b]\n"
	msg += "• [b]Layer Node:[/b] `" + target_node.name + "` (" + target_node.get_class() + ")\n"
	msg += "• [b]Tiles Placed:[/b] " + str(painted_count) + "\n"
	if painted_count > 0:
		var bounds_w = (max_pos.x - min_pos.x) + 1
		var bounds_h = (max_pos.y - min_pos.y) + 1
		msg += "• [b]Bounding Region:[/b] From (" + str(min_pos.x) + ", " + str(min_pos.y) + ") to (" + str(max_pos.x) + ", " + str(max_pos.y) + ") [" + str(bounds_w) + "x" + str(bounds_h) + "]\n"
	_emit_output(msg)

func _paint_terrain_cells(layer_node_path: String, terrain_set: int, terrain_id: int, cell_coordinates: Array, ignore_empty_terrains: bool):
	var target_node = _resolve_layer_node(layer_node_path)
	if not target_node:
		return
	
	if not target_node.has_method("set_cells_terrain_connect"):
		_emit_output("[color=red]Error: Node '" + target_node.name + "' does not support 'set_cells_terrain_connect'. It must be a TileMapLayer (Godot 4.3+).[/color]")
		return
	
	if cell_coordinates.is_empty():
		_emit_output("[color=yellow]Warning: 'cell_coordinates' is empty. No terrain painted.[/color]")
		return
	
	var cells_array: Array[Vector2i] = []
	for coord in cell_coordinates:
		if coord is Array and coord.size() >= 2:
			cells_array.append(Vector2i(int(coord[0]), int(coord[1])))
		elif coord is Dictionary and coord.has("x") and coord.has("y"):
			cells_array.append(Vector2i(int(coord["x"]), int(coord["y"])))
	
	target_node.set_cells_terrain_connect(cells_array, terrain_set, terrain_id, ignore_empty_terrains)
	_save_scene_changes()
	
	var msg = "🌱 [b]Terrain Autotile Connected Successfully![/b]\n"
	msg += "• [b]Layer Node:[/b] `" + target_node.name + "`\n"
	msg += "• [b]Terrain Set / ID:[/b] Set " + str(terrain_set) + ", Terrain " + str(terrain_id) + "\n"
	msg += "• [b]Connected Cells Count:[/b] " + str(cells_array.size()) + "\n"
	_emit_output(msg)

func _read_tilemap_layout(layer_node_path: String, bounding_box: Array):
	var target_node = _resolve_layer_node(layer_node_path)
	if not target_node:
		return
	
	if not target_node.has_method("get_used_cells"):
		_emit_output("[color=red]Error: Node '" + target_node.name + "' is not a TileMapLayer or TileMap.[/color]")
		return
	
	var used_cells = target_node.get_used_cells()
	if used_cells.is_empty():
		_emit_output("🗺️ [b]TileMapLayer '" + target_node.name + "' is empty[/b] (0 used cells).")
		return
	
	var filter_rect = Rect2i()
	var use_filter = false
	if bounding_box.size() >= 4:
		use_filter = true
		filter_rect = Rect2i(int(bounding_box[0]), int(bounding_box[1]), int(bounding_box[2]), int(bounding_box[3]))
	
	var min_x = 999999
	var min_y = 999999
	var max_x = -999999
	var max_y = -999999
	
	var sampled_cells = []
	var total_matching = 0
	
	for cell in used_cells:
		if use_filter and not filter_rect.has_point(cell):
			continue
		
		total_matching += 1
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
		
		var atlas_coords = target_node.get_cell_atlas_coords(cell)
		var source_id = target_node.get_cell_source_id(cell)
		
		if sampled_cells.size() < 50:
			sampled_cells.append({
				"pos": [cell.x, cell.y],
				"atlas": [atlas_coords.x, atlas_coords.y],
				"source_id": source_id
			})
	
	var msg = "🗺️ [b]TileMapLayer Inspection Report: '" + target_node.name + "'[/b]\n"
	msg += "• [b]Total Cells:[/b] " + str(total_matching) + "\n"
	if total_matching > 0:
		var bw = (max_x - min_x) + 1
		var bh = (max_y - min_y) + 1
		msg += "• [b]Bounding Box:[/b] Min (" + str(min_x) + ", " + str(min_y) + ") | Max (" + str(max_x) + ", " + str(max_y) + ") | Size (" + str(bw) + "x" + str(bh) + ")\n"
		msg += "• [b]Sample Tiles (" + str(sampled_cells.size()) + "):[/b]\n```json\n"
		msg += JSON.stringify(sampled_cells, "  ") + "\n```\n"
	_emit_output(msg)

func _clear_tilemap_region(layer_node_path: String, rect: Array, cell_coordinates: Array):
	var target_node = _resolve_layer_node(layer_node_path)
	if not target_node:
		return
	
	if not target_node.has_method("erase_cell"):
		_emit_output("[color=red]Error: Node '" + target_node.name + "' cannot erase cells.[/color]")
		return
	
	var cleared_count = 0
	if not cell_coordinates.is_empty():
		for coord in cell_coordinates:
			if coord is Array and coord.size() >= 2:
				target_node.erase_cell(Vector2i(int(coord[0]), int(coord[1])))
				cleared_count += 1
	elif rect.size() >= 4:
		var rx = int(rect[0])
		var ry = int(rect[1])
		var rw = int(rect[2])
		var rh = int(rect[3])
		for y in range(ry, ry + rh):
			for x in range(rx, rx + rw):
				target_node.erase_cell(Vector2i(x, y))
				cleared_count += 1
	else:
		if target_node.has_method("clear"):
			cleared_count = target_node.get_used_cells().size()
			target_node.clear()
	
	_save_scene_changes()
	_emit_output("🧹 [b]Cleared " + str(cleared_count) + " tiles from '" + target_node.name + "'.[/b]")

# --- Helpers ---

func _resolve_layer_node(path_or_name: String) -> Node:
	var root: Node = null
	if Engine.is_editor_hint():
		root = EditorInterface.get_edited_scene_root()
	if not root:
		if executor and "_test_scene_root" in executor and executor._test_scene_root:
			root = executor._test_scene_root
	
	if not root:
		_emit_output("[color=red]Error: No active scene root found to resolve TileMapLayer node.[/color]")
		return null
	
	if path_or_name == "." or path_or_name == "":
		return root
	
	if root.has_node(path_or_name):
		return root.get_node(path_or_name)
	
	# Try finding by name in children
	for child in root.get_children():
		if child.name == path_or_name or child.name.to_lower() == path_or_name.to_lower():
			return child
	
	_emit_output("[color=red]Error: Node '" + path_or_name + "' not found in active scene hierarchy.[/color]")
	return null

func _save_scene_changes():
	if Engine.is_editor_hint():
		var root = EditorInterface.get_edited_scene_root()
		if root and not root.scene_file_path.is_empty():
			EditorInterface.save_scene()
