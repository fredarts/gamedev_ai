@tool
extends "res://addons/gamedev_ai/tools/base_tool_handler.gd"

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
		"generate_procedural_dungeon":
			_generate_procedural_dungeon(args)
			return true
		"scaffold_autotile_bitmasks":
			_scaffold_autotile_bitmasks(args)
			return true
		"get_atlas_image":
			_get_atlas_image(args)
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
		_emit_output("[color=red]Error: Node '" + target_node.name + "' does not support 'set_cell'. Must be a TileMapLayer (Godot 4.3+ standard).[/color]")
		return
	
	var painted_count = 0
	var min_pos = Vector2i(999999, 999999)
	var max_pos = Vector2i(-999999, -999999)
	
	var ur = _get_undo_redo()
	var snapshots: Array = []
	if ur:
		_create_undo_action("Build TileMap Layout on " + target_node.name)
		for entry in layout_matrix:
			var p = Vector2i.ZERO
			if entry is Dictionary:
				if entry.has("pos") and entry["pos"] is Array: p = Vector2i(int(entry["pos"][0]), int(entry["pos"][1]))
				elif entry.has("x") and entry.has("y"): p = Vector2i(int(entry["x"]), int(entry["y"]))
			elif entry is Array and entry.size() >= 2:
				p = Vector2i(int(entry[0]), int(entry[1]))
			snapshots.append({
				"pos": p,
				"source_id": target_node.get_cell_source_id(p),
				"atlas_coords": target_node.get_cell_atlas_coords(p),
				"alternative_tile": target_node.get_cell_alternative_tile(p)
			})
		ur.add_undo_method(self, "_restore_tilemap_cells", target_node, snapshots)

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
		if ur:
			ur.add_do_method(target_node, "set_cell", pos, src_id, atlas, alt)
		painted_count += 1
		
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
	
	if ur:
		_commit_undo_action()
	else:
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
	
	var ur = _get_undo_redo()
	if ur:
		_create_undo_action("Paint Terrain Cells on " + target_node.name)
		var snapshots: Array = []
		for c in cells_array:
			snapshots.append({
				"pos": c,
				"source_id": target_node.get_cell_source_id(c),
				"atlas_coords": target_node.get_cell_atlas_coords(c),
				"alternative_tile": target_node.get_cell_alternative_tile(c)
			})
		ur.add_undo_method(self, "_restore_tilemap_cells", target_node, snapshots)
		ur.add_do_method(target_node, "set_cells_terrain_connect", cells_array, terrain_set, terrain_id, ignore_empty_terrains)
	
	target_node.set_cells_terrain_connect(cells_array, terrain_set, terrain_id, ignore_empty_terrains)
	
	if ur:
		_commit_undo_action()
	else:
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
		_emit_output("[color=red]Error: Node '" + target_node.name + "' is not a TileMapLayer (Godot 4.3+ standard).[/color]")
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
	
	var ur = _get_undo_redo()
	var cells_to_erase: Array[Vector2i] = []
	if not cell_coordinates.is_empty():
		for coord in cell_coordinates:
			if coord is Array and coord.size() >= 2:
				cells_to_erase.append(Vector2i(int(coord[0]), int(coord[1])))
	elif rect.size() >= 4:
		var rx = int(rect[0])
		var ry = int(rect[1])
		var rw = int(rect[2])
		var rh = int(rect[3])
		for y in range(ry, ry + rh):
			for x in range(rx, rx + rw):
				cells_to_erase.append(Vector2i(x, y))
	else:
		if target_node.has_method("get_used_cells"):
			cells_to_erase = target_node.get_used_cells()

	var snapshots: Array = []
	if ur:
		_create_undo_action("Clear TileMap Region on " + target_node.name)
		for p in cells_to_erase:
			snapshots.append({
				"pos": p,
				"source_id": target_node.get_cell_source_id(p),
				"atlas_coords": target_node.get_cell_atlas_coords(p),
				"alternative_tile": target_node.get_cell_alternative_tile(p)
			})
		ur.add_undo_method(self, "_restore_tilemap_cells", target_node, snapshots)

	var cleared_count = 0
	for p in cells_to_erase:
		target_node.erase_cell(p)
		if ur:
			ur.add_do_method(target_node, "erase_cell", p)
		cleared_count += 1
	
	if ur:
		_commit_undo_action()
	else:
		_save_scene_changes()
	_emit_output("🧹 [b]Cleared " + str(cleared_count) + " tiles from '" + target_node.name + "'.[/b]")

