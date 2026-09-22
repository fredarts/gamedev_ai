@tool
extends "res://addons/godot_ai/handlers/command_handler.gd"

## TileSet management — atlas inspection helpers.

const ErrorCodes := preload("res://addons/godot_ai/utils/error_codes.gd")


func _init() -> void:
	pass


## Query all occupied atlas tile positions for a single source.
##
## params:
##   tileset_path  — res:// path to the TileSet resource (required, non-empty)
##   source_id     — raw TileSet source id (required)
##
## Returns:
##   {"data": {"tiles": [{"col": int, "row": int}, ...], "count": int}}
##     on success (including empty sources, where tiles=[] and count=0)
##   ErrorCodes.make(code, message)  on any validation or load failure
##
## Error codes:
##   MISSING_REQUIRED_PARAM  — tileset_path absent/empty, or source_id absent
##   RESOURCE_NOT_FOUND      — ResourceLoader.exists(tileset_path) is false
##   WRONG_TYPE              — loaded resource is not a TileSet, or source is
##                             not a TileSetAtlasSource
##   VALUE_OUT_OF_RANGE      — source_id not present in TileSet
##
## This method is read-only: it never calls ResourceSaver or modifies any resource.
func get_atlas_tiles(params: Dictionary) -> Dictionary:
	var resolved := _resolve_atlas_source(params)
	if resolved.has("error"):
		return resolved
	var src: TileSetAtlasSource = resolved.src

	var tiles: Array = []
	for i in range(src.get_tiles_count()):
		var v: Vector2i = src.get_tile_id(i)
		tiles.append({"col": v.x, "row": v.y})

	return {"data": {"tiles": tiles, "count": tiles.size()}}


## Return the atlas texture of a TileSetAtlasSource as a Base64-encoded PNG.
##
## params:
##   tileset_path  — res:// path to the TileSet resource (required, non-empty)
##   source_id     — raw TileSet source id (required)
##   max_size      — optional int; if > 0, the image is scaled so its longest
##                   edge is at most max_size pixels (default 0 = full res)
##
## Returns:
##   {"data": {"image_base64": String, "width": int, "height": int,
##             "original_width": int, "original_height": int, "format": "png"}}
##     on success
##   ErrorCodes.make(code, message)  on any validation or load failure
##
## Error codes:
##   MISSING_REQUIRED_PARAM  — tileset_path absent/empty, or source_id absent
##   RESOURCE_NOT_FOUND      — ResourceLoader.exists(tileset_path) is false
##   WRONG_TYPE              — loaded resource is not a TileSet, or source is
##                             not a TileSetAtlasSource, or texture is null
##   VALUE_OUT_OF_RANGE      — source_id not present in TileSet
##
## This method is read-only: it never calls ResourceSaver or modifies anything.
func get_atlas_image(params: Dictionary) -> Dictionary:
	var resolved := _resolve_atlas_source(params)
	if resolved.has("error"):
		return resolved
	var source_id: int = resolved.source_id
	var src: TileSetAtlasSource = resolved.src

	var tex: Texture2D = src.texture
	if tex == null:
		return ErrorCodes.make(
			ErrorCodes.WRONG_TYPE,
			"Source %d has no texture assigned" % source_id
		)

	var img: Image = tex.get_image()
	if img == null:
		return ErrorCodes.make(
			ErrorCodes.WRONG_TYPE,
			"Could not retrieve image data from texture of source %d" % source_id
		)
	if img.is_compressed():
		var decompress_err := img.decompress()
		if decompress_err != OK:
			return ErrorCodes.make(
				ErrorCodes.INTERNAL_ERROR,
				"Could not decompress texture of source %d: %s" % [source_id, error_string(decompress_err)]
			)

	var original_width: int = img.get_width()
	var original_height: int = img.get_height()

	var max_size: int = params.get("max_size", 0)
	if max_size > 0:
		var longest_edge: int = max(original_width, original_height)
		if longest_edge > max_size:
			var scale: float = float(max_size) / float(longest_edge)
			var new_w: int = max(1, int(original_width * scale))
			var new_h: int = max(1, int(original_height * scale))
			img.resize(new_w, new_h, Image.INTERPOLATE_LANCZOS)

	var png_bytes: PackedByteArray = img.save_png_to_buffer()
	if png_bytes.is_empty():
		return ErrorCodes.make(
			ErrorCodes.INTERNAL_ERROR,
			"PNG encoding produced empty output for source %d" % source_id
		)
	var b64: String = Marshalls.raw_to_base64(png_bytes)

	return {
		"data": {
			"image_base64": b64,
			"width": img.get_width(),
			"height": img.get_height(),
			"original_width": original_width,
			"original_height": original_height,
			"format": "png",
		}
	}


