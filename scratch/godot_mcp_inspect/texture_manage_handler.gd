@tool
extends "res://addons/godot_ai/handlers/command_handler.gd"

const ErrorCodes := preload("res://addons/godot_ai/utils/error_codes.gd")

## Handles Image/Texture resources, AtlasTexture, and inspection.

var _undo_redo: EditorUndoRedoManager
var _connection: McpConnection


func _init(undo_redo: EditorUndoRedoManager = null, connection: McpConnection = null) -> void:
	_undo_redo = undo_redo
	_connection = connection


func create_image(params: Dictionary) -> Dictionary:
	var width: int = int(params.get("width", 64))
	var height: int = int(params.get("height", 64))
	var use_mipmaps: bool = params.get("use_mipmaps", false)
	var format_str: String = params.get("format", "rgba8").to_lower()
	var save_path: String = params.get("save_path", "")

	var img_format := Image.FORMAT_RGBA8
	if format_str == "rgb8":
		img_format = Image.FORMAT_RGB8
	elif format_str == "r8":
		img_format = Image.FORMAT_R8

	var img := Image.create(width, height, use_mipmaps, img_format)
	if params.has("fill_color"):
		var col_str: String = str(params["fill_color"])
		img.fill(Color.from_string(col_str, Color.WHITE))

	if not save_path.is_empty():
		if not save_path.begins_with("res://") and not save_path.begins_with("user://"):
			save_path = "res://" + save_path
		var err := img.save_png(save_path)
		if err != OK:
			return {"error": "Failed to save image to: %s" % save_path, "code": ErrorCodes.RESOURCE_OPERATION_FAILED}

	return {
		"success": true,
		"width": width,
		"height": height,
		"format": format_str,
		"save_path": save_path
	}


func create_atlas(params: Dictionary) -> Dictionary:
	var atlas_path: String = params.get("atlas_path", "")
	var region_array: Array = params.get("region_rect", [0, 0, 32, 32])
	var filter_clip: bool = params.get("filter_clip", false)
	var save_path: String = params.get("save_path", "")

	if atlas_path.is_empty():
		return {"error": "atlas_path is required", "code": ErrorCodes.INVALID_ARGUMENTS}
	if not atlas_path.begins_with("res://"):
		atlas_path = "res://" + atlas_path

	if not ResourceLoader.exists(atlas_path):
		return {"error": "Atlas resource does not exist: %s" % atlas_path, "code": ErrorCodes.RESOURCE_NOT_FOUND}

	var base_tex = load(atlas_path)
	if not base_tex is Texture2D:
		return {"error": "Target resource is not a Texture2D: %s" % atlas_path, "code": ErrorCodes.WRONG_TYPE}

	var atlas_tex := AtlasTexture.new()
	atlas_tex.atlas = base_tex
	if region_array.size() >= 4:
		atlas_tex.region = Rect2(region_array[0], region_array[1], region_array[2], region_array[3])
	atlas_tex.filter_clip = filter_clip

	if not save_path.is_empty():
		if not save_path.begins_with("res://"):
			save_path = "res://" + save_path
		var err := ResourceSaver.save(atlas_tex, save_path)
		if err != OK:
			return {"error": "Failed to save AtlasTexture to: %s" % save_path, "code": ErrorCodes.RESOURCE_OPERATION_FAILED}

	return {
		"success": true,
		"atlas_path": atlas_path,
		"save_path": save_path,
		"region": [atlas_tex.region.position.x, atlas_tex.region.position.y, atlas_tex.region.size.x, atlas_tex.region.size.y]
	}


func get_texture_info(params: Dictionary) -> Dictionary:
	var path: String = params.get("path", "")
	if path.is_empty():
		return {"error": "path is required", "code": ErrorCodes.INVALID_ARGUMENTS}
	if not path.begins_with("res://"):
		path = "res://" + path

	if not ResourceLoader.exists(path):
		return {"error": "Texture file not found: %s" % path, "code": ErrorCodes.RESOURCE_NOT_FOUND}

	var res = load(path)
	if not res is Texture2D:
		return {"error": "Resource is not a Texture2D: %s" % path, "code": ErrorCodes.WRONG_TYPE}

	var tex: Texture2D = res
	return {
		"success": true,
		"path": path,
		"width": tex.get_width(),
		"height": tex.get_height(),
		"class": tex.get_class()
	}


func create_curve_texture(params: Dictionary) -> Dictionary:
	var points: Array = params.get("points", [[0.0, 0.0], [1.0, 1.0]])
	var width: int = int(params.get("width", 256))
	var save_path: String = params.get("save_path", "")

	var curve := Curve.new()
	for pt in points:
		if pt is Array and pt.size() >= 2:
			curve.add_point(Vector2(float(pt[0]), float(pt[1])))

	var tex := CurveTexture.new()
	tex.curve = curve
	tex.width = width

	if not save_path.is_empty():
		if not save_path.begins_with("res://"):
			save_path = "res://" + save_path
		var err := ResourceSaver.save(tex, save_path)
		if err != OK:
			return {"error": "Failed to save CurveTexture to: %s" % save_path, "code": ErrorCodes.RESOURCE_OPERATION_FAILED}

	return {
		"success": true,
		"width": width,
		"points_count": points.size(),
		"save_path": save_path
	}