func _restore_tilemap_cells(layer_node: Node, cell_snapshots: Array):
	if not is_instance_valid(layer_node) or not layer_node.has_method("set_cell"):
		return
	for snap in cell_snapshots:
		var p = snap.get("pos", Vector2i.ZERO)
		var sid = int(snap.get("source_id", -1))
		var atlas = snap.get("atlas_coords", Vector2i(-1, -1))
		var alt = int(snap.get("alternative_tile", 0))
		if sid != -1:
			layer_node.set_cell(p, sid, atlas, alt)
		else:
			layer_node.erase_cell(p)
	_save_scene_changes()

# --- Procedural Dungeon Generator ---

func _generate_procedural_dungeon(args: Dictionary):
	var target_node = _resolve_layer_node(args.get("layer_node_path", "."))
	if not target_node:
		return
	
	var DungeonGen = load("res://addons/gamedev_ai/tools/dungeon_generator.gd")
	if not DungeonGen:
		_emit_output("Error: DungeonGenerator script not found at res://addons/gamedev_ai/tools/dungeon_generator.gd")
		return
		
	var algo: String = str(args.get("algorithm", "bsp")).to_lower()
	var width: int = int(args.get("width", 40))
	var height: int = int(args.get("height", 30))
	var min_size: int = int(args.get("room_min_size", 5))
	var max_size: int = int(args.get("room_max_size", 10))
	var max_rooms: int = int(args.get("max_rooms", 8))
	var seed_val: int = int(args.get("seed", -1))
	var src_id: int = int(args.get("source_id", 0))
	
	var floor_coords = args.get("floor_tile", [0, 0])
	var wall_coords = args.get("wall_tile", [1, 0])
	var floor_atlas = Vector2i(int(floor_coords[0]), int(floor_coords[1])) if floor_coords is Array and floor_coords.size() >= 2 else Vector2i(0, 0)
	var wall_atlas = Vector2i(int(wall_coords[0]), int(wall_coords[1])) if wall_coords is Array and wall_coords.size() >= 2 else Vector2i(1, 0)
	
	var use_terrain: bool = bool(args.get("use_terrain_autotile", false))
	var terrain_set: int = int(args.get("terrain_set", 0))
	var terrain_id: int = int(args.get("terrain_id", 0))
	
	var dungeon_data: Dictionary = {}
	match algo:
		"bsp":
			dungeon_data = DungeonGen.generate_bsp(width, height, min_size, max_rooms, seed_val)
		"rooms_and_corridors", "roguelike":
			dungeon_data = DungeonGen.generate_rooms_and_corridors(width, height, max_rooms, min_size, max_size, seed_val)
		"cellular", "caves":
			var fill_prob = float(args.get("fill_prob", 0.46))
			var iters = int(args.get("iterations", 4))
			dungeon_data = DungeonGen.generate_cellular(width, height, fill_prob, iters, seed_val)
		"drunkard_walk", "tunnels":
			var floor_ratio = float(args.get("desired_floor_ratio", 0.35))
			dungeon_data = DungeonGen.generate_drunkard_walk(width, height, floor_ratio, 5000, seed_val)
		_:
			_emit_output("Error: Unknown algorithm '" + algo + "'. Valid algorithms: bsp, rooms_and_corridors, cellular, drunkard_walk")
			return
			
	var grid: Array = dungeon_data.get("grid", [])
	var floor_cells: Array[Vector2i] = []
	var wall_cells: Array[Vector2i] = []
	
	for y in range(height):
		for x in range(width):
			var val = grid[y][x]
			if val == DungeonGen.TILE_FLOOR:
				floor_cells.append(Vector2i(x, y))
			elif val == DungeonGen.TILE_WALL:
				wall_cells.append(Vector2i(x, y))
				
	# Capture previous cells for UndoRedo
	var ur = _get_undo_redo()
	if ur:
		_create_undo_action("Generate Procedural Dungeon (" + algo + ") on " + target_node.name)
		var snapshots: Array = []
		for y in range(height):
			for x in range(width):
				var p = Vector2i(x, y)
				snapshots.append({
					"pos": p,
					"source_id": target_node.get_cell_source_id(p),
					"atlas_coords": target_node.get_cell_atlas_coords(p),
					"alternative_tile": target_node.get_cell_alternative_tile(p)
				})
		ur.add_undo_method(self, "_restore_tilemap_cells", target_node, snapshots)
		
	if use_terrain and target_node.has_method("set_cells_terrain_connect"):
		target_node.set_cells_terrain_connect(floor_cells, terrain_set, terrain_id, true)
		if ur:
			ur.add_do_method(target_node, "set_cells_terrain_connect", floor_cells, terrain_set, terrain_id, true)
	else:
		for p in floor_cells:
			target_node.set_cell(p, src_id, floor_atlas)
			if ur: ur.add_do_method(target_node, "set_cell", p, src_id, floor_atlas)
		for p in wall_cells:
			target_node.set_cell(p, src_id, wall_atlas)
			if ur: ur.add_do_method(target_node, "set_cell", p, src_id, wall_atlas)
			
	if ur:
		_commit_undo_action()
	else:
		_save_scene_changes()
		
	var report = {
		"status": "success",
		"algorithm": algo,
		"dimensions": {"width": width, "height": height},
		"floor_cells_count": floor_cells.size(),
		"wall_cells_count": wall_cells.size(),
		"player_spawn": dungeon_data.get("player_spawn", [0, 0]),
		"exit_stairs": dungeon_data.get("exit_stairs", [0, 0]),
		"rooms": dungeon_data.get("rooms", []),
		"target_layer": target_node.name
	}
	_emit_output(JSON.stringify(report, "\t"))

