@tool
extends "res://addons/godot_ai/handlers/command_handler.gd"

const ErrorCodes := preload("res://addons/godot_ai/utils/error_codes.gd")

## Handles AnimationPlayer authoring: creating players, animations, tracks,
## keyframes, autoplay, and dev-ergonomics playback.
##
## Animations live inside an AnimationLibrary attached to an AnimationPlayer
## node in the scene. They save with the .tscn — no separate resource file
## needed. Undo callables hold direct Animation references (not paths).
##
## Split (issue #342, audit finding #13):
##   - animation_presets.gd  → preset_fade / slide / shake / pulse + helpers
##   - animation_values.gd   → animation_list / get / validate + shared
##                             value coercion / serialization
## Both submodules hold a WeakRef back to this handler. The handler's
## preset_* / list / get / validate methods are thin proxies so existing
## dispatcher registrations and test fixtures don't change.

const AnimationPresets := preload("res://addons/godot_ai/handlers/animation_presets.gd")
const AnimationValues := preload("res://addons/godot_ai/handlers/animation_values.gd")

var _undo_redo: EditorUndoRedoManager
var _presets
var _values

const _LOOP_MODES := {
	"none": Animation.LOOP_NONE,
	"linear": Animation.LOOP_LINEAR,
	"pingpong": Animation.LOOP_PINGPONG,
}

const _INTERP_MODES := {
	"nearest": Animation.INTERPOLATION_NEAREST,
	"linear": Animation.INTERPOLATION_LINEAR,
	"cubic": Animation.INTERPOLATION_CUBIC,
}


func _init(undo_redo: EditorUndoRedoManager) -> void:
	_undo_redo = undo_redo
	_presets = AnimationPresets.new(self)
	_values = AnimationValues.new(self)


# ============================================================================
# animation_player_create
# ============================================================================

func create_player(params: Dictionary) -> Dictionary:
	var parent_path: String = params.get("parent_path", "")
	var node_name: String = params.get("name", "AnimationPlayer")

	var _scene_check := McpNodeValidator.require_scene_or_error()
	if _scene_check.has("error"):
		return _scene_check
	var scene_root: Node = _scene_check.scene_root

	var parent: Node = scene_root
	if not parent_path.is_empty():
		parent = McpScenePath.resolve(parent_path, scene_root)
		if parent == null:
			return ErrorCodes.make(ErrorCodes.NODE_NOT_FOUND, McpScenePath.format_parent_error(parent_path, scene_root))

	var player := AnimationPlayer.new()
	if not node_name.is_empty():
		player.name = node_name

	# Attach the default library before adding to tree — it persists on redo.
	var library := AnimationLibrary.new()
	player.add_animation_library("", library)

	_undo_redo.create_action("MCP: Create AnimationPlayer %s" % player.name)
	_undo_redo.add_do_method(parent, "add_child", player, true)
	_undo_redo.add_do_method(player, "set_owner", scene_root)
	_undo_redo.add_do_reference(player)
	_undo_redo.add_do_reference(library)
	_undo_redo.add_undo_method(parent, "remove_child", player)
	_undo_redo.commit_action()

	return {
		"data": {
			"path": McpScenePath.from_node(player, scene_root),
			"parent_path": McpScenePath.from_node(parent, scene_root),
			"name": String(player.name),
			"undoable": true,
		}
	}


# ============================================================================
# animation_create
# ============================================================================

func create_animation(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")
	var anim_name: String = params.get("name", "")
	var length: float = float(params.get("length", 1.0))
	var loop_mode_str: String = params.get("loop_mode", "none")

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")
	if anim_name.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: name")
	if length <= 0.0:
		return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE, "length must be > 0 (got %s)" % length)

	if not _LOOP_MODES.has(loop_mode_str):
		return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE,
			"Invalid loop_mode '%s'. Valid: %s" % [loop_mode_str, ", ".join(_LOOP_MODES.keys())])

	var resolved := _resolve_player(player_path, true)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player
	var library: AnimationLibrary = resolved.library
	var created_player: bool = resolved.get("player_created", false)
	var player_parent: Node = resolved.get("player_parent", null)
	var created_library := false
	if library == null:
		library = AnimationLibrary.new()
		created_library = true

	var overwrite: bool = params.get("overwrite", false)
	var old_anim: Animation = null
	if library.has_animation(anim_name):
		if not overwrite:
			return ErrorCodes.make(ErrorCodes.INVALID_PARAMS,
				"Animation '%s' already exists. Pass overwrite=true or delete it first." % anim_name)
		old_anim = library.get_animation(anim_name)

	var anim := Animation.new()
	anim.length = length
	anim.loop_mode = _LOOP_MODES[loop_mode_str]

	_commit_animation_add("MCP: Create animation %s" % anim_name,
		player, library, created_library, anim_name, anim, old_anim,
		created_player, player_parent)

	return {
		"data": {
			"player_path": player_path,
			"name": anim_name,
			"length": length,
			"loop_mode": loop_mode_str,
			"library_created": created_library or created_player,
			"animation_player_created": created_player,
			"overwritten": old_anim != null,
			"undoable": true,
		}
	}


# ============================================================================
# animation_delete
# ============================================================================

