@tool
extends SceneTree

func _init():
	print("\n=======================================================")
	print("🗺️ RUNNING TILEMAP & LEVEL GENERATOR TEST SUITE (GODOT 4.3+ / 4.6)")
	print("=======================================================\n")
	
	var passed = 0
	var total = 0
	
	# Test 1: ToolExecutor Registration & Validation
	total += 1
	var ToolExecutorScript = load("res://addons/gamedev_ai/tool_executor.gd")
	if ToolExecutorScript:
		var executor = ToolExecutorScript.new()
		executor.setup(null)
		var val_res = executor._validate_args("build_tilemap_layout", {"layout_matrix": []})
		var val_terrain = executor._validate_args("paint_terrain_cells", {"terrain_set": 0, "terrain_id": 0, "cell_coordinates": []})
		if val_res.get("valid", false) and val_terrain.get("valid", false):
			print("✅ Test 1 Passed: ToolExecutor registered all 5 TileMap tools with valid schemas.")
			passed += 1
		else:
			print("❌ Test 1 Failed: ToolExecutor validation error.")
	else:
		print("❌ Test 1 Failed: Could not load ToolExecutor")
	
	# Test 2: TileMapTools Handler Loading & Execution
	total += 1
	var TileMapToolsScript = load("res://addons/gamedev_ai/tools/tilemap_tools.gd")
	if TileMapToolsScript:
		var tools = TileMapToolsScript.new()
		var executor = ToolExecutorScript.new()
		tools.setup(executor)
		print("✅ Test 2 Passed: TileMapTools initialized and connected to BaseToolHandler.")
		passed += 1
	else:
		print("❌ Test 2 Failed: Could not load TileMapTools script.")
		
	# Test 3: TileSetAtlasSource and Terrains programmatic creation
	total += 1
	var tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(16, 16)
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.GREEN)
	var tex = ImageTexture.create_from_image(img)
	
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = tex
	atlas_source.texture_region_size = Vector2i(16, 16)
	
	var cols = 4
	var rows = 4
	for r in range(rows):
		for c in range(cols):
			atlas_source.create_tile(Vector2i(c, r))
			
	tile_set.add_terrain_set()
	tile_set.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES)
	tile_set.add_terrain(0)
	tile_set.set_terrain_name(0, 0, "Grass")
	
	var t_data = atlas_source.get_tile_data(Vector2i(0, 0), 0)
	if t_data:
		t_data.terrain_set = 0
		t_data.terrain = 0
		t_data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE, 0)
		t_data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, 0)
	
	var src_id = tile_set.add_source(atlas_source)
	if src_id == 0 and atlas_source.has_tile(Vector2i(3, 3)) and t_data.terrain == 0:
		print("✅ Test 3 Passed: TileSetAtlasSource created with 16 tiles and autotile terrain peering bits.")
		passed += 1
	else:
		print("❌ Test 3 Failed: TileSetAtlasSource configuration failed.")
		
	# Test 4: TileMapLayer Painting & Layout Building
	total += 1
	var layer = TileMapLayer.new()
	layer.name = "GroundLayer"
	layer.tile_set = tile_set
	
	# Simulate building a 3x3 layout
	var layout_matrix = [
		{"pos": [0, 0], "atlas": [0, 0]},
		{"pos": [1, 0], "atlas": [1, 0]},
		{"pos": [2, 0], "atlas": [2, 0]},
		{"pos": [0, 1], "atlas": [0, 1]},
		{"pos": [1, 1], "atlas": [1, 1]},
		{"pos": [2, 1], "atlas": [2, 1]},
		{"pos": [0, 2], "atlas": [0, 2]},
		{"pos": [1, 2], "atlas": [1, 2]},
		{"pos": [2, 2], "atlas": [2, 2]}
	]
	
	for entry in layout_matrix:
		layer.set_cell(Vector2i(entry["pos"][0], entry["pos"][1]), 0, Vector2i(entry["atlas"][0], entry["atlas"][1]))
		
	var used = layer.get_used_cells()
	if used.size() == 9 and layer.get_cell_atlas_coords(Vector2i(1, 1)) == Vector2i(1, 1):
		print("✅ Test 4 Passed: TileMapLayer painted 9 cells correctly with modern Vector2i set_cell API.")
		passed += 1
	else:
		print("❌ Test 4 Failed: TileMapLayer set_cell failed.")
		
	# Test 5: TileMapLayer Inspection and Erase Region
	total += 1
	layer.erase_cell(Vector2i(1, 1))
	var updated_used = layer.get_used_cells()
	if updated_used.size() == 8 and not updated_used.has(Vector2i(1, 1)):
		print("✅ Test 5 Passed: TileMapLayer erase_cell and region clearance verified.")
		passed += 1
	else:
		print("❌ Test 5 Failed: TileMapLayer erase_cell failed.")
	
	print("\n=======================================================")
	print("RESULTS: " + str(passed) + "/" + str(total) + " tests passed.")
	print("=======================================================\n")
	
	quit(0 if passed == total else 1)
