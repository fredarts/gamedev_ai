# Godot 4.x Procedural Level Generation and PCG Guide

This skill defines the standard architecture for generating levels procedurally in Godot 4, primarily utilizing `FastNoiseLite` and the new `TileMapLayer` system.

## 1. FastNoiseLite for Terrain Data
`FastNoiseLite` is the standard tool for generating smooth, continuous random values (noise) to determine terrain types (e.g., Water, Sand, Grass).

### Initialization
Always create and configure the noise object in `_ready()` or pass it as an `@export` resource.
```gdscript
var noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    noise.seed = randi() # Or a fixed seed for reproducible worlds
    noise.fractal_octaves = 4
    noise.frequency = 0.05
```

## 2. Reading Noise and Setting Tiles
Godot 4 replaced the old `TileMap` node with `TileMapLayer` nodes for better performance and grouping. You must use `TileMapLayer.set_cell()` to place tiles based on the noise value.

Noise values range from `-1.0` to `1.0`. You can map these values to different terrains:

```gdscript
@export var terrain_layer: TileMapLayer
@export var map_width: int = 100
@export var map_height: int = 100

const SOURCE_ID = 0
const TILE_WATER = Vector2i(0, 0)
const TILE_SAND = Vector2i(1, 0)
const TILE_GRASS = Vector2i(2, 0)

func generate_map() -> void:
    for x in range(map_width):
        for y in range(map_height):
            # get_noise_2d returns a float between -1.0 and 1.0
            var noise_val = noise.get_noise_2d(x, y) 
            var tile_coords: Vector2i
            
            if noise_val < -0.2:
                tile_coords = TILE_WATER
            elif noise_val < 0.0:
                tile_coords = TILE_SAND
            else:
                tile_coords = TILE_GRASS
            
            # set_cell(coords, source_id, atlas_coords)
            terrain_layer.set_cell(Vector2i(x, y), SOURCE_ID, tile_coords)
```

## 3. Autotiling (Terrain Connecting)
If your tileset is configured with Terrains (Autotiling), do **not** use `set_cell()` to place them one by one, as they won't automatically connect. Instead, use `set_cells_terrain_connect()`.

```gdscript
func generate_autotiled_grass() -> void:
    var grass_cells: Array[Vector2i] = []
    
    for x in range(map_width):
        for y in range(map_height):
            if noise.get_noise_2d(x, y) > 0.0:
                grass_cells.append(Vector2i(x, y))
    
    # Connects all tiles in the array using Terrain Set 0, Terrain 0
    terrain_layer.set_cells_terrain_connect(grass_cells, 0, 0)
```

## 4. Chunk-Based Infinite Generation
For infinite worlds, do NOT generate everything at once.
1. Divide the world into "Chunks" (e.g., 32x32 tiles).
2. Track the player's position in "Chunk Coordinates" (`player.global_position / (32 * tile_size)`).
3. Generate chunks within a specific radius (e.g., 2 chunks in every direction).
4. Store generated chunks in a Dictionary (`{Vector2i(chunk_x, chunk_y): true}`) to prevent regenerating them.
5. Delete or hide chunks that fall too far behind the player.

## 5. Performance Tips
- Use `TileMapLayer` instead of instantiating individual `Sprite2D` nodes for background/terrain.
- Do PCG calculations in a separate `Thread` if the world is massive, to avoid freezing the main game loop during generation.