func delete_animation(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")
	var anim_name: String = params.get("animation_name", "")

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")
	if anim_name.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: animation_name")

	var resolved := _resolve_player(player_path)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player

	# Use _resolve_animation so we can delete from ANY library, not just the
	# default. Mirrors the read-side symmetry with animation_get / animation_play
	# which already search all libraries via _resolve_animation.
	var anim_resolved := _resolve_animation(player, anim_name)
	if anim_resolved.has("error"):
		return anim_resolved
	var old_anim: Animation = anim_resolved.animation
	var library: AnimationLibrary = anim_resolved.library
	# Clip key within the owning library — strips the "libname/" prefix if the
	# caller passed a qualified name.
	var clip_key: String = anim_name
	var slash := anim_name.find("/")
	if slash >= 0:
		clip_key = anim_name.substr(slash + 1)

	_undo_redo.create_action("MCP: Delete animation %s" % anim_name)
	_undo_redo.add_do_method(library, "remove_animation", clip_key)
	_undo_redo.add_undo_method(library, "add_animation", clip_key, old_anim)
	_undo_redo.add_do_reference(old_anim)  # prevent GC so undo→redo works
	_undo_redo.commit_action()

	return {
		"data": {
			"player_path": player_path,
			"animation_name": anim_name,
			"library_key": anim_resolved.get("library_key", ""),
			"undoable": true,
		}
	}


# ============================================================================
# animation_add_property_track
# ============================================================================

func add_property_track(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")
	var anim_name: String = params.get("animation_name", "")
	var track_path: String = params.get("track_path", "")
	var keyframes = params.get("keyframes", [])
	var interp_str: String = params.get("interpolation", "linear")

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")
	if anim_name.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: animation_name")
	if track_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM,
			"Missing required param: track_path (format: 'NodeName:property', e.g. 'Panel:modulate')")
	if not track_path.contains(":"):
		return ErrorCodes.make(ErrorCodes.INVALID_PARAMS,
			"track_path must include ':property' suffix (e.g. 'Panel:modulate', '.:position')")
	if not _INTERP_MODES.has(interp_str):
		return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE,
			"Invalid interpolation '%s'. Valid: %s" % [interp_str, ", ".join(_INTERP_MODES.keys())])
	if typeof(keyframes) != TYPE_ARRAY or keyframes.is_empty():
		return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "keyframes must be a non-empty array")

	var resolved := _resolve_player(player_path)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player

	var anim_resolved := _resolve_animation(player, anim_name)
	if anim_resolved.has("error"):
		return anim_resolved
	var anim: Animation = anim_resolved.animation

	# Validate + pre-coerce keyframes before mutating. Coercion errors
	# surface as INVALID_PARAMS rather than silently inserting garbage keys.
	# Resolve the target property's type ONCE — dense clips used to re-walk
	# get_property_list() per keyframe.
	var ctx := AnimationValues.resolve_track_prop_context(track_path, player)
	if ctx.has("error"):
		return ErrorCodes.make(ErrorCodes.INVALID_PARAMS, ctx.error)
	var coerced_keyframes: Array = []
	for kf in keyframes:
		if typeof(kf) != TYPE_DICTIONARY:
			return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "Each keyframe must be a dictionary")
		if not "time" in kf:
			return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Each keyframe must have a 'time' field")
		if not "value" in kf:
			return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Each keyframe must have a 'value' field")
		var coerce_result := AnimationValues.coerce_with_context(kf.get("value"), ctx)
		if coerce_result.has("error"):
			return ErrorCodes.make(ErrorCodes.INVALID_PARAMS, coerce_result.error)
		coerced_keyframes.append({
			"time": kf.get("time"),
			"value": coerce_result.ok,
			"transition": kf.get("transition", "linear"),
		})

	_create_scene_pinned_action("MCP: Add property track %s to %s" % [track_path, anim_name])
	_undo_redo.add_do_method(self, "_do_add_property_track", anim, track_path, interp_str, coerced_keyframes)
	# Undo locates the track by (path, type) at undo time rather than caching
	# an index captured at do time. Cached indices go stale if any other track
	# mutation lands between do and undo (Godot editor, another MCP call, etc.)
	_undo_redo.add_undo_method(self, "_undo_remove_track_by_path", anim, track_path, Animation.TYPE_VALUE)
	_undo_redo.commit_action()

	return {
		"data": {
			"player_path": player_path,
			"animation_name": anim_name,
			"track_path": track_path,
			"interpolation": interp_str,
			"keyframe_count": keyframes.size(),
			"undoable": true,
		}
	}


## Insert a pre-coerced track into the animation. Callers must coerce
## values against the target property before calling this (see
## AnimationValues.coerce_value_for_track) — this method runs inside the
## undo do-method path where error propagation isn't possible.
func _do_add_property_track(
	anim: Animation,
	track_path: String,
	interp_str: String,
	keyframes: Array,
) -> void:
	var idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(idx, NodePath(track_path))
	anim.track_set_interpolation_type(idx, _INTERP_MODES.get(interp_str, Animation.INTERPOLATION_LINEAR))
	for kf in keyframes:
		var t: float = float(kf.get("time", 0.0))
		var trans: float = AnimationValues.parse_transition(kf.get("transition", "linear"))
		anim.track_insert_key(idx, t, kf.get("value"), trans)


# ============================================================================
# animation_add_method_track
# ============================================================================

func add_method_track(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")
	var anim_name: String = params.get("animation_name", "")
	var target_path: String = params.get("target_node_path", "")
	var keyframes = params.get("keyframes", [])

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")
	if anim_name.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: animation_name")
	if target_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: target_node_path")
	if target_path.contains(":"):
		return ErrorCodes.make(ErrorCodes.INVALID_PARAMS,
			"target_node_path is a bare NodePath without ':property' (got '%s'). " % target_path +
			"Method name goes in each keyframe's 'method' field, not the path.")
	if typeof(keyframes) != TYPE_ARRAY or keyframes.is_empty():
		return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "keyframes must be a non-empty array")

	for kf in keyframes:
		if typeof(kf) != TYPE_DICTIONARY:
			return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "Each keyframe must be a dictionary")
		if not "time" in kf:
			return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Each keyframe must have a 'time' field")
		if not "method" in kf:
			return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Each keyframe must have a 'method' field")
		var method_field = kf.get("method")
		if typeof(method_field) != TYPE_STRING or (method_field as String).is_empty():
			return ErrorCodes.make(ErrorCodes.INVALID_PARAMS, "'method' must be a non-empty string")
		if kf.has("args") and typeof(kf.get("args")) != TYPE_ARRAY:
			return ErrorCodes.make(ErrorCodes.INVALID_PARAMS,
				"'args' must be an array if provided (got %s)" % type_string(typeof(kf.get("args"))))

	var resolved := _resolve_player(player_path)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player

	var anim_resolved := _resolve_animation(player, anim_name)
	if anim_resolved.has("error"):
		return anim_resolved
	var anim: Animation = anim_resolved.animation

	_create_scene_pinned_action("MCP: Add method track %s to %s" % [target_path, anim_name])
	_undo_redo.add_do_method(self, "_do_add_method_track", anim, target_path, keyframes)
	# Undo locates the track by (path, type) at undo time — see add_property_track.
	_undo_redo.add_undo_method(self, "_undo_remove_track_by_path", anim, target_path, Animation.TYPE_METHOD)
	_undo_redo.commit_action()

	return {
		"data": {
			"player_path": player_path,
			"animation_name": anim_name,
			"target_node_path": target_path,
			"keyframe_count": keyframes.size(),
			"undoable": true,
		}
	}