# --- Autotile Bitmask Templates ---

func _scaffold_autotile_bitmasks(args: Dictionary):
	var tileset_path: String = args.get("tileset_path", "")
	if tileset_path.strip_edges().is_empty():
		_emit_output("Error: 'tileset_path' cannot be empty.")
		return
	if not ResourceLoader.exists(tileset_path):
		_emit_output("Error: TileSet resource not found at " + tileset_path)
		return
	var ts = load(tileset_path)
	if not ts is TileSet:
		_emit_output("Error: Resource at " + tileset_path + " is not a TileSet.")
		return
		
	var source_id: int = int(args.get("source_id", 0))
	if not ts.has_source(source_id) or not ts.get_source(source_id) is TileSetAtlasSource:
		_emit_output("Error: Source ID " + str(source_id) + " is not a valid TileSetAtlasSource in " + tileset_path)
		return
		
	var src: TileSetAtlasSource = ts.get_source(source_id)
	var terrain_set: int = int(args.get("terrain_set", 0))
	var terrain_id: int = int(args.get("terrain_id", 0))
	var template: String = str(args.get("template", "simple_box")).to_lower().strip_edges()
	var offset_col: int = int(args.get("offset_col", 0))
	var offset_row: int = int(args.get("offset_row", 0))
	
	while ts.get_terrain_sets_count() <= terrain_set:
		ts.add_terrain_set()
	while ts.get_terrains_count(terrain_set) <= terrain_id:
		ts.add_terrain(terrain_set)
		
	var template_map: Array[Dictionary] = []
	match template:
		"simple_box":
			template_map = [
				{"col": 0, "row": 0, "bits": [0, 1, 2]},
				{"col": 1, "row": 0, "bits": [0, 1, 2, 3, 4]},
				{"col": 2, "row": 0, "bits": [2, 3, 4]},
				{"col": 0, "row": 1, "bits": [6, 7, 0, 1, 2]},
				{"col": 1, "row": 1, "bits": [0, 1, 2, 3, 4, 5, 6, 7]},
				{"col": 2, "row": 1, "bits": [6, 5, 4, 3, 2]},
				{"col": 0, "row": 2, "bits": [6, 7, 0]},
				{"col": 1, "row": 2, "bits": [4, 5, 6, 7, 0]},
				{"col": 2, "row": 2, "bits": [6, 5, 4]},
			]
		"kenney_3x3_minimal":
			template_map = [
				{"col": 0, "row": 0, "bits": [0, 1, 2]},
				{"col": 1, "row": 0, "bits": [0, 1, 2, 3, 4]},
				{"col": 2, "row": 0, "bits": [2, 3, 4]},
				{"col": 3, "row": 0, "bits": [2]},
				{"col": 0, "row": 1, "bits": [6, 7, 0, 1, 2]},
				{"col": 1, "row": 1, "bits": [0, 1, 2, 3, 4, 5, 6, 7]},
				{"col": 2, "row": 1, "bits": [6, 5, 4, 3, 2]},
				{"col": 3, "row": 1, "bits": [6, 2]},
				{"col": 0, "row": 2, "bits": [6, 7, 0]},
				{"col": 1, "row": 2, "bits": [4, 5, 6, 7, 0]},
				{"col": 2, "row": 2, "bits": [6, 5, 4]},
				{"col": 3, "row": 2, "bits": [6]},
				{"col": 0, "row": 3, "bits": [0]},
				{"col": 1, "row": 3, "bits": [4, 0]},
				{"col": 2, "row": 3, "bits": [4]},
				{"col": 3, "row": 3, "bits": []},
			]
		"rpgmaker_47":
			template_map = [
				{"col": 0, "row": 0, "bits": [0, 1, 2]},
				{"col": 1, "row": 0, "bits": [0, 1, 2, 3, 4]},
				{"col": 2, "row": 0, "bits": [2, 3, 4]},
				{"col": 0, "row": 1, "bits": [6, 7, 0, 1, 2]},
				{"col": 1, "row": 1, "bits": [0, 1, 2, 3, 4, 5, 6, 7]},
				{"col": 2, "row": 1, "bits": [6, 5, 4, 3, 2]},
				{"col": 0, "row": 2, "bits": [6, 7, 0]},
				{"col": 1, "row": 2, "bits": [4, 5, 6, 7, 0]},
				{"col": 2, "row": 2, "bits": [6, 5, 4]},
				{"col": 3, "row": 0, "bits": [2]},
				{"col": 3, "row": 1, "bits": [6, 2]},
				{"col": 3, "row": 2, "bits": [6]},
				{"col": 0, "row": 3, "bits": [0]},
				{"col": 1, "row": 3, "bits": [4, 0]},
				{"col": 2, "row": 3, "bits": [4]},
				{"col": 3, "row": 3, "bits": []},
				{"col": 4, "row": 0, "bits": [0, 1, 2, 3, 4, 6, 7]},
				{"col": 5, "row": 0, "bits": [0, 1, 2, 3, 4, 5, 6]},
				{"col": 4, "row": 1, "bits": [0, 2, 4, 5, 6, 7]},
				{"col": 5, "row": 1, "bits": [0, 1, 2, 4, 5, 6]},
			]
		_:
			_emit_output("Error: Unknown template '" + template + "'. Valid templates: simple_box, kenney_3x3_minimal, rpgmaker_47")
			return
			
	var count = 0
	for entry in template_map:
		var c = int(entry.get("col", 0)) + offset_col
		var r = int(entry.get("row", 0)) + offset_row
		var coords = Vector2i(c, r)
		if not src.has_tile(coords):
			src.create_tile(coords)
		var tile_data: TileData = src.get_tile_data(coords, 0)
		if tile_data:
			tile_data.set_terrain_set(terrain_set)
			tile_data.set_terrain(terrain_id)
			for b in range(8):
				tile_data.set_terrain_peering_bit(b, -1)
			for b in entry.get("bits", []):
				tile_data.set_terrain_peering_bit(int(b), terrain_id)
			count += 1
			
	var err = ResourceSaver.save(ts, tileset_path)
	if err != OK:
		_emit_output("Error: Failed to save TileSet at " + tileset_path + " (Code: " + str(err) + ")")
		return
		
	_emit_output(JSON.stringify({
		"status": "success",
		"tileset_path": tileset_path,
		"template": template,
		"terrain_set": terrain_set,
		"terrain_id": terrain_id,
		"tiles_configured": count,
		"offset": {"col": offset_col, "row": offset_row}
	}, "\t"))

