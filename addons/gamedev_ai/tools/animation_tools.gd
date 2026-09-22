@tool
extends "res://addons/gamedev_ai/tools/base_tool_handler.gd"

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"create_animation":
			_create_animation(
				args.get("player_node_path", "AnimationPlayer"),
				args.get("animation_name", "default"),
				args.get("library_name", ""),
				float(args.get("length", 1.0)),
				String(args.get("loop_mode", "none")),
				args.get("tracks", [])
			)
			return true
		"setup_spritesheet_animation":
			_setup_spritesheet_animation(
				args.get("player_node_path", "AnimationPlayer"),
				args.get("sprite_node_path", "Sprite2D"),
				args.get("animation_name", "idle"),
				int(args.get("start_frame", 0)),
				int(args.get("frame_count", 4)),
				float(args.get("fps", 10.0)),
				String(args.get("loop_mode", "linear")),
				bool(args.get("auto_create_reset", true))
			)
			return true
		"add_animation_event_track":
			_add_animation_event_track(
				args.get("player_node_path", "AnimationPlayer"),
				args.get("animation_name", "default"),
				args.get("library_name", ""),
				String(args.get("event_type", "method")),
				args.get("target_node_path", "."),
				float(args.get("timestamp", 0.0)),
				String(args.get("method_name_or_property", "")),
				args.get("method_args_or_value", null)
			)
			return true
		"inspect_animation_player":
			_inspect_animation_player(args.get("player_node_path", "AnimationPlayer"))
			return true
		"create_state_machine":
			_create_state_machine(
				args.get("tree_node_path", "AnimationTree"),
				args.get("anim_player_path", "../AnimationPlayer"),
				args.get("states", []),
				args.get("transitions", []),
				String(args.get("start_state", "")),
				bool(args.get("set_active", true))
			)
			return true
		"create_blend_space_2d":
			_create_blend_space_2d(
				args.get("tree_node_path", "AnimationTree"),
				args.get("state_name", "MoveSpace"),
				args.get("blend_points", []),
				String(args.get("blend_mode", "interpolated")),
				args.get("min_space", [-1.0, -1.0]),
				args.get("max_space", [1.0, 1.0])
			)
			return true
		"connect_state_machine_transition":
			_connect_state_machine_transition(
				args.get("tree_node_path", "AnimationTree"),
				String(args.get("from_state", "")),
				String(args.get("to_state", "")),
				String(args.get("advance_condition", "")),
				String(args.get("advance_expression", "")),
				String(args.get("advance_mode", "auto")),
				float(args.get("xfade_time", 0.15)),
				String(args.get("switch_mode", "immediate"))
			)
			return true
		"inspect_animation_tree":
			_inspect_animation_tree(args.get("tree_node_path", "AnimationTree"))
			return true
		"setup_character_animation_suite":
			_setup_character_animation_suite(
				args.get("parent_path", "."),
				args.get("sprite_node_path", "Sprite2D"),
				args.get("animations_config", {}),
				args.get("state_machine_config", {}),
				bool(args.get("auto_create_tree", true)),
				bool(args.get("generate_helper_script", false))
			)
			return true
	return false

# ==============================================================================
# --- 1. AnimationPlayer Tool Implementations ---
# ==============================================================================

func _create_animation(player_path: String, anim_name: String, lib_name: String, length: float, loop_mode_str: String, tracks: Array):
	var player = _resolve_node(player_path)
	if not player or not player is AnimationPlayer:
		_emit_output("[color=red]Error: Node at '" + player_path + "' is not a valid AnimationPlayer.[/color]")
		return

	var lib = _ensure_animation_library(player, lib_name)
	if not lib:
		return

	var anim = Animation.new()
	anim.length = maxf(0.01, length)
	anim.step = 0.05
	
	match loop_mode_str.to_lower():
		"linear", "loop":
			anim.loop_mode = Animation.LOOP_LINEAR
		"pingpong", "ping_pong":
			anim.loop_mode = Animation.LOOP_PINGPONG
		_:
			anim.loop_mode = Animation.LOOP_NONE

	# Add provided tracks
	for tr in tracks:
		if tr is Dictionary:
			_add_track_to_animation(player, anim, tr)

	lib.add_animation(anim_name, anim)
	_save_scene_changes()
	
	var full_name = anim_name if lib_name.is_empty() else lib_name + "/" + anim_name
	var msg = "🎬 [b]Animation Created Successfully![/b]\n"
	msg += "• [b]Animation:[/b] `" + full_name + "`\n"
	msg += "• [b]Duration:[/b] " + str(snappedf(anim.length, 0.01)) + "s | [b]Loop:[/b] " + loop_mode_str + "\n"
	msg += "• [b]Tracks Count:[/b] " + str(anim.get_track_count())
	_emit_output(msg)