## Remove a track identified by (path, type) at undo time. Robust to
## history interleaving: if another track was added since the do, the
## find_track call still resolves to the correct index. Returns silently
## if the track is no longer present (e.g. a prior undo already removed it).
func _undo_remove_track_by_path(anim: Animation, track_path: String, track_type: int) -> void:
	var idx := anim.find_track(NodePath(track_path), track_type)
	if idx >= 0:
		anim.remove_track(idx)


func _do_add_method_track(anim: Animation, target_path: String, keyframes: Array) -> void:
	var idx := anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(idx, NodePath(target_path))
	for kf in keyframes:
		var t: float = float(kf.get("time", 0.0))
		var method_name: String = str(kf.get("method", ""))
		var args: Array = kf.get("args", [])
		anim.track_insert_key(idx, t, {"method": method_name, "args": args})


# ============================================================================
# animation_set_autoplay
# ============================================================================

func set_autoplay(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")
	var anim_name: String = params.get("animation_name", "")

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")

	var resolved := _resolve_player(player_path)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player

	# Allow empty string to clear autoplay; otherwise validate the name exists.
	if not anim_name.is_empty() and not player.has_animation(anim_name):
		return ErrorCodes.make(ErrorCodes.PROPERTY_NOT_ON_CLASS,
			"Animation '%s' not found on player at %s" % [anim_name, player_path])

	var old_autoplay: String = player.autoplay

	_undo_redo.create_action("MCP: Set autoplay %s on %s" % [anim_name, player_path])
	_undo_redo.add_do_property(player, "autoplay", anim_name)
	_undo_redo.add_undo_property(player, "autoplay", old_autoplay)
	_undo_redo.commit_action()

	return {
		"data": {
			"player_path": player_path,
			"animation_name": anim_name,
			"previous_autoplay": old_autoplay,
			"cleared": anim_name.is_empty(),
			"undoable": true,
		}
	}


# ============================================================================
# animation_play  (dev ergonomics — not saved with scene)
# ============================================================================

func play(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")
	var anim_name: String = params.get("animation_name", "")

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")

	var resolved := _resolve_player(player_path)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player

	if not anim_name.is_empty() and not player.has_animation(anim_name):
		return ErrorCodes.make(ErrorCodes.PROPERTY_NOT_ON_CLASS,
			"Animation '%s' not found on player at %s" % [anim_name, player_path])

	player.play(anim_name)

	return {
		"data": {
			"player_path": player_path,
			"animation_name": anim_name,
			"undoable": false,
			"reason": "Runtime playback state — not saved with scene",
		}
	}


# ============================================================================
# animation_stop  (dev ergonomics — not saved with scene)
# ============================================================================

func stop(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")

	var resolved := _resolve_player(player_path)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player

	player.stop()

	return {
		"data": {
			"player_path": player_path,
			"undoable": false,
			"reason": "Runtime playback state — not saved with scene",
		}
	}


# ============================================================================
# animation_create_simple  (composer)
# ============================================================================

func create_simple(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")
	var anim_name: String = params.get("name", "")
	var tweens = params.get("tweens", [])
	var loop_mode_str: String = params.get("loop_mode", "none")

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")
	if anim_name.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: name")
	if typeof(tweens) != TYPE_ARRAY or tweens.is_empty():
		return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "tweens must be a non-empty array")
	if not _LOOP_MODES.has(loop_mode_str):
		return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE,
			"Invalid loop_mode '%s'. Valid: %s" % [loop_mode_str, ", ".join(_LOOP_MODES.keys())])

	# Validate all tween specs before touching the scene.
	var seen_paths := {}
	for spec in tweens:
		if typeof(spec) != TYPE_DICTIONARY:
			return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "Each tween spec must be a dictionary")
		for field in ["target", "property", "from", "to", "duration"]:
			if not field in spec:
				return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM,
					"Each tween spec must have '%s'" % field)
		if float(spec.get("duration", 0.0)) <= 0.0:
			return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE,
				"tween 'duration' must be > 0")
		var dup_key: String = str(spec.target) + ":" + str(spec.property)
		if seen_paths.has(dup_key):
			return ErrorCodes.make(ErrorCodes.INVALID_PARAMS,
				"Duplicate tween target '%s' — merge keyframes into a single track " % dup_key +
				"via animation_add_property_track instead of two separate tweens.")
		seen_paths[dup_key] = true

	# Compute/validate length before resolving the player — a fresh auto-created
	# AnimationPlayer is a detached Node that leaks if we return after creation.
	var has_length: bool = params.has("length") and params.get("length") != null
	var computed_length: float = 0.0
	if has_length:
		computed_length = float(params.get("length"))
		if computed_length <= 0.0:
			return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE,
				"'length' must be > 0 when provided (got %s)" % str(params.get("length")))
	else:
		for spec in tweens:
			var end_time: float = float(spec.get("delay", 0.0)) + float(spec.get("duration", 0.0))
			if end_time > computed_length:
				computed_length = end_time
		if computed_length <= 0.0:
			computed_length = 1.0

	var resolved := _resolve_player(player_path, true)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player
	var library: AnimationLibrary = resolved.library
	var created_player: bool = resolved.get("player_created", false)
	var player_parent: Node = resolved.get("player_parent", null)
	var created_library := false
	if library == null:
		library = AnimationLibrary.new()
		created_library = true

	var overwrite: bool = params.get("overwrite", false)
	var old_anim: Animation = null
	if library.has_animation(anim_name):
		if not overwrite:
			if created_player:
				player.queue_free()
			return ErrorCodes.make(ErrorCodes.INVALID_PARAMS,
				"Animation '%s' already exists. Pass overwrite=true or delete it first." % anim_name)
		old_anim = library.get_animation(anim_name)

	# Pre-coerce all tween values before touching the anim — coercion errors
	# surface as INVALID_PARAMS, not silent garbage keyframes.
	# When the player was auto-created, it isn't in the tree yet — pass its
	# future parent so the coercer can still resolve target property types.
	var coerce_root: Node = player_parent if created_player else null
	var per_track_keyframes: Array = []
	for spec in tweens:
		var target: String = str(spec.get("target", ""))
		var property: String = str(spec.get("property", ""))
		var track_path: String = target + ":" + property
		var duration: float = float(spec.get("duration", 1.0))
		var delay: float = float(spec.get("delay", 0.0))
		var trans_str = spec.get("transition", "linear")
		var from_result := AnimationValues.coerce_value_for_track(spec.get("from"), track_path, player, coerce_root)
		if from_result.has("error"):
			if created_player:
				player.queue_free()
			return ErrorCodes.make(ErrorCodes.INVALID_PARAMS, "tween '%s': %s" % [track_path, from_result.error])
		var to_result := AnimationValues.coerce_value_for_track(spec.get("to"), track_path, player, coerce_root)
		if to_result.has("error"):
			if created_player:
				player.queue_free()
			return ErrorCodes.make(ErrorCodes.INVALID_PARAMS, "tween '%s': %s" % [track_path, to_result.error])
		per_track_keyframes.append({
			"track_path": track_path,
			"keyframes": [
				{"time": delay, "value": from_result.ok, "transition": trans_str},
				{"time": delay + duration, "value": to_result.ok, "transition": trans_str},
			],
		})

	# Build the animation fully in memory before touching the undo stack.
	var anim := Animation.new()
	anim.length = computed_length
	anim.loop_mode = _LOOP_MODES[loop_mode_str]

	for entry in per_track_keyframes:
		_do_add_property_track(anim, entry.track_path, "linear", entry.keyframes)

	# One atomic undo action — bundles player creation (if any), library
	# creation (if any), and the animation add. A single Ctrl-Z rolls back all.
	_commit_animation_add("MCP: Create animation %s (%d tracks)" % [anim_name, anim.get_track_count()],
		player, library, created_library, anim_name, anim, old_anim,
		created_player, player_parent)

	return {
		"data": {
			"player_path": player_path,
			"name": anim_name,
			"length": computed_length,
			"loop_mode": loop_mode_str,
			"track_count": anim.get_track_count(),
			"library_created": created_library or created_player,
			"animation_player_created": created_player,
			"overwritten": old_anim != null,
			"undoable": true,
		}
	}