## Generate an atlas TileSet resource (.tres) sliced from a texture.
## params: {texture_path, save_path, tile_width=16, tile_height=16, separation_x=0, separation_y=0, margin_x=0, margin_y=0}
func create_from_texture(params: Dictionary) -> Dictionary:
	var texture_path: String = params.get("texture_path", "")
	var save_path: String = params.get("save_path", "")
	if texture_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Parameter 'texture_path' is required")
	if save_path.is_empty():
		return ErrorCodes.make(ErrorCodes.MISSING_REQUIRED_PARAM, "Parameter 'save_path' is required")

	var tex_err = McpPathValidator.loadable_error(texture_path, "texture_path")
	if tex_err != null: return tex_err
	if not ResourceLoader.exists(texture_path):
		return ErrorCodes.make(ErrorCodes.RESOURCE_NOT_FOUND, "Texture resource not found: %s" % texture_path)

	var tex = load(texture_path)
	if not tex is Texture2D:
		return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "Resource at '%s' is not a Texture2D" % texture_path)

	var tw: int = int(params.get("tile_width", 16))
	var th: int = int(params.get("tile_height", 16))
	var sep_x: int = int(params.get("separation_x", 0))
	var sep_y: int = int(params.get("separation_y", 0))
	var mar_x: int = int(params.get("margin_x", 0))
	var mar_y: int = int(params.get("margin_y", 0))

	if tw <= 0 or th <= 0:
		return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE, "tile_width and tile_height must be > 0")

	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(tw, th)

	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(tw, th)
	src.separation = Vector2i(sep_x, sep_y)
	src.margins = Vector2i(mar_x, mar_y)

	var tex_w: int = tex.get_width()
	var tex_h: int = tex.get_height()
	var cols: int = maxi(1, int((tex_w - mar_x) / (tw + sep_x)))
	var rows: int = maxi(1, int((tex_h - mar_y) / (th + sep_y)))

	var total_tiles := 0
	for c in range(cols):
		for r in range(rows):
			src.create_tile(Vector2i(c, r))
			total_tiles += 1

	tileset.add_source(src, 0)

	var dir := save_path.get_base_dir()
	if not dir.is_empty() and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)

	var save_err := ResourceSaver.save(tileset, save_path)
	if save_err != OK:
		return ErrorCodes.make(ErrorCodes.INTERNAL_ERROR, "Failed to save TileSet to %s: %s" % [save_path, error_string(save_err)])

	return {"data": {
		"save_path": save_path,
		"source_id": 0,
		"tiles_count": total_tiles,
		"cols": cols,
		"rows": rows,
		"tile_size": {"width": tw, "height": th}
	}}


## Set collision shape for a tile in a TileSet resource.
## params: {tileset_path, source_id=0, atlas_col=0, atlas_row=0, shape_type="box"|"polygon", points=[...], physics_layer=0}
func create_collision_polygon(params: Dictionary) -> Dictionary:
	var resolved := _resolve_atlas_source(params)
	if resolved.has("error"):
		return resolved
	var source_id: int = resolved.source_id
	var src: TileSetAtlasSource = resolved.src
	var tileset_path: String = params.get("tileset_path", "")

	var ts: TileSet = load(tileset_path) as TileSet
	if ts == null:
		return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "Resource at '%s' is not a TileSet" % tileset_path)

	var physics_layer: int = int(params.get("physics_layer", 0))
	while ts.get_physics_layers_count() <= physics_layer:
		ts.add_physics_layer()

	var col: int = int(params.get("atlas_col", 0))
	var row: int = int(params.get("atlas_row", 0))
	var tile_coords := Vector2i(col, row)

	if not src.has_tile(tile_coords):
		src.create_tile(tile_coords)

	var tile_data: TileData = src.get_tile_data(tile_coords, 0)
	if tile_data == null:
		return ErrorCodes.make(ErrorCodes.INTERNAL_ERROR, "Could not obtain TileData for tile at (%d, %d)" % [col, row])

	var shape_type: String = str(params.get("shape_type", "box")).to_lower()
	var poly_points := PackedVector2Array()

	if shape_type == "box":
		var tile_size: Vector2i = ts.tile_size

		var hx: float = tile_size.x / 2.0
		var hy: float = tile_size.y / 2.0
		poly_points.append(Vector2(-hx, -hy))
		poly_points.append(Vector2(hx, -hy))
		poly_points.append(Vector2(hx, hy))
		poly_points.append(Vector2(-hx, hy))
	else:
		var raw_points: Array = params.get("points", [])
		for pt in raw_points:
			if pt is Vector2:
				poly_points.append(pt)
			elif pt is Dictionary:
				poly_points.append(Vector2(float(pt.get("x", 0)), float(pt.get("y", 0))))
			elif pt is Array and pt.size() >= 2:
				poly_points.append(Vector2(float(pt[0]), float(pt[1])))

	if poly_points.size() < 3:
		return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE, "Collision polygon requires at least 3 points (got %d)" % poly_points.size())

	tile_data.add_collision_polygon(physics_layer)
	var poly_idx := tile_data.get_collision_polygons_count(physics_layer) - 1
	tile_data.set_collision_polygon_points(physics_layer, poly_idx, poly_points)

	var save_err := ResourceSaver.save(ts, tileset_path)
	if save_err != OK:
		return ErrorCodes.make(ErrorCodes.INTERNAL_ERROR, "Failed to save TileSet changes: %s" % error_string(save_err))

	return {"data": {
		"tileset_path": tileset_path,
		"source_id": source_id,
		"atlas_col": col,
		"atlas_row": row,
		"physics_layer": physics_layer,
		"polygon_index": poly_idx,
		"points_count": poly_points.size(),
		"shape_type": shape_type
	}}