func _setup_spritesheet_animation(player_path: String, sprite_path: String, anim_name: String, start_frame: int, frame_count: int, fps: float, loop_mode_str: String, auto_create_reset: bool):
	var player = _resolve_node(player_path)
	if not player or not player is AnimationPlayer:
		_emit_output("[color=red]Error: Node at '" + player_path + "' is not a valid AnimationPlayer.[/color]")
		return

	var sprite = _resolve_relative_node(player, sprite_path)
	if not sprite:
		_emit_output("[color=red]Error: Sprite node '" + sprite_path + "' not found relative to AnimationPlayer.[/color]")
		return

	var lib = _ensure_animation_library(player, "")
	if not lib:
		return

	var safe_fps = maxf(1.0, fps)
	var duration = float(frame_count) / safe_fps
	var frame_step = 1.0 / safe_fps

	# 1. Setup main animation
	var anim = Animation.new()
	anim.length = duration
	anim.step = frame_step

	match loop_mode_str.to_lower():
		"linear", "loop":
			anim.loop_mode = Animation.LOOP_LINEAR
		"pingpong":
			anim.loop_mode = Animation.LOOP_PINGPONG
		_:
			anim.loop_mode = Animation.LOOP_NONE

	# Add frame value track
	var track_path = str(player.get_path_to(sprite)) + ":frame"
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, NodePath(track_path))
	anim.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)

	for i in range(frame_count):
		var time = i * frame_step
		var frame_val = start_frame + i
		anim.track_insert_key(track_idx, time, frame_val)

	lib.add_animation(anim_name, anim)

	# 2. Setup RESET animation if requested and not exists
	if auto_create_reset and not lib.has_animation("RESET"):
		var reset_anim = Animation.new()
		reset_anim.length = 0.001
		var reset_track = reset_anim.add_track(Animation.TYPE_VALUE)
		reset_anim.track_set_path(reset_track, NodePath(track_path))
		reset_anim.value_track_set_update_mode(reset_track, Animation.UPDATE_DISCRETE)
		reset_anim.track_insert_key(reset_track, 0.0, start_frame)
		lib.add_animation("RESET", reset_anim)

	_save_scene_changes()

	var msg = "🎞️ [b]Spritesheet Animation Built Successfully![/b]\n"
	msg += "• [b]Animation:[/b] `" + anim_name + "` on `" + player.name + "`\n"
	msg += "• [b]Frames:[/b] " + str(start_frame) + " → " + str(start_frame + frame_count - 1) + " (" + str(frame_count) + " frames at " + str(safe_fps) + " FPS)\n"
	msg += "• [b]Target Node:[/b] `" + sprite.name + "` (" + track_path + ")"
	_emit_output(msg)