# ============================================================================
# Proxies — preset_* and read methods live in the submodules. Kept here so
# the dispatcher registrations and `_handler.method(...)` test fixtures stay
# unchanged across the split.
# ============================================================================

func preset_fade(params: Dictionary) -> Dictionary:
	return _presets.preset_fade(params)


func preset_slide(params: Dictionary) -> Dictionary:
	return _presets.preset_slide(params)


func preset_shake(params: Dictionary) -> Dictionary:
	return _presets.preset_shake(params)


func preset_pulse(params: Dictionary) -> Dictionary:
	return _presets.preset_pulse(params)


func preset_spin(params: Dictionary) -> Dictionary:
	return _presets.preset_spin(params)


func preset_bounce(params: Dictionary) -> Dictionary:
	return _presets.preset_bounce(params)



func list_animations(params: Dictionary) -> Dictionary:
	return _values.list_animations(params)


func get_animation(params: Dictionary) -> Dictionary:
	return _values.get_animation(params)


func validate_animation(params: Dictionary) -> Dictionary:
	return _values.validate_animation(params)


# ============================================================================
# Helpers — undo
# ============================================================================

## Shared undo setup for create_animation and create_simple. Handles fresh-
## create, overwrite, library auto-create, and player auto-create in a single
## atomic action. When `created_player` is true, the player already has the
## library attached (eagerly, from `_instantiate_player`) and the library
## doesn't need its own undo bookkeeping — it rides along with the add_child.
func _commit_animation_add(
	action_label: String,
	player: AnimationPlayer,
	library: AnimationLibrary,
	created_library: bool,
	anim_name: String,
	anim: Animation,
	old_anim: Animation,  ## null when not overwriting
	created_player: bool = false,
	player_parent: Node = null,
) -> void:
	_undo_redo.create_action(action_label)
	if created_player:
		var scene_root := EditorInterface.get_edited_scene_root()
		_undo_redo.add_do_method(player_parent, "add_child", player, true)
		_undo_redo.add_do_method(player, "set_owner", scene_root)
		_undo_redo.add_do_reference(player)
		_undo_redo.add_do_reference(library)
		_undo_redo.add_undo_method(player_parent, "remove_child", player)
	elif created_library:
		_undo_redo.add_do_method(player, "add_animation_library", "", library)
		_undo_redo.add_undo_method(player, "remove_animation_library", "")
		_undo_redo.add_do_reference(library)
	if old_anim != null:
		_undo_redo.add_do_method(library, "remove_animation", anim_name)
	_undo_redo.add_do_method(library, "add_animation", anim_name, anim)
	if old_anim != null:
		_undo_redo.add_undo_method(library, "remove_animation", anim_name)
		_undo_redo.add_undo_method(library, "add_animation", anim_name, old_anim)
		_undo_redo.add_do_reference(old_anim)
	else:
		_undo_redo.add_undo_method(library, "remove_animation", anim_name)
	_undo_redo.add_do_reference(anim)
	_undo_redo.commit_action()


## Open a `create_action` pinned to the edited scene's history.
##
## Without an explicit context, `add_do_method(self, ...)` against a
## RefCounted handler lands in GLOBAL_HISTORY while sibling actions whose
## first do-target is a Resource (e.g. AnimationLibrary) land in the scene's
## history. Mismatched histories make the test-side `editor_undo` helper
## (walks scene first) undo the wrong action, and break batch_handler's
## rollback. Mirrors `camera_handler.gd`'s identical pinning rationale.
func _create_scene_pinned_action(action_label: String) -> void:
	_undo_redo.create_action(
		action_label, UndoRedo.MERGE_DISABLE, EditorInterface.get_edited_scene_root(),
	)


# ============================================================================
# High-Level 2D Animation & Character State Tools
# ============================================================================