## Scaffold terrain autotile peering bitmasks across an atlas region.
## params: {tileset_path, source_id=0, terrain_set=0, terrain_id=0, template="simple_box"|"kenney_3x3_minimal"|"rpgmaker_47", offset_col=0, offset_row=0}
func scaffold_terrain_bitmasks(params: Dictionary) -> Dictionary:
	var resolved := _resolve_atlas_source(params)
	if resolved.has("error"):
		return resolved
	var source_id: int = resolved.source_id
	var src: TileSetAtlasSource = resolved.src
	var tileset_path: String = params.get("tileset_path", "")

	var ts: TileSet = load(tileset_path) as TileSet
	if ts == null:
		return ErrorCodes.make(ErrorCodes.WRONG_TYPE, "Resource at '%s' is not a TileSet" % tileset_path)

	var terrain_set: int = int(params.get("terrain_set", 0))
	var terrain_id: int = int(params.get("terrain_id", params.get("terrain", 0)))
	var template: String = str(params.get("template", "simple_box")).to_lower().strip_edges()
	var offset_col: int = int(params.get("atlas_offset_col", params.get("offset_col", 0)))
	var offset_row: int = int(params.get("atlas_offset_row", params.get("offset_row", 0)))

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
			var custom_tiles: Array = params.get("tiles", params.get("bitmasks", []))
			if not custom_tiles.is_empty():
				for item in custom_tiles:
					if item is Dictionary:
						template_map.append(item)
			else:
				return ErrorCodes.make(ErrorCodes.VALUE_OUT_OF_RANGE, "Unknown template '%s'. Valid: simple_box, kenney_3x3_minimal, rpgmaker_47" % template)

	var configured_count := 0
	for entry in template_map:
		var c: int = int(entry.get("col", 0)) + offset_col
		var r: int = int(entry.get("row", 0)) + offset_row
		var coords := Vector2i(c, r)
		if not src.has_tile(coords):
			src.create_tile(coords)
		var tile_data: TileData = src.get_tile_data(coords, 0)
		if tile_data == null:
			continue
		tile_data.set_terrain_set(terrain_set)
		tile_data.set_terrain(terrain_id)
		for b in range(8):
			tile_data.set_terrain_peering_bit(b, -1)
		var bits: Array = entry.get("bits", [])
		for b in bits:
			tile_data.set_terrain_peering_bit(int(b), terrain_id)
		configured_count += 1

	var save_err := ResourceSaver.save(ts, tileset_path)
	if save_err != OK:
		return ErrorCodes.make(ErrorCodes.INTERNAL_ERROR, "Failed to save TileSet terrain configuration: %s" % error_string(save_err))

	return {"data": {
		"tileset_path": tileset_path,
		"source_id": source_id,
		"terrain_set": terrain_set,
		"terrain_id": terrain_id,
		"template": template,
		"tiles_configured": configured_count,
		"offset": {"col": offset_col, "row": offset_row}
	}}


func _resolve_atlas_source(params: Dictionary) -> Dictionary:
	var tileset_path: String = params.get("tileset_path", "")
	if tileset_path.is_empty():
		return ErrorCodes.make(
			ErrorCodes.MISSING_REQUIRED_PARAM,
			"'tileset_path' parameter is required and must not be empty"
		)

	if not params.has("source_id"):
		return ErrorCodes.make(
			ErrorCodes.MISSING_REQUIRED_PARAM,
			"'source_id' parameter is required"
		)

	var tileset_path_err = McpPathValidator.loadable_error(tileset_path, "tileset_path")
	if tileset_path_err != null:
		return tileset_path_err

	if not ResourceLoader.exists(tileset_path):
		return ErrorCodes.make(
			ErrorCodes.RESOURCE_NOT_FOUND,
			"TileSet resource not found: %s" % tileset_path
		)

	var ts = load(tileset_path)
	if not ts is TileSet:
		var loaded_type := "null" if ts == null else ts.get_class()
		return ErrorCodes.make(
			ErrorCodes.WRONG_TYPE,
			"Resource at '%s' is not a TileSet (got %s)" % [tileset_path, loaded_type]
		)

	var source_id: int = int(params.get("source_id", -999))
	if source_id < 0 or not ts.has_source(source_id):
		return ErrorCodes.make(
			ErrorCodes.VALUE_OUT_OF_RANGE,
			"source_id %d does not exist in TileSet" % source_id
		)

	var src = ts.get_source(source_id)
	if not src is TileSetAtlasSource:
		var source_type: String = "null" if src == null else src.get_class()
		return ErrorCodes.make(
			ErrorCodes.WRONG_TYPE,
			"Source %d is not a TileSetAtlasSource (got %s)" % [source_id, source_type]
		)

	return {
		"source_id": source_id,
		"src": src,
	}
