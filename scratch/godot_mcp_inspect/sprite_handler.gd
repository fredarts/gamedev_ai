@tool
extends "res://addons/godot_ai/handlers/command_handler.gd"

const ErrorCodes := preload("res://addons/godot_ai/utils/error_codes.gd")

## Handles 2D/3D sprites, SpriteFrames, MultiMeshInstance, and Line2D.

var _undo_redo: EditorUndoRedoManager
var _connection: McpConnection


func _init(undo_redo: EditorUndoRedoManager = null, connection: McpConnection = null) -> void:
	_undo_redo = undo_redo
	_connection = connection


func _get_scene_root() -> Node:
	if Engine.is_editor_hint():
		var tree := Engine.get_main_loop() as SceneTree
		if tree != null and Engine.has_singleton("EditorInterface"):
			var editor_interface := Engine.get_singleton("EditorInterface")
			if editor_interface.has_method("get_edited_scene_root"):
				var root: Node = editor_interface.get_edited_scene_root()
				if root != null:
					return root
		if tree != null and tree.edited_scene_root != null:
			return tree.edited_scene_root
		if tree != null and tree.current_scene != null:
			return tree.current_scene
		if tree != null and tree.root != null:
			return tree.root
	return null


func _resolve_node(scene_root: Node, node_path: String) -> Node:
	if node_path.is_empty():
		return scene_root
	return scene_root.get_node_or_null(NodePath(node_path))


func create_sprite_frames(params: Dictionary) -> Dictionary:
	var sf := SpriteFrames.new()
	var animations: Array = params.get("animations", [])
	var save_path: String = params.get("save_path", "")

	for anim in animations:
		if anim is Dictionary:
			var anim_name: String = anim.get("name", "default")
			if not sf.has_animation(StringName(anim_name)):
				sf.add_animation(StringName(anim_name))
			sf.set_animation_speed(StringName(anim_name), float(anim.get("fps", 5.0)))
			sf.set_animation_loop(StringName(anim_name), bool(anim.get("loop", true)))

	if not save_path.is_empty():
		if not save_path.begins_with("res://"):
			save_path = "res://" + save_path
		var err := ResourceSaver.save(sf, save_path)
		if err != OK:
			return {"error": "Failed to save SpriteFrames to: %s" % save_path, "code": ErrorCodes.RESOURCE_OPERATION_FAILED}

	return {
		"success": true,
		"animation_count": sf.get_animation_names().size(),
		"save_path": save_path
	}


func scaffold_animated_sprite(params: Dictionary) -> Dictionary:
	var scene_root := _get_scene_root()
	if scene_root == null:
		return {"error": "No edited scene root available", "code": ErrorCodes.SCENE_NOT_FOUND}

	var parent_path: String = params.get("parent_path", "")
	var parent: Node = _resolve_node(scene_root, parent_path)
	if parent == null:
		return {"error": "Parent node not found: %s" % parent_path, "code": ErrorCodes.NODE_NOT_FOUND}

	var sprite_type: String = params.get("sprite_type", "2d").to_lower()
	var node: Node
	if sprite_type == "3d":
		var s3 := AnimatedSprite3D.new()
		node = s3
	else:
		var s2 := AnimatedSprite2D.new()
		node = s2

	node.name = params.get("node_name", "AnimatedSprite")
	var frames_path: String = params.get("sprite_frames_path", "")
	if not frames_path.is_empty():
		if not frames_path.begins_with("res://"):
			frames_path = "res://" + frames_path
		if ResourceLoader.exists(frames_path):
			var res = load(frames_path)
			if res is SpriteFrames:
				node.set("sprite_frames", res)

	parent.add_child(node)
	node.owner = scene_root

	return {
		"success": true,
		"node_path": str(node.get_path()),
		"sprite_type": sprite_type
	}


func scaffold_multimesh(params: Dictionary) -> Dictionary:
	var scene_root := _get_scene_root()
	if scene_root == null:
		return {"error": "No edited scene root available", "code": ErrorCodes.SCENE_NOT_FOUND}

	var parent_path: String = params.get("parent_path", "")
	var parent: Node = _resolve_node(scene_root, parent_path)
	if parent == null:
		return {"error": "Parent node not found: %s" % parent_path, "code": ErrorCodes.NODE_NOT_FOUND}

	var is_2d: bool = params.get("is_2d", false)
	var instance_count: int = int(params.get("instance_count", 100))
	var node: Node

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D if is_2d else MultiMesh.TRANSFORM_3D
	mm.instance_count = instance_count

	if is_2d:
		var mmi2 := MultiMeshInstance2D.new()
		mmi2.multimesh = mm
		node = mmi2
	else:
		var mmi3 := MultiMeshInstance3D.new()
		var mesh_type: String = params.get("mesh_type", "box").to_lower()
		var primitive: PrimitiveMesh = BoxMesh.new()
		if mesh_type == "sphere":
			primitive = SphereMesh.new()
		elif mesh_type == "cylinder":
			primitive = CylinderMesh.new()
		mm.mesh = primitive
		mmi3.multimesh = mm
		node = mmi3

	node.name = params.get("node_name", "MultiMeshInstance")
	parent.add_child(node)
	node.owner = scene_root

	return {
		"success": true,
		"node_path": str(node.get_path()),
		"instance_count": instance_count,
		"is_2d": is_2d
	}


func configure_line_2d(params: Dictionary) -> Dictionary:
	var scene_root := _get_scene_root()
	if scene_root == null:
		return {"error": "No edited scene root available", "code": ErrorCodes.SCENE_NOT_FOUND}

	var node_path: String = params.get("node_path", "")
	var node: Node = _resolve_node(scene_root, node_path)
	if not node is Line2D:
		return {"error": "Target node is not a Line2D: %s" % node_path, "code": ErrorCodes.WRONG_TYPE}

	var line: Line2D = node
	var pts_array: Array = params.get("points", [])
	var packed_pts := PackedVector2Array()
	for pt in pts_array:
		if pt is Array and pt.size() >= 2:
			packed_pts.append(Vector2(float(pt[0]), float(pt[1])))

	if not packed_pts.is_empty():
		line.points = packed_pts

	if params.has("width"):
		line.width = float(params["width"])
	if params.has("default_color"):
		line.default_color = Color.from_string(str(params["default_color"]), Color.WHITE)

	return {
		"success": true,
		"node_path": node_path,
		"points_count": line.points.size(),
		"width": line.width
	}