func _add_animation_event_track(player_path: String, anim_name: String, lib_name: String, event_type: String, target_path: String, timestamp: float, method_or_prop: String, args_or_val: Variant):
	var player = _resolve_node(player_path)
	if not player or not player is AnimationPlayer:
		_emit_output("[color=red]Error: Node at '" + player_path + "' is not a valid AnimationPlayer.[/color]")
		return

	var lib = _ensure_animation_library(player, lib_name)
	if not lib or not lib.has_animation(anim_name):
		_emit_output("[color=red]Error: Animation '" + anim_name + "' not found in AnimationPlayer.[/color]")
		return

	var anim = lib.get_animation(anim_name)
	var target_node = _resolve_relative_node(player, target_path)
	if not target_node:
		_emit_output("[color=red]Error: Target event node '" + target_path + "' not found.[/color]")
		return

	var rel_path = str(player.get_path_to(target_node))

	if event_type.to_lower() == "method":
		# Method Track
		var track_path = NodePath(rel_path)
		var track_idx = -1
		for i in range(anim.get_track_count()):
			if anim.track_get_type(i) == Animation.TYPE_METHOD and anim.track_get_path(i) == track_path:
				track_idx = i
				break
		if track_idx == -1:
			track_idx = anim.add_track(Animation.TYPE_METHOD)
			anim.track_set_path(track_idx, track_path)

		var method_dict = {
			"method": method_or_prop,
			"args": args_or_val if args_or_val is Array else ([] if args_or_val == null else [args_or_val])
		}
		anim.track_insert_key(track_idx, timestamp, method_dict)
		_emit_output("⚡ [b]Method Event Key Inserted:[/b] Invoking `" + method_or_prop + "()` at " + str(timestamp) + "s on `" + target_node.name + "`.")
	else:
		# Property Value Track
		var full_prop_path = NodePath(rel_path + ":" + method_or_prop)
		var track_idx = -1
		for i in range(anim.get_track_count()):
			if anim.track_get_path(i) == full_prop_path:
				track_idx = i
				break
		if track_idx == -1:
			track_idx = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(track_idx, full_prop_path)
			anim.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)

		anim.track_insert_key(track_idx, timestamp, args_or_val)
		_emit_output("⚡ [b]Property Event Key Inserted:[/b] Setting `" + method_or_prop + " = " + str(args_or_val) + "` at " + str(timestamp) + "s.")

	_save_scene_changes()

func _inspect_animation_player(player_path: String):
	var player = _resolve_node(player_path)
	if not player or not player is AnimationPlayer:
		_emit_output("[color=red]Error: Node at '" + player_path + "' is not a valid AnimationPlayer.[/color]")
		return

	var report = "🎬 [b]AnimationPlayer Inspection Report: '" + player.name + "'[/b]\n"
	var lib_list = player.get_animation_library_list()
	if lib_list.is_empty():
		report += "• [color=yellow]No Animation Libraries found.[/color]\n"
		_emit_output(report)
		return

	for lib_name in lib_list:
		var lib = player.get_animation_library(lib_name)
		var display_lib = "[default]" if lib_name == "" else lib_name
		report += "\n📦 [b]Library: " + display_lib + "[/b]\n"
		var anim_list = lib.get_animation_list()
		if anim_list.is_empty():
			report += "  • (Empty Library)\n"
		for a_name in anim_list:
			var anim = lib.get_animation(a_name)
			var loop_str = "None"
			if anim.loop_mode == Animation.LOOP_LINEAR: loop_str = "Linear"
			elif anim.loop_mode == Animation.LOOP_PINGPONG: loop_str = "PingPong"
			report += "  • [b]`" + a_name + "`[/b]: " + str(snappedf(anim.length, 0.01)) + "s (Loop: " + loop_str + ", Tracks: " + str(anim.get_track_count()) + ")\n"
			for t in range(anim.get_track_count()):
				var p = anim.track_get_path(t)
				var type_name = "VALUE"
				if anim.track_get_type(t) == Animation.TYPE_METHOD: type_name = "METHOD"
				report += "    - Track [" + type_name + "]: `" + str(p) + "` (" + str(anim.track_get_key_count(t)) + " keys)\n"

	_emit_output(report)

# ==============================================================================
# --- 2. AnimationTree & State Machine Implementations ---
# ==============================================================================