## Create a discrete keyframe track for Sprite2D frame stepping from a spritesheet.
func create_spritesheet_track(params: Dictionary) -> Dictionary:
	var player_path: String = params.get("player_path", "")
	var anim_name: String = params.get("animation_name", params.get("name", ""))
	var sprite_path: String = params.get("sprite_path", "")
	var hframes: int = int(params.get("hframes", 1))
	var vframes: int = int(params.get("vframes", 1))
	var start_frame: int = int(params.get("start_frame", 0))
	var frame_count: int = int(params.get("frame_count", 1))
	var fps: float = float(params.get("fps", 10.0))
	var loop: bool = bool(params.get("loop", true))

	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: player_path")
	if anim_name.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: animation_name")
	if sprite_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Missing required param: sprite_path")
	if frame_count <= 0 or fps <= 0.0:
		return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE, "frame_count and fps must be > 0")

	var resolved := _resolve_player(player_path, true)
	if resolved.has("error"):
		return resolved
	var player: AnimationPlayer = resolved.player
	var library: AnimationLibrary = resolved.library
	var created_player: bool = resolved.get("player_created", false)
	var player_parent: Node = resolved.get("player_parent", null)
	var created_library := false
	if library == null:
		library = AnimationLibrary.new()
		created_library = true

	var old_anim: Animation = null
	if library.has_animation(anim_name):
		old_anim = library.get_animation(anim_name)

	var duration: float = maxf(0.01, float(frame_count) / fps)
	var anim := Animation.new()
	anim.length = duration
	anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE

	var scene_root := EditorInterface.get_edited_scene_root()
	var sprite_node := McpScenePath.resolve(sprite_path, scene_root) if scene_root else null
	if sprite_node != null and (sprite_node is Sprite2D or sprite_node.has_method("set_hframes")):
		if hframes > 1:
			sprite_node.set("hframes", hframes)
		if vframes > 1:
			sprite_node.set("vframes", vframes)

	var rel_path: String = McpScenePath.path_relative_to(sprite_node, player) if sprite_node != null else sprite_path
	var track_path := "%s:frame" % rel_path

	var track_idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, track_path)
	anim.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_NEAREST)

	for i in range(frame_count):
		var t: float = float(i) / fps
		var frame_val: int = start_frame + i
		anim.track_insert_key(track_idx, t, frame_val)

	_commit_animation_add("MCP: Create spritesheet track %s" % anim_name,
		player, library, created_library, anim_name, anim, old_anim,
		created_player, player_parent)

	return {"data": {
		"animation_name": anim_name,
		"player_path": player_path,
		"sprite_path": sprite_path,
		"track_path": track_path,
		"frames": frame_count,
		"fps": fps,
		"duration": duration,
		"loop": loop,
		"undoable": true
	}}


## Scaffold complete spritesheet animations on a target node or scene.
## Configures Sprite2D (hframes, vframes, texture) and AnimationPlayer tracks for all states.
## params: {
##   target: String (scene path or node path),
##   texture: String (res:// path to spritesheet texture),
##   hframes: int,
##   vframes: int,
##   animations: Dictionary { "idle": [0,1,2,3], "walk_down": [4,5,6,7], ... },
##   fps: float (default 8.0),
##   loop: bool (default true),
##   sprite_name: String (default "Sprite2D"),
##   player_name: String (default "AnimationPlayer")
## }
func create_spritesheet_animation(params: Dictionary) -> Dictionary:
	var target_spec: String = params.get("target", params.get("target_path", ""))
	if target_spec.ends_with(".tscn") and ResourceLoader.exists(target_spec):
		var cur_root := EditorInterface.get_edited_scene_root()
		if cur_root == null or cur_root.scene_file_path != target_spec:
			EditorInterface.open_scene_from_path(target_spec)

	var _scene_check := McpNodeValidator.require_scene_or_error()
	if _scene_check.has("error"): return _scene_check
	var scene_root: Node = _scene_check.scene_root

	var target_node: Node = scene_root
	if not target_spec.is_empty() and not target_spec.ends_with(".tscn"):
		target_node = McpScenePath.resolve(target_spec, scene_root)
		if target_node == null:
			return ErrorCodes.make(ErrorCodes.NODE_NOT_FOUND, McpScenePath.format_node_error(target_spec, scene_root))

	var texture_path: String = params.get("texture", params.get("texture_path", ""))
	var hframes: int = int(params.get("hframes", 1))
	var vframes: int = int(params.get("vframes", 1))
	var anim_defs: Dictionary = params.get("animations", {})
	var fps: float = float(params.get("fps", 8.0))
	var loop: bool = bool(params.get("loop", true))
	var sprite_name: String = params.get("sprite_name", params.get("sprite_node_name", "Sprite2D"))
	var player_name: String = params.get("player_name", params.get("player_node_name", "AnimationPlayer"))

	# Find or instantiate Sprite2D
	var sprite: Sprite2D = null
	var sprite_created := false
	if target_node.has_node(sprite_name):
		var candidate = target_node.get_node(sprite_name)
		if candidate is Sprite2D:
			sprite = candidate
	if sprite == null:
		if target_node is Sprite2D:
			sprite = target_node
		else:
			for child in target_node.get_children():
				if child is Sprite2D:
					sprite = child
					break
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = sprite_name
		sprite_created = true

	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		var tex = load(texture_path)
		if tex is Texture2D:
			sprite.texture = tex
	if hframes > 0:
		sprite.hframes = hframes
	if vframes > 0:
		sprite.vframes = vframes
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	# Find or instantiate AnimationPlayer
	var player: AnimationPlayer = null
	var player_created := false
	if target_node.has_node(player_name):
		var candidate = target_node.get_node(player_name)
		if candidate is AnimationPlayer:
			player = candidate
	if player == null:
		for child in target_node.get_children():
			if child is AnimationPlayer:
				player = child
				break
	if player == null:
		player = AnimationPlayer.new()
		player.name = player_name
		player_created = true

	var lib: AnimationLibrary = null
	if player.has_animation_library(""):
		lib = player.get_animation_library("")
	else:
		lib = AnimationLibrary.new()
		player.add_animation_library("", lib)

	var created_anims: Array = []
	var root_target: Node = target_node
	if not player.root_node.is_empty():
		var explicit_root = player.get_node_or_null(player.root_node)
		if explicit_root != null:
			root_target = explicit_root
	var rel_sprite_path := String(root_target.get_path_to(sprite))
	var track_path := "%s:frame" % rel_sprite_path

	for anim_name_key in anim_defs.keys():
		var anim_name := String(anim_name_key)
		var raw_frames: Variant = anim_defs[anim_name_key]
		var frames: Array = []
		if raw_frames is Array:
			frames = raw_frames
		var anim := Animation.new()
		var duration := maxf(0.05, float(frames.size()) / maxf(1.0, fps))
		anim.length = duration
		anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE

		var track_idx := anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track_idx, track_path)
		anim.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)
		anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_NEAREST)

		for i in range(frames.size()):
			var t: float = float(i) / maxf(1.0, fps)
			var frame_val: int = int(frames[i])
			anim.track_insert_key(track_idx, t, frame_val)

		if lib.has_animation(anim_name):
			lib.remove_animation(anim_name)
		lib.add_animation(anim_name, anim)
		created_anims.append({
			"name": anim_name,
			"frames": frames.size(),
			"duration": duration,
			"loop": loop
		})

	_undo_redo.create_action("MCP: Create spritesheet animation (%d animations)" % created_anims.size())
	if sprite_created:
		_undo_redo.add_do_method(target_node, "add_child", sprite, true)
		_undo_redo.add_do_method(sprite, "set_owner", scene_root)
		_undo_redo.add_do_reference(sprite)
		_undo_redo.add_undo_method(target_node, "remove_child", sprite)
	if player_created:
		_undo_redo.add_do_method(target_node, "add_child", player, true)
		_undo_redo.add_do_method(player, "set_owner", scene_root)
		_undo_redo.add_do_reference(player)
		_undo_redo.add_undo_method(target_node, "remove_child", player)
	_undo_redo.commit_action()

	return {"data": {
		"target": McpScenePath.from_node(target_node, scene_root),
		"sprite_path": McpScenePath.from_node(sprite, scene_root),
		"player_path": McpScenePath.from_node(player, scene_root),
		"animations": created_anims,
		"fps": fps,
		"loop": loop,
		"undoable": true
	}}


