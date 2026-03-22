# Godot 4.x Save System and Persistence Guide

This skill defines the standard architecture for saving and loading game data in Godot 4. Depending on the complexity of the data, you MUST use one of the two standard approaches below.

## 1. Important Rules for Saving
- **Always save to `user://`**: The `res://` directory is read-only in exported games. Always use paths like `user://save_game.save`.
- **Abstract the Save Logic**: Create an Autoload (e.g., `SaveManager`) to handle reading and writing. Nodes should only pack their data into a Dictionary and send it to the `SaveManager`.

## 2. Approach A: Dictionary & JSON (Best for simple configurations and generic states)
This is the safest and most common way to save game state (player position, health, level).

### Step 1: Nodes return their state
Every object that needs saving should have a `save()` function that returns a Dictionary.
```gdscript
# Player.gd
func save() -> Dictionary:
	return {
		"node_path": get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"health": current_health
	}
```

### Step 2: The SaveManager (Autoload) writing the file
```gdscript
# SaveManager.gd
extends Node

const SAVE_PATH = "user://savegame.json"

func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	
	var all_data: Array = []
	for node in save_nodes:
		if node.has_method("save"):
			all_data.append(node.save())
			
	var json_string = JSON.stringify(all_data)
	file.store_string(json_string)
```

### Step 3: Loading the file
```gdscript
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return # No save file

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result == OK:
		var all_data = json.data
		for node_data in all_data:
			var node = get_node_or_null(node_data["node_path"])
			if node:
				node.position = Vector2(node_data["pos_x"], node_data["pos_y"])
				if node.has_method("load_data"):
					node.load_data(node_data)
```

## 3. Approach B: Custom Resources (Best for Inventories and RPG Stats)
For complex nested data (like the Inventory system), you can save a `Resource` directly to disk using `ResourceSaver`.

### Saving a Resource
```gdscript
var my_inventory: InventoryData = InventoryData.new()
# ... populate inventory ...
var error = ResourceSaver.save(my_inventory, "user://player_inventory.tres")
if error != OK:
	printerr("Failed to save inventory!")
```

### Loading a Resource
```gdscript
if ResourceLoader.exists("user://player_inventory.tres"):
	# CACHE_MODE_IGNORE ensures we read the file from disk, not memory
	var loaded_inventory = ResourceLoader.load("user://player_inventory.tres", "InventoryData", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded_inventory:
		player.inventory = loaded_inventory
```

## 4. Security Warning
When using `ResourceLoader.load()` on `.tres` or `.res` files from the `user://` directory, be aware that malicious users could inject executable GDScript if the game allows downloading save files. For purely single-player local games, this is usually acceptable, but for competitive games, stick to JSON or `FileAccess.get_var()` binary serialization.