func _create_state_machine(tree_path: String, anim_player_path: String, states: Array, transitions: Array, start_state: String, set_active: bool):
	var root = _get_scene_root()
	if not root:
		return

	var tree = _resolve_node(tree_path)
	if not tree:
		# Automatically instantiate and attach AnimationTree if not present
		tree = AnimationTree.new()
		tree.name = tree_path.get_file()
		root.add_child(tree)
		tree.owner = root
		_emit_output("Created new AnimationTree node at `" + tree_path + "`.")

	if not tree is AnimationTree:
		_emit_output("[color=red]Error: Node at '" + tree_path + "' is not an AnimationTree.[/color]")
		return

	tree.anim_player = NodePath(anim_player_path)

	var state_machine = AnimationNodeStateMachine.new()
	var registered_states: Dictionary = {}

	# 1. Register States with Auto-Layout Positions
	for i in range(states.size()):
		var st = states[i]
		if st is Dictionary:
			var st_name = String(st.get("name", "state_" + str(i)))
			var anim_name = String(st.get("animation", st_name))
			var node_anim = AnimationNodeAnimation.new()
			node_anim.animation = anim_name

			var pos = _calculate_auto_layout_position(st_name, i, st.get("position", null))
			state_machine.add_node(st_name, node_anim, pos)
			registered_states[st_name] = true

	# Set Start State
	if start_state != "" and registered_states.has(start_state):
		state_machine.set_start_node(start_state)
	elif not states.is_empty():
		var first_name = states[0].get("name", "")
		if first_name != "":
			state_machine.set_start_node(first_name)

	# 2. Register Transitions
	for tr in transitions:
		if tr is Dictionary:
			var from_node = String(tr.get("from", ""))
			var to_node = String(tr.get("to", ""))
			if registered_states.has(from_node) and registered_states.has(to_node):
				var trans = _build_transition(tr)
				state_machine.add_transition(from_node, to_node, trans)

	tree.tree_root = state_machine
	tree.active = set_active
	_save_scene_changes()

	var msg = "🌲 [b]AnimationNodeStateMachine Configured Successfully![/b]\n"
	msg += "• [b]Tree Node:[/b] `" + tree.name + "` (Connected to `" + anim_player_path + "`)\n"
	msg += "• [b]States (" + str(registered_states.size()) + "):[/b] " + ", ".join(registered_states.keys()) + "\n"
	msg += "• [b]Transitions Count:[/b] " + str(transitions.size()) + "\n"
	msg += "• [b]Active Status:[/b] " + str(set_active)
	_emit_output(msg)

func _create_blend_space_2d(tree_path: String, state_name: String, blend_points: Array, blend_mode_str: String, min_space: Array, max_space: Array):
	var tree = _resolve_node(tree_path)
	if not tree or not tree is AnimationTree:
		_emit_output("[color=red]Error: Node at '" + tree_path + "' is not a valid AnimationTree.[/color]")
		return

	if not tree.tree_root or not tree.tree_root is AnimationNodeStateMachine:
		_emit_output("[color=red]Error: AnimationTree root must be an AnimationNodeStateMachine.[/color]")
		return

	var sm = tree.tree_root as AnimationNodeStateMachine
	var blend_space = AnimationNodeBlendSpace2D.new()

	if min_space.size() >= 2:
		blend_space.min_space = Vector2(float(min_space[0]), float(min_space[1]))
	if max_space.size() >= 2:
		blend_space.max_space = Vector2(float(max_space[0]), float(max_space[1]))

	match blend_mode_str.to_lower():
		"discrete":
			blend_space.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_DISCRETE
		_:
			blend_space.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_INTERPOLATED

	# Add blend points
	var added_pts = 0
	for pt in blend_points:
		if pt is Dictionary:
			var anim_name = pt.get("animation", "")
			var pos_arr = pt.get("pos", [0, 0])
			if anim_name != "" and pos_arr is Array and pos_arr.size() >= 2:
				var node_anim = AnimationNodeAnimation.new()
				node_anim.animation = anim_name
				var vec_pos = Vector2(float(pos_arr[0]), float(pos_arr[1]))
				blend_space.add_blend_point(node_anim, vec_pos)
				added_pts += 1

	if sm.has_node(state_name):
		sm.remove_node(state_name)

	var layout_pos = _calculate_auto_layout_position(state_name, 1, null)
	sm.add_node(state_name, blend_space, layout_pos)
	_save_scene_changes()

	var msg = "🕹️ [b]AnimationNodeBlendSpace2D Added Successfully![/b]\n"
	msg += "• [b]State Name:[/b] `" + state_name + "` in `" + tree.name + "`\n"
	msg += "• [b]Blend Points Added:[/b] " + str(added_pts) + "\n"
	msg += "• [b]Blend Mode:[/b] " + blend_mode_str + " (Bounds: " + str(blend_space.min_space) + " to " + str(blend_space.max_space) + ")"
	_emit_output(msg)

