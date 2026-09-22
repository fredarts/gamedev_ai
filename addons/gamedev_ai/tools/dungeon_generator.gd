@tool
extends RefCounted

## DungeonGenerator
## Pure GDScript procedural level generation algorithms:
## - BSP (Binary Space Partitioning)
## - Rooms & Corridors (Classic Roguelike)
## - Cellular Automata (Natural Caves & Caverns)
## - Drunkard Walk (Organic Catacombs & Tunnels)

const TILE_EMPTY = 0
const TILE_FLOOR = 1
const TILE_WALL = 2
const TILE_DOOR = 3
const TILE_ACCENT = 4

class BSPNode:
	var rect: Rect2i
	var left: BSPNode = null
	var right: BSPNode = null
	var room: Rect2i = Rect2i()

	func _init(p_rect: Rect2i):
		rect = p_rect

	func is_leaf() -> bool:
		return left == null and right == null

	func split(min_size: int, rng: RandomNumberGenerator) -> bool:
		if not is_leaf():
			return false

		var split_horizontally = rng.randf() > 0.5
		if rect.size.x > rect.size.y and float(rect.size.x) / float(rect.size.y) >= 1.25:
			split_horizontally = false
		elif rect.size.y > rect.size.x and float(rect.size.y) / float(rect.size.x) >= 1.25:
			split_horizontally = true

		var max_dim = (rect.size.y if split_horizontally else rect.size.x) - min_size
		if max_dim <= min_size:
			return false

		var split_pos = rng.randi_range(min_size, max_dim)

		if split_horizontally:
			left = BSPNode.new(Rect2i(rect.position.x, rect.position.y, rect.size.x, split_pos))
			right = BSPNode.new(Rect2i(rect.position.x, rect.position.y + split_pos, rect.size.x, rect.size.y - split_pos))
		else:
			left = BSPNode.new(Rect2i(rect.position.x, rect.position.y, split_pos, rect.size.y))
			right = BSPNode.new(Rect2i(rect.position.x + split_pos, rect.position.y, rect.size.x - split_pos, rect.size.y))

		return true

	func create_rooms(min_size: int, rng: RandomNumberGenerator, rooms_list: Array):
		if not is_leaf():
			if left: left.create_rooms(min_size, rng, rooms_list)
			if right: right.create_rooms(min_size, rng, rooms_list)
		else:
			var padding = 2
			var rw = rng.randi_range(min_size, max(min_size, rect.size.x - padding * 2))
			var rh = rng.randi_range(min_size, max(min_size, rect.size.y - padding * 2))
			var rx = rect.position.x + rng.randi_range(padding, max(padding, rect.size.x - rw - padding))
			var ry = rect.position.y + rng.randi_range(padding, max(padding, rect.size.y - rh - padding))
			room = Rect2i(rx, ry, rw, rh)
			rooms_list.append(room)

# ==============================================================================
# 1. BSP DUNGEON GENERATOR
# ==============================================================================

