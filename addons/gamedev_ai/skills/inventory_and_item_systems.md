# Godot 4.x Inventory and Item Systems Guide

This skill defines the standard, highly-scalable architecture for creating Data-Driven Inventories and Item Systems in Godot 4. Whenever asked to create items, shops, or player inventories, you MUST follow this Resource-based approach.

## 1. Core Architecture (The 3 Resources)
Godot 4's `Resource` class is the perfect container for data because it can be easily saved, loaded, and manipulated in the inspector without attaching to a Node.

An inventory system consists of three Custom Resources:
1. **`ItemData`**: Defines what an item IS (its texture, name, stats).
2. **`SlotData`**: Defines an instance of an item in a slot (holds an `ItemData` reference and a `quantity` integer).
3. **`InventoryData`**: Defines a collection of slots (holds an Array of `SlotData`).

---

### Step 1: `ItemData.gd`
Provides the raw definition of the item.

```gdscript
class_name ItemData
extends Resource

@export var id: String = ""
@export var name: String = "Item Name"
@export var description: String = ""
@export var texture: Texture2D
@export var stackable: bool = false
@export var max_stack: int = 99
```

### Step 2: `SlotData.gd`
Pairs an `ItemData` with a quantity.

```gdscript
class_name SlotData
extends Resource

# Emitted when the slot changes (item added/removed), useful for UI updates
signal changed

@export var item_data: ItemData
@export var quantity: int = 0:
	set(value):
		quantity = value
		changed.emit()

func set_item_and_quantity(item: ItemData, amount: int) -> void:
	item_data = item
	quantity = amount
	changed.emit()
```

### Step 3: `InventoryData.gd`
Holds the entire inventory and its logic (adding/removing items).

```gdscript
class_name InventoryData
extends Resource

# Emitted when any slot in the inventory changes
signal inventory_updated(inventory_data: InventoryData)

@export var slots: Array[SlotData] = []

func add_item(item: ItemData, amount: int = 1) -> bool:
	if item.stackable:
		# Try to find an existing slot with this item
		for slot in slots:
			if slot and slot.item_data == item and slot.quantity < item.max_stack:
				var available_space = item.max_stack - slot.quantity
				if amount <= available_space:
					slot.quantity += amount
					inventory_updated.emit(self)
					return true
				else:
					slot.quantity += available_space
					amount -= available_space

	# If not stackable or no existing slot found, find an empty slot
	for i in range(slots.size()):
		if not slots[i] or not slots[i].item_data:
			if not slots[i]:
				slots[i] = SlotData.new()
			slots[i].set_item_and_quantity(item, amount)
			inventory_updated.emit(self)
			return true
			
	return false # Inventory full
```

## 2. Using the Inventory in the Game
To use the inventory on a Player or Chest:
1. Create a variable in the `Player.gd` script: `@export var inventory: InventoryData`.
2. Emitting `inventory_updated` from the Resource allows you to connect the UI directly to the data.

## 3. Creating Items
Do not create nodes for items stored in an inventory. Create `.tres` files by right-clicking in the FileSystem -> New Resource -> `ItemData`. Configure the texture and stats in the inspector.

## 4. Why Use This Pattern?
- **Persistence**: You can save the entire `InventoryData` resource to disk using `ResourceSaver.save(inventory, "user://save_inventory.tres")`.
- **UI Separation**: The UI scripts just listen to `inventory_updated` and `slot_data.changed` signals to redraw themselves. The UI holds NO data logic.