## Create an AnimatedSprite2D node and slice frames into a SpriteFrames resource.
func create_animated_sprite(params: Dictionary) -> Dictionary:
	var _scene_check := McpNodeValidator.require_scene_or_error()
	if _scene_check.has("error"): return _scene_check
	var scene_root: Node = _scene_check.scene_root

	var parent_path: String = params.get("parent_path", "")
	var parent: Node = scene_root
	if not parent_path.is_empty():
		parent = McpScenePath.resolve(parent_path, scene_root)
		if parent == null:
			return ErrorCodes.make(ErrorCodes.NODE_NOT_FOUND, McpScenePath.format_parent_error(parent_path, scene_root))

	var node_name: String = params.get("node_name", params.get("name", "AnimatedSprite2D"))
	var texture_path: String = params.get("texture_path", "")
	var anim_name: String = params.get("animation_name", "default")
	var hframes: int = int(params.get("hframes", 1))
	var vframes: int = int(params.get("vframes", 1))
	var start_frame: int = int(params.get("start_frame", 0))
	var frame_count: int = int(params.get("frame_count", 1))
	var fps: float = float(params.get("fps", 10.0))
	var loop: bool = bool(params.get("loop", true))
	var save_frames_path: String = params.get("save_frames_path", "")

	var sprite := AnimatedSprite2D.new()
	sprite.name = node_name
	var sprite_frames := SpriteFrames.new()

	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		var tex = load(texture_path)
		if tex is Texture2D:
			var tex_w: int = tex.get_width()
			var tex_h: int = tex.get_height()
			var cell_w: float = float(tex_w) / maxf(1.0, float(hframes))
			var cell_h: float = float(tex_h) / maxf(1.0, float(vframes))

			if not sprite_frames.has_animation(anim_name):
				sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, fps)
			sprite_frames.set_animation_loop(anim_name, loop)

			for i in range(frame_count):
				var f_idx := start_frame + i
				var col: int = f_idx % hframes
				var row: int = int(f_idx / hframes)
				var atlas_tex := AtlasTexture.new()
				atlas_tex.atlas = tex
				atlas_tex.region = Rect2(col * cell_w, row * cell_h, cell_w, cell_h)
				sprite_frames.add_frame(anim_name, atlas_tex)

	sprite.sprite_frames = sprite_frames
	sprite.animation = anim_name

	if not save_frames_path.is_empty():
		ResourceSaver.save(sprite_frames, save_frames_path)

	_undo_redo.create_action("MCP: Create AnimatedSprite2D %s" % sprite.name)
	_undo_redo.add_do_method(parent, "add_child", sprite, true)
	_undo_redo.add_do_method(sprite, "set_owner", scene_root)
	_undo_redo.add_do_reference(sprite)
	_undo_redo.add_do_reference(sprite_frames)
	_undo_redo.add_undo_method(parent, "remove_child", sprite)
	_undo_redo.commit_action()

	return {"data": {
		"path": McpScenePath.from_node(sprite, scene_root),
		"name": String(sprite.name),
		"animation": anim_name,
		"frames": frame_count,
		"fps": fps,
		"undoable": true
	}}