func _connect_state_machine_transition(tree_path: String, from_state: String, to_state: String, advance_cond: String, advance_expr: String, advance_mode: String, xfade_time: float, switch_mode: String):
	var tree = _resolve_node(tree_path)
	if not tree or not tree is AnimationTree:
		_emit_output("[color=red]Error: Node at '" + tree_path + "' is not a valid AnimationTree.[/color]")
		return

	if not tree.tree_root or not tree.tree_root is AnimationNodeStateMachine:
		_emit_output("[color=red]Error: AnimationTree root is not an AnimationNodeStateMachine.[/color]")
		return

	var sm = tree.tree_root as AnimationNodeStateMachine
	if not sm.has_node(from_state) or not sm.has_node(to_state):
		_emit_output("[color=red]Error: States '" + from_state + "' or '" + to_state + "' not found in StateMachine.[/color]")
		return

	var tr_dict = {
		"advance_mode": advance_mode,
		"advance_condition": advance_cond,
		"advance_expression": advance_expr,
		"xfade_time": xfade_time,
		"switch_mode": switch_mode
	}

	var trans = _build_transition(tr_dict)
	
	# If transition already exists, replace it
	if sm.has_transition(from_state, to_state):
		sm.remove_transition(from_state, to_state)

	sm.add_transition(from_state, to_state, trans)
	_save_scene_changes()

	var cond_info = "Expression: `" + advance_expr + "`" if advance_expr != "" else ("Condition: `" + advance_cond + "`" if advance_cond != "" else "Auto")
	var msg = "🔀 [b]Transition Connected:[/b] `" + from_state + "` ➔ `" + to_state + "` (" + cond_info + ", XFade: " + str(xfade_time) + "s)"
	_emit_output(msg)

func _inspect_animation_tree(tree_path: String):
	var tree = _resolve_node(tree_path)
	if not tree or not tree is AnimationTree:
		_emit_output("[color=red]Error: Node at '" + tree_path + "' is not an AnimationTree.[/color]")
		return

	var report = "🌲 [b]AnimationTree Inspection Report: '" + tree.name + "'[/b]\n"
	report += "• [b]Target Player:[/b] `" + str(tree.anim_player) + "` | [b]Active:[/b] " + str(tree.active) + "\n"

	if not tree.tree_root:
		report += "• [color=yellow]No root node assigned.[/color]\n"
		_emit_output(report)
		return

	if tree.tree_root is AnimationNodeStateMachine:
		var sm = tree.tree_root as AnimationNodeStateMachine
		report += "\n📊 [b]StateMachine Nodes & Graph Layout:[/b]\n"
		var node_list = sm.get_node_list()
		for n_name in node_list:
			var node_obj = sm.get_node(n_name)
			var node_type = "Animation"
			if node_obj is AnimationNodeBlendSpace2D: node_type = "BlendSpace2D"
			elif node_obj is AnimationNodeStateMachine: node_type = "Sub-StateMachine"
			var pos = sm.get_node_position(n_name)
			report += "  • [b]`" + n_name + "`[/b] (" + node_type + ") at position " + str(pos) + "\n"

		report += "\n🔀 [b]Transitions (" + str(sm.get_transition_count()) + "):[/b]\n"
		for t_idx in range(sm.get_transition_count()):
			var from_n = sm.get_transition_from_node(t_idx)
			var to_n = sm.get_transition_to_node(t_idx)
			var trans = sm.get_transition(t_idx)
			var cond_desc = ""
			if trans.advance_expression != "": cond_desc = " [expr: " + trans.advance_expression + "]"
			elif trans.advance_condition != "": cond_desc = " [cond: " + str(trans.advance_condition) + "]"
			report += "  • `" + from_n + "` ➔ `" + to_n + "` (XFade: " + str(trans.xfade_time) + "s)" + cond_desc + "\n"

	_emit_output(report)

# ==============================================================================
# --- 3. High-Level All-in-One Character Suite ---
# ==============================================================================