# --- Spritesheet / Atlas Visual Inspection ---

func _get_atlas_image(args: Dictionary):
	var tex: Texture2D = null
	var texture_path: String = args.get("texture_path", "")
	var tileset_path: String = args.get("tileset_path", "")
	var source_id: int = int(args.get("source_id", 0))
	
	if not texture_path.is_empty():
		if ResourceLoader.exists(texture_path):
			tex = load(texture_path)
	elif not tileset_path.is_empty():
		if ResourceLoader.exists(tileset_path):
			var ts = load(tileset_path)
			if ts is TileSet and ts.has_source(source_id):
				var src = ts.get_source(source_id)
				if src is TileSetAtlasSource:
					tex = src.texture
					
	if not tex:
		_emit_output("Error: Could not load Texture2D from texture_path or TileSet source.")
		return
		
	var img: Image = tex.get_image()
	if not img:
		_emit_output("Error: Could not retrieve image data from texture.")
		return
		
	if img.is_compressed():
		img.decompress()
		
	var orig_w = img.get_width()
	var orig_h = img.get_height()
	var tile_w = int(args.get("tile_width", 16))
	var tile_h = int(args.get("tile_height", 16))
	var max_size = int(args.get("max_size", 512))
	var draw_grid = bool(args.get("grid_overlay", true))
	
	var processed_img: Image = img.duplicate()
	if draw_grid and tile_w > 0 and tile_h > 0:
		var cols = orig_w / tile_w
		var rows = orig_h / tile_h
		var grid_color = Color(1.0, 0.2, 0.2, 0.5)
		for c in range(cols + 1):
			var gx = min(c * tile_w, orig_w - 1)
			for y in range(orig_h):
				processed_img.set_pixel(gx, y, grid_color)
		for r in range(rows + 1):
			var gy = min(r * tile_h, orig_h - 1)
			for x in range(orig_w):
				processed_img.set_pixel(x, gy, grid_color)

	if max_size > 0:
		var longest = max(orig_w, orig_h)
		if longest > max_size:
			var scale = float(max_size) / float(longest)
			var nw = max(1, int(orig_w * scale))
			var nh = max(1, int(orig_h * scale))
			processed_img.resize(nw, nh, Image.INTERPOLATE_LANCZOS)
			
	var png_buffer = processed_img.save_png_to_buffer()
	var b64_str = Marshalls.raw_to_base64(png_buffer)
	
	_emit_output(JSON.stringify({
		"status": "success",
		"width": processed_img.get_width(),
		"height": processed_img.get_height(),
		"original_width": orig_w,
		"original_height": orig_h,
		"tile_size": {"w": tile_w, "h": tile_h},
		"cols": int(orig_w / tile_w) if tile_w > 0 else 1,
		"rows": int(orig_h / tile_h) if tile_h > 0 else 1,
		"format": "image/png;base64",
		"image_base64": b64_str
	}, "\t"))

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
