# Godot 4.x Data Management and Crafting Guide

This skill defines the standard architecture for handling large-scale static data (like RPG items, enemy stats, or crafting recipes) in Godot 4 without hardcoding them into scripts.

## 1. When to use JSON vs Resources
- **Resources (`.tres`)**: Best for data that needs tight integration with Godot features (like Textures, AudioStreams, or Scripts). Example: An `ItemData` resource that holds a sword's icon.
- **JSON (`.json`)**: Best for pure, massive datasets (like a global list of 500 enemy stats, dialog trees, or crafting recipe requirements) that might be edited by game designers in external tools (Excel/Google Sheets exported to JSON).

## 2. Parsing JSON Data (Godot 4 Syntax)
In Godot 4, you no longer need to instance a `JSON` object to quickly parse a string into a Dictionary. You can use the static method `JSON.parse_string()`.

### Creating a DataManager (Autoload)
To keep the game performant, load JSON files **once** at the start of the game and store them in a Dictionary.

```gdscript
# DataManager.gd (Autoload)
extends Node

var item_database: Dictionary = {}
var crafting_recipes: Dictionary = {}

func _ready() -> void:
    item_database = load_json_file("res://data/items.json")
    crafting_recipes = load_json_file("res://data/recipes.json")

func load_json_file(file_path: String) -> Dictionary:
    if not FileAccess.file_exists(file_path):
        printerr("DataManager: File not found: ", file_path)
        return {}
        
    var file = FileAccess.open(file_path, FileAccess.READ)
    var content = file.get_as_text()
    file.close()
    
    # parse_string returns a Variant. We cast it to Dictionary.
    var parsed_data = JSON.parse_string(content)
    
    if parsed_data is Dictionary:
        return parsed_data
    else:
        printerr("DataManager: Error parsing JSON or root is not an object: ", file_path)
        return {}
```

## 3. Designing the JSON Structure
Always use unique String IDs as keys for dictionaries, not Array indices.

```json
{
  "sword_iron": {
    "name": "Iron Sword",
    "damage": 15,
    "type": "weapon"
  },
  "potion_health": {
    "name": "Health Potion",
    "heal_amount": 50,
    "type": "consumable"
  }
}
```

## 4. Crafting System Architecture
A crafting system needs to iterate through the user's inventory and check if it meets the `requirements` array defined in the JSON.

```json
// recipes.json
{
  "sword_steel": {
    "result_item": "sword_steel",
    "requirements": {
      "ingot_steel": 2,
      "wood_stick": 1
    },
    "crafting_time": 5.0
  }
}
```

### Checking Recipes
When a player clicks "Craft", don't hardcode the logic. Read from the dictionary:

```gdscript
func try_craft(recipe_id: String, player_inventory: InventoryData) -> bool:
    var recipe = DataManager.crafting_recipes.get(recipe_id)
    if not recipe: return false
    
    # 1. Check if we have all requirements
    var reqs: Dictionary = recipe["requirements"]
    for item_id in reqs:
        var amount_needed = reqs[item_id]
        if not player_inventory.has_item_amount(item_id, amount_needed):
            return false # Missing an item
            
    # 2. Consume items
    for item_id in reqs:
        player_inventory.remove_item(item_id, reqs[item_id])
        
    # 3. Give result
    player_inventory.add_item(recipe["result_item"], 1)
    return true
```

## 5. Security Note
Only use `JSON.parse_string()` on files inside `res://` (which are created by you). If reading downloaded content or user mods from `user://`, validate the structure thoroughly, as incorrect formats will return `null` and break your game.