## Scaffold an AnimationTree with an AnimationNodeStateMachine preset.
func scaffold_state_machine(params: Dictionary) -> Dictionary:
	var _scene_check := McpNodeValidator.require_scene_or_error()
	if _scene_check.has("error"): return _scene_check
	var scene_root: Node = _scene_check.scene_root

	var parent_path: String = params.get("parent_path", "")
	var parent: Node = scene_root
	if not parent_path.is_empty():
		parent = McpScenePath.resolve(parent_path, scene_root)
		if parent == null:
			return ErrorCodes.make(ErrorCodes.NODE_NOT_FOUND, McpScenePath.format_parent_error(parent_path, scene_root))

	var player_path: String = params.get("player_path", "")
	var states: Array = params.get("states", ["idle", "run", "jump", "fall"])
	var tree_name: String = params.get("name", "AnimationTree")

	var tree := AnimationTree.new()
	tree.name = tree_name

	var state_machine := AnimationNodeStateMachine.new()
	for s_name in states:
		var node_anim := AnimationNodeAnimation.new()
		node_anim.animation = str(s_name)
		state_machine.add_node(str(s_name), node_anim)

	if not states.is_empty():
		var start_trans := AnimationNodeStateMachineTransition.new()
		start_trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		state_machine.add_transition("Start", str(states[0]), start_trans)

	if states.has("idle") and states.has("run"):
		var t_ir := AnimationNodeStateMachineTransition.new()
		var t_ri := AnimationNodeStateMachineTransition.new()
		state_machine.add_transition("idle", "run", t_ir)
		state_machine.add_transition("run", "idle", t_ri)

	if states.has("idle") and states.has("jump"):
		var t_ij := AnimationNodeStateMachineTransition.new()
		state_machine.add_transition("idle", "jump", t_ij)

	if states.has("run") and states.has("jump"):
		var t_rj := AnimationNodeStateMachineTransition.new()
		state_machine.add_transition("run", "jump", t_rj)

	if states.has("jump") and states.has("fall"):
		var t_jf := AnimationNodeStateMachineTransition.new()
		t_jf.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		state_machine.add_transition("jump", "fall", t_jf)

	if states.has("fall") and states.has("idle"):
		var t_fi := AnimationNodeStateMachineTransition.new()
		state_machine.add_transition("fall", "idle", t_fi)

	tree.tree_root = state_machine
	if not player_path.is_empty():
		var player_node := McpScenePath.resolve(player_path, scene_root)
		if player_node != null:
			tree.anim_player = tree.get_path_to(player_node)
	tree.active = true

	_undo_redo.create_action("MCP: Scaffold AnimationTree State Machine")
	_undo_redo.add_do_method(parent, "add_child", tree, true)
	_undo_redo.add_do_method(tree, "set_owner", scene_root)
	_undo_redo.add_do_reference(tree)
	_undo_redo.add_do_reference(state_machine)
	_undo_redo.add_undo_method(parent, "remove_child", tree)
	_undo_redo.commit_action()

	return {"data": {
		"path": McpScenePath.from_node(tree, scene_root),
		"name": String(tree.name),
		"states": states,
		"player_path": player_path,
		"undoable": true
	}}


## Scaffold an AnimationTree with an AnimationNodeStateMachine and AnimationNodeBlendSpace2D
## nodes configured for 4-way or 8-way locomotion.
## params: {player_path, states: {StateName: {pos: anim_name}}, name="AnimationTree", blend_mode="discrete"|"interpolated"}
func scaffold_locomotion_tree(params: Dictionary) -> Dictionary:
	var _scene_check := McpNodeValidator.require_scene_or_error()
	if _scene_check.has("error"):
		return _scene_check
	var scene_root: Node = _scene_check.scene_root

	var player_path: String = params.get("player_path", "")
	if player_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Parameter 'player_path' is required")

	var target_node := McpScenePath.resolve(player_path, scene_root)
	if target_node == null:
		return ErrorCodes.make(ErrorCodes.NODE_NOT_FOUND, McpScenePath.format_node_error(player_path, scene_root))

	var anim_player: AnimationPlayer = null
	if target_node is AnimationPlayer:
		anim_player = target_node
	else:
		anim_player = target_node.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if anim_player == null and target_node.get_parent() != null:
			anim_player = target_node.get_parent().find_child("AnimationPlayer", true, false) as AnimationPlayer

	var parent: Node = target_node if not (target_node is AnimationPlayer) else target_node.get_parent()
	if parent == null: parent = scene_root

	var tree_name: String = params.get("name", "AnimationTree")
	var blend_mode_str: String = str(params.get("blend_mode", "interpolated")).to_lower()
	var blend_mode_val := AnimationNodeBlendSpace2D.BLEND_MODE_INTERPOLATED
	if blend_mode_str == "discrete":
		blend_mode_val = AnimationNodeBlendSpace2D.BLEND_MODE_DISCRETE

	var raw_states: Dictionary = params.get("states", {})
	if raw_states.is_empty():
		raw_states = {
			"Idle": {"(0, 1)": "idle_down", "(0, -1)": "idle_up", "(-1, 0)": "idle_left", "(1, 0)": "idle_right"},
			"Walk": {"(0, 1)": "walk_down", "(0, -1)": "walk_up", "(-1, 0)": "walk_left", "(1, 0)": "walk_right"}
		}

	var tree := AnimationTree.new()
	tree.name = tree_name

	var state_machine := AnimationNodeStateMachine.new()
	var configured_states: Array[String] = []

	for s_name in raw_states.keys():
		var state_str := str(s_name)
		var blend_space := AnimationNodeBlendSpace2D.new()
		blend_space.blend_mode = blend_mode_val

		var blend_points: Dictionary = raw_states[s_name]
		for key in blend_points.keys():
			var anim_name: String = str(blend_points[key])
			var pos := _parse_2d_coord(key)
			var node_anim := AnimationNodeAnimation.new()
			node_anim.animation = anim_name
			blend_space.add_blend_point(node_anim, pos)

		state_machine.add_node(state_str, blend_space)
		configured_states.append(state_str)

	if not configured_states.is_empty():
		var first_state := configured_states[0]
		var start_trans := AnimationNodeStateMachineTransition.new()
		start_trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		state_machine.add_transition("Start", first_state, start_trans)

	var idle_name := ""
	var move_name := ""
	for s in configured_states:
		var s_lower := s.to_lower()
		if s_lower == "idle": idle_name = s
		elif s_lower == "walk" or s_lower == "run" or s_lower == "move": move_name = s

	if not idle_name.is_empty() and not move_name.is_empty():
		var t_to_move := AnimationNodeStateMachineTransition.new()
		var t_to_idle := AnimationNodeStateMachineTransition.new()
		state_machine.add_transition(idle_name, move_name, t_to_move)
		state_machine.add_transition(move_name, idle_name, t_to_idle)

	tree.tree_root = state_machine
	if anim_player != null:
		tree.anim_player = tree.get_path_to(anim_player)
	tree.active = true

	_undo_redo.create_action("MCP: Scaffold AnimationTree Locomotion")
	_undo_redo.add_do_method(parent, "add_child", tree, true)
	_undo_redo.add_do_method(tree, "set_owner", scene_root)
	_undo_redo.add_do_reference(tree)
	_undo_redo.add_do_reference(state_machine)
	_undo_redo.add_undo_method(parent, "remove_child", tree)
	_undo_redo.commit_action()

	return {"data": {
		"path": McpScenePath.from_node(tree, scene_root),
		"name": String(tree.name),
		"states": configured_states,
		"player_path": McpScenePath.from_node(parent, scene_root),
		"anim_player_path": McpScenePath.from_node(anim_player, scene_root) if anim_player != null else "",
		"undoable": true
	}}


