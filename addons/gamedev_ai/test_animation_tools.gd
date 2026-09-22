@tool
extends SceneTree

func _init():
	print("\n=======================================================")
	print("🎬 RUNNING ANIMATION & STATE MACHINE TOOLS TEST SUITE")
	print("=======================================================\n")

	var passed = 0
	var total = 0

	# Test 1: ToolExecutor Registration & Validation
	total += 1
	var ToolExecutorScript = load("res://addons/gamedev_ai/tool_executor.gd")
	if ToolExecutorScript:
		var executor = ToolExecutorScript.new()
		executor.setup(null)
		var v1 = executor._validate_args("create_animation", {"player_node_path": "AnimationPlayer", "animation_name": "idle"})
		var v2 = executor._validate_args("setup_spritesheet_animation", {"player_node_path": "AnimationPlayer", "animation_name": "run", "start_frame": 0, "frame_count": 4})
		var v3 = executor._validate_args("create_state_machine", {"tree_node_path": "AnimationTree", "states": []})
		var v4 = executor._validate_args("setup_character_animation_suite", {"parent_path": ".", "sprite_node_path": "Sprite2D"})
		if v1.get("valid", false) and v2.get("valid", false) and v3.get("valid", false) and v4.get("valid", false):
			print("✅ Test 1 Passed: ToolExecutor successfully registered all Animation & State Machine schemas.")
			passed += 1
		else:
			print("❌ Test 1 Failed: Validation failure on animation tools schemas.")
	else:
		print("❌ Test 1 Failed: Could not load ToolExecutor")

	# Test 2: AnimationTools Handler Loading
	total += 1
	var AnimationToolsScript = load("res://addons/gamedev_ai/tools/animation_tools.gd")
	if AnimationToolsScript:
		var anim_tools = AnimationToolsScript.new()
		var executor = ToolExecutorScript.new()
		anim_tools.setup(executor)
		print("✅ Test 2 Passed: AnimationTools handler instantiated and configured.")
		passed += 1
	else:
		print("❌ Test 2 Failed: Could not load AnimationTools script.")

	# Test 3: Programmatic Animation & Spritesheet Building with RESET
	total += 1
	var test_root = Node2D.new()
	test_root.name = "TestCharacter"
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	test_root.add_child(sprite)
	var player = AnimationPlayer.new()
	player.name = "AnimationPlayer"
	test_root.add_child(player)

	var anim_tools_instance = AnimationToolsScript.new()
	var mock_executor = RefCounted.new()
	mock_executor.set("_test_scene_root", test_root)
	anim_tools_instance.setup(mock_executor)

	anim_tools_instance.execute("setup_spritesheet_animation", {
		"player_node_path": "AnimationPlayer",
		"sprite_node_path": "Sprite2D",
		"animation_name": "walk",
		"start_frame": 4,
		"frame_count": 6,
		"fps": 12.0,
		"loop_mode": "linear",
		"auto_create_reset": true
	})

	if player.has_animation("walk") and player.has_animation("RESET"):
		var walk_anim = player.get_animation("walk")
		if walk_anim.length > 0.4 and walk_anim.get_track_count() >= 1:
			print("✅ Test 3 Passed: Spritesheet animation 'walk' and 'RESET' track built with correct frame keys.")
			passed += 1
		else:
			print("❌ Test 3 Failed: Walk animation tracks missing or invalid length.")
	else:
		print("❌ Test 3 Failed: 'walk' or 'RESET' animation not created.")

	# Test 4: Method Event Track Injection
	total += 1
	anim_tools_instance.execute("add_animation_event_track", {
		"player_node_path": "AnimationPlayer",
		"animation_name": "walk",
		"event_type": "method",
		"target_node_path": "Sprite2D",
		"timestamp": 0.25,
		"method_name_or_property": "_play_footstep",
		"method_args_or_value": ["gravel"]
	})

	var walk_anim_mod = player.get_animation("walk")
	var has_method_track = false
	for t in range(walk_anim_mod.get_track_count()):
		if walk_anim_mod.track_get_type(t) == Animation.TYPE_METHOD:
			has_method_track = true
			break

	if has_method_track:
		print("✅ Test 4 Passed: Method event track successfully injected into animation timeline.")
		passed += 1
	else:
		print("❌ Test 4 Failed: Method event track was not inserted.")

	# Test 5: State Machine & Auto-Layout Graph
	total += 1
	var states = [
		{"name": "idle", "animation": "idle"},
		{"name": "walk", "animation": "walk"}
	]
	var transitions = [
		{"from": "idle", "to": "walk", "advance_expression": "velocity.length() > 5.0", "xfade_time": 0.15},
		{"from": "walk", "to": "idle", "advance_expression": "velocity.length() <= 5.0", "xfade_time": 0.15}
	]

	anim_tools_instance.execute("create_state_machine", {
		"tree_node_path": "AnimationTree",
		"anim_player_path": "../AnimationPlayer",
		"states": states,
		"transitions": transitions,
		"start_state": "idle",
		"set_active": true
	})

	var tree = test_root.get_node_or_null("AnimationTree")
	if tree and tree is AnimationTree and tree.tree_root is AnimationNodeStateMachine:
		var sm = tree.tree_root as AnimationNodeStateMachine
		if sm.has_node("idle") and sm.has_node("walk") and sm.has_transition("idle", "walk"):
			var tr = sm.get_transition(0)
			if tr.advance_expression == "velocity.length() > 5.0":
				print("✅ Test 5 Passed: AnimationNodeStateMachine generated with auto-layout and advance_expression.")
				passed += 1
			else:
				print("❌ Test 5 Failed: Transition advance_expression mismatch.")
		else:
			print("❌ Test 5 Failed: State machine missing states or transitions.")
	else:
		print("❌ Test 5 Failed: AnimationTree node not created or root is not StateMachine.")

	# Test 6: 2D Blend Space Creation
	total += 1
	anim_tools_instance.execute("create_blend_space_2d", {
		"tree_node_path": "AnimationTree",
		"state_name": "MoveBlend",
		"blend_points": [
			{"pos": [0, 1], "animation": "walk"},
			{"pos": [0, -1], "animation": "walk"}
		],
		"blend_mode": "interpolated"
	})

	if tree and tree.tree_root is AnimationNodeStateMachine:
		var sm = tree.tree_root as AnimationNodeStateMachine
		if sm.has_node("MoveBlend") and sm.get_node("MoveBlend") is AnimationNodeBlendSpace2D:
			print("✅ Test 6 Passed: AnimationNodeBlendSpace2D created and integrated into StateMachine.")
			passed += 1
		else:
			print("❌ Test 6 Failed: BlendSpace2D not found in StateMachine.")
	else:
		print("❌ Test 6 Failed: AnimationTree root invalid.")

	# Cleanup test nodes
	test_root.free()

	print("\n-------------------------------------------------------")
	print("📊 RESULTS: " + str(passed) + "/" + str(total) + " Tests Passed.")
	print("=======================================================\n")
	quit()