static func generate_bsp(width: int, height: int, min_room_size: int = 5, max_rooms: int = 8, seed_val: int = -1) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	if seed_val >= 0:
		rng.seed = seed_val
	else:
		rng.randomize()

	var grid: Array = []
	for y in range(height):
		var row: Array = []
		row.resize(width)
		row.fill(TILE_EMPTY)
		grid.append(row)

	var root_node = BSPNode.new(Rect2i(1, 1, width - 2, height - 2))
	var nodes: Array[BSPNode] = [root_node]

	# Split nodes recursively
	var did_split = true
	while did_split and nodes.size() < max_rooms * 2:
		did_split = false
		var new_nodes: Array[BSPNode] = []
		for n in nodes:
			if n.is_leaf():
				if n.rect.size.x > min_room_size * 2 + 4 or n.rect.size.y > min_room_size * 2 + 4:
					if n.split(min_room_size + 2, rng):
						new_nodes.append(n.left)
						new_nodes.append(n.right)
						did_split = true
						continue
			new_nodes.append(n)
		nodes = new_nodes

	var rooms: Array = []
	root_node.create_rooms(min_room_size, rng, rooms)

	# Carve rooms into grid
	for r in rooms:
		for y in range(r.position.y, r.position.y + r.size.y):
			for x in range(r.position.x, r.position.x + r.size.x):
				if x >= 0 and x < width and y >= 0 and y < height:
					grid[y][x] = TILE_FLOOR

	# Connect rooms with corridors
	for i in range(rooms.size() - 1):
		var r1: Rect2i = rooms[i]
		var r2: Rect2i = rooms[i + 1]
		var c1 = Vector2i(r1.position.x + r1.size.x / 2, r1.position.y + r1.size.y / 2)
		var c2 = Vector2i(r2.position.x + r2.size.x / 2, r2.position.y + r2.size.y / 2)
		_carve_corridor(grid, c1, c2, width, height, rng)

	# Enclose floor tiles with walls
	_enclose_with_walls(grid, width, height)

	var spawn_pos = [rooms[0].position.x + 1, rooms[0].position.y + 1] if not rooms.is_empty() else [width / 2, height / 2]
	var exit_pos = [rooms.back().position.x + 1, rooms.back().position.y + 1] if not rooms.is_empty() else [width / 2, height / 2]

	var rooms_formatted: Array = []
	for r in rooms:
		rooms_formatted.append({"x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y})

	return {
		"algorithm": "bsp",
		"width": width,
		"height": height,
		"grid": grid,
		"rooms": rooms_formatted,
		"rooms_count": rooms.size(),
		"player_spawn": spawn_pos,
		"exit_stairs": exit_pos
	}

# ==============================================================================
# 2. CLASSIC ROOMS & CORRIDORS
# ==============================================================================

static func generate_rooms_and_corridors(width: int, height: int, room_count: int = 8, min_size: int = 5, max_size: int = 10, seed_val: int = -1) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	if seed_val >= 0:
		rng.seed = seed_val
	else:
		rng.randomize()

	var grid: Array = []
	for y in range(height):
		var row: Array = []
		row.resize(width)
		row.fill(TILE_EMPTY)
		grid.append(row)

	var rooms: Array[Rect2i] = []
	var attempts = 0
	var max_attempts = room_count * 15

	while rooms.size() < room_count and attempts < max_attempts:
		attempts += 1
		var rw = rng.randi_range(min_size, max_size)
		var rh = rng.randi_range(min_size, max_size)
		var rx = rng.randi_range(2, width - rw - 3)
		var ry = rng.randi_range(2, height - rh - 3)
		var new_room = Rect2i(rx, ry, rw, rh)

		var overlaps = false
		for r in rooms:
			var expanded = Rect2i(r.position.x - 1, r.position.y - 1, r.size.x + 2, r.size.y + 2)
			if expanded.intersects(new_room):
				overlaps = true
				break

		if not overlaps:
			rooms.append(new_room)
			for y in range(new_room.position.y, new_room.position.y + new_room.size.y):
				for x in range(new_room.position.x, new_room.position.x + new_room.size.x):
					grid[y][x] = TILE_FLOOR

	# Connect each room to the previous room
	for i in range(1, rooms.size()):
		var prev = rooms[i - 1].get_center()
		var curr = rooms[i].get_center()
		_carve_corridor(grid, prev, curr, width, height, rng)

	_enclose_with_walls(grid, width, height)

	var rooms_formatted: Array = []
	for r in rooms:
		rooms_formatted.append({"x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y})

	return {
		"algorithm": "rooms_and_corridors",
		"width": width,
		"height": height,
		"grid": grid,
		"rooms": rooms_formatted,
		"rooms_count": rooms.size(),
		"player_spawn": [rooms[0].position.x + 1, rooms[0].position.y + 1] if not rooms.is_empty() else [width / 2, height / 2],
		"exit_stairs": [rooms.back().position.x + 1, rooms.back().position.y + 1] if not rooms.is_empty() else [width / 2, height / 2]
	}

# ==============================================================================
# 3. CELLULAR AUTOMATA (NATURAL CAVES)
# ==============================================================================

static func generate_cellular(width: int, height: int, fill_prob: float = 0.46, iterations: int = 4, seed_val: int = -1) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	if seed_val >= 0:
		rng.seed = seed_val
	else:
		rng.randomize()

	var map: Array = []
	for y in range(height):
		var row: Array = []
		for x in range(width):
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				row.append(TILE_WALL)
			else:
				row.append(TILE_WALL if rng.randf() < fill_prob else TILE_FLOOR)
		map.append(row)

	# Smoothing iterations (B5678/S45678 standard cellular rule)
	for _it in range(iterations):
		var next_map: Array = []
		for y in range(height):
			var new_row: Array = []
			for x in range(width):
				if x == 0 or x == width - 1 or y == 0 or y == height - 1:
					new_row.append(TILE_WALL)
				else:
					var wall_count = _count_wall_neighbors(map, x, y, width, height)
					if wall_count >= 5:
						new_row.append(TILE_WALL)
					else:
						new_row.append(TILE_FLOOR)
			next_map.append(new_row)
		map = next_map

	# Find a floor tile for player spawn
	var spawn_pos = [width / 2, height / 2]
	for y in range(height / 2, height):
		var found = false
		for x in range(width / 2, width):
			if map[y][x] == TILE_FLOOR:
				spawn_pos = [x, y]
				found = true
				break
		if found: break

	return {
		"algorithm": "cellular",
		"width": width,
		"height": height,
		"grid": map,
		"player_spawn": spawn_pos,
		"exit_stairs": [width - spawn_pos[0], height - spawn_pos[1]]
	}

# ==============================================================================
# 4. DRUNKARD WALK (ORGANIC CATACOMBS)
# ==============================================================================

static func generate_drunkard_walk(width: int, height: int, desired_floor_ratio: float = 0.35, max_steps: int = 5000, seed_val: int = -1) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	if seed_val >= 0:
		rng.seed = seed_val
	else:
		rng.randomize()

	var grid: Array = []
	for y in range(height):
		var row: Array = []
		row.resize(width)
		row.fill(TILE_EMPTY)
		grid.append(row)

	var target_floor_cells = int(width * height * desired_floor_ratio)
	var floor_cells_count = 0

	var cx = width / 2
	var cy = height / 2
	var spawn_pos = [cx, cy]

	grid[cy][cx] = TILE_FLOOR
	floor_cells_count += 1

	var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var steps = 0

	while floor_cells_count < target_floor_cells and steps < max_steps:
		steps += 1
		var dir = directions[rng.randi() % directions.size()]
		var nx = clampi(cx + dir.x, 2, width - 3)
		var ny = clampi(cy + dir.y, 2, height - 3)
		cx = nx
		cy = ny

		if grid[cy][cx] != TILE_FLOOR:
			grid[cy][cx] = TILE_FLOOR
			floor_cells_count += 1

	var exit_pos = [cx, cy]
	_enclose_with_walls(grid, width, height)

	return {
		"algorithm": "drunkard_walk",
		"width": width,
		"height": height,
		"grid": grid,
		"floor_cells_count": floor_cells_count,
		"player_spawn": spawn_pos,
		"exit_stairs": exit_pos
	}

# ==============================================================================
# HELPERS
# ==============================================================================

static func _carve_corridor(grid: Array, from: Vector2i, to: Vector2i, width: int, height: int, rng: RandomNumberGenerator):
	var horiz_first = rng.randf() > 0.5
	if horiz_first:
		_carve_h_tunnel(grid, from.x, to.x, from.y, width, height)
		_carve_v_tunnel(grid, from.y, to.y, to.x, width, height)
	else:
		_carve_v_tunnel(grid, from.y, to.y, from.x, width, height)
		_carve_h_tunnel(grid, from.x, to.x, to.y, width, height)

static func _carve_h_tunnel(grid: Array, x1: int, x2: int, y: int, width: int, height: int):
	for x in range(min(x1, x2), max(x1, x2) + 1):
		if x >= 0 and x < width and y >= 0 and y < height:
			grid[y][x] = TILE_FLOOR

static func _carve_v_tunnel(grid: Array, y1: int, y2: int, x: int, width: int, height: int):
	for y in range(min(y1, y2), max(y1, y2) + 1):
		if x >= 0 and x < width and y >= 0 and y < height:
			grid[y][x] = TILE_FLOOR

static func _enclose_with_walls(grid: Array, width: int, height: int):
	var neighbors = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),                    Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1),  Vector2i(1, 1)
	]

	var walls_to_add: Array[Vector2i] = []
	for y in range(height):
		for x in range(width):
			if grid[y][x] == TILE_EMPTY:
				for n in neighbors:
					var nx = x + n.x
					var ny = y + n.y
					if nx >= 0 and nx < width and ny >= 0 and ny < height:
						if grid[ny][nx] == TILE_FLOOR:
							walls_to_add.append(Vector2i(x, y))
							break

	for w in walls_to_add:
		grid[w.y][w.x] = TILE_WALL

static func _count_wall_neighbors(map: Array, x: int, y: int, width: int, height: int) -> int:
	var count = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx < 0 or nx >= width or ny < 0 or ny >= height:
				count += 1
			elif map[ny][nx] == TILE_WALL:
				count += 1
	return count