func _parse_2d_coord(key: Variant) -> Vector2:
	if key is Vector2:
		return key
	if key is Array and key.size() >= 2:
		return Vector2(float(key[0]), float(key[1]))
	if key is Dictionary:
		return Vector2(float(key.get("x", 0)), float(key.get("y", 0)))
	var s := str(key).strip_edges().trim_prefix("(").trim_suffix(")").trim_prefix("[").trim_suffix("]")
	var parts := s.split(",")
	if parts.size() >= 2:
		return Vector2(float(parts[0].strip_edges()), float(parts[1].strip_edges()))
	return Vector2.ZERO


# ============================================================================
# Helpers — resolution
# ============================================================================

## Resolve an AnimationPlayer and its default library for write operations.
## Returns {player, library, player_created, player_parent} on success, or an
## error dict. library is null if the player exists but has no default library
## yet — callers bundle an `add_animation_library` step into their undo action.
##
## When `create_if_missing` is true and `player_path` resolves to nothing, a
## fresh AnimationPlayer is instantiated (with an empty default library attached
## eagerly) but is NOT added to the scene tree — callers must bundle the
## add_child step into their undo action via `_commit_animation_add`.
## If the resolved node exists but isn't an AnimationPlayer, that's still an
## error — we don't clobber an existing node of a different type.
func _resolve_player(player_path: String, create_if_missing: bool = false) -> Dictionary:
	var _scene_check := McpNodeValidator.require_scene_or_error()
	if _scene_check.has("error"):
		return _scene_check
	var scene_root: Node = _scene_check.scene_root
	var node := McpScenePath.resolve(player_path, scene_root)
	if node == null:
		if not create_if_missing:
			return ErrorCodes.make(ErrorCodes.NODE_NOT_FOUND, McpScenePath.format_node_error(player_path, scene_root))
		return _instantiate_player(player_path, scene_root)
	if not node is AnimationPlayer:
		return ErrorCodes.make(ErrorCodes.WRONG_TYPE,
			"Node at %s is not an AnimationPlayer (got %s)" % [player_path, node.get_class()])
	var player := node as AnimationPlayer
	var lib: AnimationLibrary = null
	if player.has_animation_library(""):
		lib = player.get_animation_library("")
	return {"player": player, "library": lib, "player_created": false, "player_parent": null}


## Build a new AnimationPlayer (with empty default library) for insertion under
## the parent implied by `player_path`. Returns an error dict if the parent
## can't be resolved or the path has no usable leaf name.
func _instantiate_player(player_path: String, scene_root: Node) -> Dictionary:
	var slash := player_path.rfind("/")
	var parent_path: String
	var player_name: String
	if slash < 0:
		parent_path = ""
		player_name = player_path
	else:
		parent_path = player_path.substr(0, slash)
		player_name = player_path.substr(slash + 1)
	if player_name.is_empty():
		return ErrorCodes.make(ErrorCodes.INVALID_PARAMS,
			"Cannot auto-create AnimationPlayer: player_path '%s' has no leaf name" % player_path)
	var parent: Node
	if parent_path.is_empty():
		parent = scene_root
	else:
		parent = McpScenePath.resolve(parent_path, scene_root)
	if parent == null:
		return ErrorCodes.make(ErrorCodes.NODE_NOT_FOUND,
			"Cannot auto-create AnimationPlayer at %s: %s" % [
				player_path, McpScenePath.format_parent_error(parent_path, scene_root)])
	var new_player := AnimationPlayer.new()
	new_player.name = player_name
	var lib := AnimationLibrary.new()
	new_player.add_animation_library("", lib)
	return {
		"player": new_player,
		"library": lib,
		"player_created": true,
		"player_parent": parent,
	}


## Resolve for read operations (no library requirement).
func _resolve_player_read(player_path: String) -> Dictionary:
	var resolved := McpNodeValidator.resolve_or_error(player_path, "player_path")
	if resolved.has("error"):
		return resolved
	var node: Node = resolved.node
	if not node is AnimationPlayer:
		return ErrorCodes.make(ErrorCodes.WRONG_TYPE,
			"Node at %s is not an AnimationPlayer (got %s)" % [player_path, node.get_class()])
	return {"player": node as AnimationPlayer}


## Resolve an animation by name, searching all libraries.
## Accepts bare clip names ("idle") and library-qualified names ("moves/idle")
## as returned by `list_animations` for non-default libraries.
func _resolve_animation(player: AnimationPlayer, anim_name: String) -> Dictionary:
	if not player.has_animation(anim_name):
		return ErrorCodes.make(ErrorCodes.PROPERTY_NOT_ON_CLASS,
			"Animation '%s' not found on player. Available: %s" % [
				anim_name,
				", ".join(Array(player.get_animation_list()))
			])
	# If the caller passed "library/clip", look up in that specific library.
	var slash := anim_name.find("/")
	if slash >= 0:
		var lib_key := anim_name.substr(0, slash)
		var clip_key := anim_name.substr(slash + 1)
		if player.has_animation_library(lib_key):
			var lib: AnimationLibrary = player.get_animation_library(lib_key)
			if lib.has_animation(clip_key):
				return {"animation": lib.get_animation(clip_key), "library": lib, "library_key": lib_key}
	# Otherwise scan libraries for a bare clip name.
	for lib_name in player.get_animation_library_list():
		var lib2: AnimationLibrary = player.get_animation_library(lib_name)
		if lib2.has_animation(anim_name):
			return {"animation": lib2.get_animation(anim_name), "library": lib2, "library_key": lib_name}
	# Fallback — shouldn't happen if has_animation returned true.
	return ErrorCodes.make(ErrorCodes.INTERNAL_ERROR, "Animation found by player but not in any library")