func _setup_character_animation_suite(parent_path: String, sprite_path: String, anims_config: Dictionary, sm_config: Dictionary, auto_create_tree: bool, generate_boilerplate: bool):
	var parent_node = _resolve_node(parent_path)
	if not parent_node:
		_emit_output("[color=red]Error: Parent node '" + parent_path + "' not found.[/color]")
		return

	# 1. Ensure AnimationPlayer exists under parent
	var player: AnimationPlayer = null
	for child in parent_node.get_children():
		if child is AnimationPlayer:
			player = child
			break
	if not player:
		player = AnimationPlayer.new()
		player.name = "AnimationPlayer"
		parent_node.add_child(player)
		player.owner = _get_scene_root()

	# 2. Build Animations from Config
	var default_anims = {
		"idle": {"start_frame": 0, "frame_count": 4, "fps": 8.0, "loop": "linear"},
		"walk": {"start_frame": 4, "frame_count": 6, "fps": 10.0, "loop": "linear"},
		"run": {"start_frame": 10, "frame_count": 6, "fps": 12.0, "loop": "linear"},
		"attack": {"start_frame": 16, "frame_count": 4, "fps": 14.0, "loop": "none"},
		"hurt": {"start_frame": 20, "frame_count": 2, "fps": 8.0, "loop": "none"},
		"death": {"start_frame": 22, "frame_count": 4, "fps": 8.0, "loop": "none"}
	}

	var active_anims = default_anims.duplicate(true)
	for k in anims_config:
		active_anims[k] = anims_config[k]

	for a_name in active_anims:
		var cfg = active_anims[a_name]
		_setup_spritesheet_animation(
			str(parent_node.get_path_to(player)),
			sprite_path,
			a_name,
			int(cfg.get("start_frame", 0)),
			int(cfg.get("frame_count", 4)),
			float(cfg.get("fps", 10.0)),
			String(cfg.get("loop", "linear")),
			true
		)

	# 3. Setup AnimationTree if requested
	if auto_create_tree:
		var states = []
		for a_name in active_anims:
			states.append({"name": a_name, "animation": a_name})

		var transitions = [
			{"from": "idle", "to": "walk", "advance_expression": "velocity.length() > 5.0 and velocity.length() <= 120.0", "xfade_time": 0.15},
			{"from": "walk", "to": "idle", "advance_expression": "velocity.length() <= 5.0", "xfade_time": 0.15},
			{"from": "walk", "to": "run", "advance_expression": "velocity.length() > 120.0", "xfade_time": 0.15},
			{"from": "run", "to": "walk", "advance_expression": "velocity.length() <= 120.0 and velocity.length() > 5.0", "xfade_time": 0.15},
			{"from": "idle", "to": "attack", "advance_condition": "is_attacking", "xfade_time": 0.05},
			{"from": "walk", "to": "attack", "advance_condition": "is_attacking", "xfade_time": 0.05},
			{"from": "attack", "to": "idle", "advance_mode": "auto", "switch_mode": "at_end", "xfade_time": 0.1},
			{"from": "idle", "to": "hurt", "advance_condition": "is_hurt", "xfade_time": 0.05},
			{"from": "hurt", "to": "idle", "advance_mode": "auto", "switch_mode": "at_end", "xfade_time": 0.1},
			{"from": "idle", "to": "death", "advance_condition": "is_dead", "xfade_time": 0.1}
		]

		if sm_config.has("transitions"):
			transitions = sm_config["transitions"]

		_create_state_machine(
			str(parent_node.get_path()) + "/AnimationTree",
			"../AnimationPlayer",
			states,
			transitions,
			"idle",
			true
		)

	_save_scene_changes()

	var msg = "🚀 [b]Studio Character Animation Suite Assembled Successfully![/b]\n"
	msg += "• [b]Parent Character:[/b] `" + parent_node.name + "`\n"
	msg += "• [b]Configured Animations:[/b] " + ", ".join(active_anims.keys()) + "\n"
	msg += "• [b]AnimationTree & Transitions:[/b] Connected with Expression and One-shot rules.\n"
	_emit_output(msg)

# ==============================================================================
# --- 4. Internal Helpers & Math ---
# ==============================================================================

func _calculate_auto_layout_position(state_name: String, index: int, explicit_pos: Variant) -> Vector2:
	if explicit_pos is Array and explicit_pos.size() >= 2:
		return Vector2(float(explicit_pos[0]), float(explicit_pos[1]))
	
	var s_lower = state_name.to_lower()
	if s_lower == "start": return Vector2(0, 0)
	if s_lower == "idle": return Vector2(250, 0)
	if s_lower == "walk": return Vector2(500, 0)
	if s_lower == "run": return Vector2(750, 0)
	if s_lower == "jump": return Vector2(350, -180)
	if s_lower == "fall": return Vector2(600, -180)
	if s_lower == "attack": return Vector2(350, 180)
	if s_lower == "hurt": return Vector2(600, 180)
	if s_lower == "death": return Vector2(850, 180)
	
	# Generic grid placement
	var col = index % 3
	var row = index / 3
	return Vector2(200 + col * 250, row * 180)

