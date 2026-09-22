@tool
extends SceneTree

func _init():
	print("==================================================")
	print("🧪 RUNNING PROCEDURAL DUNGEON & AUTOTILE TEST SUITE")
	print("==================================================")
	
	var passed = 0
	var failed = 0
	
	var DungeonGen = load("res://addons/gamedev_ai/tools/dungeon_generator.gd")
	var ToolExecutor = load("res://addons/gamedev_ai/tool_executor.gd")
	
	var executor = ToolExecutor.new()
	executor.setup(null)
	
	# Helper output catcher
	var last_output = ""
	executor.tool_output.connect(func(out):
		last_output = str(out)
	)
	
	# Test 1: BSP Dungeon Generation
	print("\n[Test 1] Testing BSP Dungeon Generator...")
	var bsp_res = DungeonGen.generate_bsp(30, 20, 4, 6, 1234)
	if bsp_res.has("rooms") and bsp_res["rooms"].size() > 0 and bsp_res.has("player_spawn"):
		print("  ✅ PASS: BSP generated " + str(bsp_res["rooms"].size()) + " rooms with spawn at " + str(bsp_res["player_spawn"]))
		passed += 1
	else:
		print("  ❌ FAIL: BSP generation failed: " + str(bsp_res))
		failed += 1

	# Test 2: Rooms & Corridors Generation
	print("\n[Test 2] Testing Rooms & Corridors Generator...")
	var roguelike_res = DungeonGen.generate_rooms_and_corridors(35, 25, 6, 4, 8, 4321)
	if roguelike_res.has("rooms") and roguelike_res["rooms"].size() > 0:
		print("  ✅ PASS: Rooms & Corridors generated " + str(roguelike_res["rooms"].size()) + " rooms")
		passed += 1
	else:
		print("  ❌ FAIL: Rooms & Corridors generation failed")
		failed += 1

	# Test 3: Cellular Automata Caves Generation
	print("\n[Test 3] Testing Cellular Automata Caves...")
	var cave_res = DungeonGen.generate_cellular(30, 20, 0.45, 4, 999)
	if cave_res.has("grid") and cave_res.has("player_spawn"):
		print("  ✅ PASS: Cellular cave generated with spawn at " + str(cave_res["player_spawn"]))
		passed += 1
	else:
		print("  ❌ FAIL: Cellular cave generation failed")
		failed += 1

	# Test 4: Drunkard Walk Tunnels
	print("\n[Test 4] Testing Drunkard Walk Tunnels...")
	var drunk_res = DungeonGen.generate_drunkard_walk(30, 20, 0.35, 3000, 777)
	if drunk_res.has("floor_cells_count") and drunk_res["floor_cells_count"] > 20:
		print("  ✅ PASS: Drunkard walk carved " + str(drunk_res["floor_cells_count"]) + " floor tiles")
		passed += 1
	else:
		print("  ❌ FAIL: Drunkard walk generation failed")
		failed += 1

	# Test 5: Autotile Bitmask Scaffolding
	print("\n[Test 5] Testing scaffold_autotile_bitmasks...")
	var test_ts_path = "res://addons/gamedev_ai/scratch/test_autotile.tres"
	var dir = test_ts_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
		
	var test_ts = TileSet.new()
	test_ts.tile_size = Vector2i(16, 16)
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var img_tex = ImageTexture.create_from_image(img)
	var src = TileSetAtlasSource.new()
	src.texture = img_tex
	src.texture_region_size = Vector2i(16, 16)
	test_ts.add_source(src, 0)
	ResourceSaver.save(test_ts, test_ts_path)
	
	last_output = ""
	executor.execute_tool("scaffold_autotile_bitmasks", {
		"tileset_path": test_ts_path,
		"source_id": 0,
		"template": "kenney_3x3_minimal"
	})
	if "success" in last_output and "tiles_configured" in last_output:
		print("  ✅ PASS: Autotile bitmasks scaffolded successfully for Kenney 3x3 template")
		passed += 1
	else:
		print("  ❌ FAIL: Autotile bitmask scaffolding failed: " + last_output)
		failed += 1

	# Test 6: Spritesheet Base64 Inspection (get_atlas_image)
	print("\n[Test 6] Testing get_atlas_image Base64 extraction...")
	last_output = ""
	executor.execute_tool("get_atlas_image", {
		"tileset_path": test_ts_path,
		"source_id": 0,
		"grid_overlay": true
	})
	if "image/png;base64" in last_output and "image_base64" in last_output:
		print("  ✅ PASS: Atlas image extracted, grid overlaid, and encoded to Base64 PNG")
		passed += 1
	else:
		print("  ❌ FAIL: get_atlas_image failed: " + last_output)
		failed += 1

	# Clean up scratch test file
	if FileAccess.file_exists(test_ts_path):
		DirAccess.remove_absolute(test_ts_path)

	print("\n==================================================")
	print("📊 RESULTS: " + str(passed) + " PASSED, " + str(failed) + " FAILED")
	print("==================================================")
	
	if failed == 0:
		print("🎉 ALL DUNGEON & AUTOTILE TESTS PASSED!")
		
	quit(0 if failed == 0 else 1)