func _build_transition(dict: Dictionary) -> AnimationNodeStateMachineTransition:
	var trans = AnimationNodeStateMachineTransition.new()
	trans.xfade_time = float(dict.get("xfade_time", 0.15))

	var adv_mode = String(dict.get("advance_mode", "auto")).to_lower()
	match adv_mode:
		"enabled": trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED
		"disabled": trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_DISABLED
		_: trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO

	var sw_mode = String(dict.get("switch_mode", "immediate")).to_lower()
	match sw_mode:
		"at_end", "end": trans.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
		"sync": trans.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_SYNC
		_: trans.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE

	if dict.has("advance_condition") and String(dict["advance_condition"]) != "":
		trans.advance_condition = StringName(dict["advance_condition"])

	if dict.has("advance_expression") and String(dict["advance_expression"]) != "":
		trans.advance_expression = String(dict["advance_expression"])

	return trans

func _add_track_to_animation(player: AnimationPlayer, anim: Animation, tr_dict: Dictionary):
	var node_path_str = String(tr_dict.get("node_path", ""))
	var prop = String(tr_dict.get("property", ""))
	var t_type_str = String(tr_dict.get("track_type", "value")).to_lower()
	var keys = tr_dict.get("keys", [])

	var full_path_str = node_path_str
	if prop != "" and not node_path_str.ends_with(":" + prop):
		full_path_str += ":" + prop

	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, NodePath(full_path_str))

	var up_mode = String(tr_dict.get("update_mode", "discrete")).to_lower()
	match up_mode:
		"continuous": anim.value_track_set_update_mode(track_idx, Animation.UPDATE_CONTINUOUS)
		"capture": anim.value_track_set_update_mode(track_idx, Animation.UPDATE_CAPTURE)
		_: anim.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)

	for k in keys:
		if k is Dictionary:
			var time = float(k.get("time", 0.0))
			var val = k.get("value", null)
			var trans = float(k.get("transition", 1.0))
			anim.track_insert_key(track_idx, time, val, trans)

func _ensure_animation_library(player: AnimationPlayer, lib_name: String) -> AnimationLibrary:
	var target_lib_name = lib_name.strip_edges()
	if player.has_animation_library(target_lib_name):
		return player.get_animation_library(target_lib_name)
	
	var new_lib = AnimationLibrary.new()
	var err = player.add_animation_library(target_lib_name, new_lib)
	if err != OK:
		_emit_output("[color=red]Error adding AnimationLibrary '" + target_lib_name + "': " + str(err) + "[/color]")
		return null
	return new_lib

func _resolve_node(path_or_name: String) -> Node:
	var root = _get_scene_root()
	if not root:
		_emit_output("[color=red]Error: No active edited scene root.[/color]")
		return null
	
	if path_or_name == "." or path_or_name == "":
		return root
	
	if root.has_node(path_or_name):
		return root.get_node(path_or_name)
		
	# Search by name in hierarchy
	var found = root.find_child(path_or_name, true, false)
	if found:
		return found
		
	return null

func _resolve_relative_node(base_node: Node, target_path: String) -> Node:
	if base_node.has_node(target_path):
		return base_node.get_node(target_path)
	
	var root = _get_scene_root()
	if root and root.has_node(target_path):
		return root.get_node(target_path)
		
	if root:
		var found = root.find_child(target_path, true, false)
		if found:
			return found
			
	return null

func _get_scene_root() -> Node:
	if Engine.is_editor_hint():
		return EditorInterface.get_edited_scene_root()
	if executor and "_test_scene_root" in executor and executor._test_scene_root:
		return executor._test_scene_root
	return null

func _save_scene_changes():
	if Engine.is_editor_hint():
		var root = EditorInterface.get_edited_scene_root()
		if root and not root.scene_file_path.is_empty():
			EditorInterface.save_scene()
