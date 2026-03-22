# Godot 4.x Quest and Dialogue Systems Guide

This skill defines the architecture for implementing Quest and Dialogue systems natively in Godot 4 without relying on massive external plugins (unless specifically requested by the user, like Dialogic or Dialogue Manager).

## 1. Dialogue Architecture (Native Approach)
For native Godot dialogue, we use a simple Array of Dictionaries exported from a Resource or parsed from a JSON file.

### Dialogue Data Structure
```json
[
  {"name": "King", "text": "Welcome, hero! We need your help.", "portrait": "res://assets/king_happy.png"},
  {"name": "King", "text": "Will you slay the dragon?", "choices": ["Yes", "No"]}
]
```

### Dialogue Manager (Autoload)
Always use an Autoload (`DialogueManager`) to handle UI instantiation so that NPCS don't need to know about the UI.
```gdscript
extends Node

signal dialogue_finished
signal choice_selected(choice_index: int)

var dialogue_ui_scene = preload("res://ui/dialogue_ui.tscn")
var current_ui: Control

func start_dialogue(dialogue_data: Array) -> void:
	if current_ui:
		current_ui.queue_free()
	
	current_ui = dialogue_ui_scene.instantiate()
	get_tree().root.add_child(current_ui)
	current_ui.play(dialogue_data)
```

## 2. Quest System Architecture (Resource-Based)
Quests should NEVER be hardcoded into NPC scripts. They must use Godot's `Resource` system, specifically following a Composition Pattern.

### `Quest.gd`
The main data container for a single quest.
```gdscript
class_name Quest
extends Resource

enum QuestStatus { UNAVAILABLE, AVAILABLE, ACTIVE, COMPLETED, FAILED }

@export var id: String
@export var title: String
@export var description: String
@export var status: QuestStatus = QuestStatus.UNAVAILABLE
@export var objectives: Array[QuestObjective] = []

signal status_changed(new_status: QuestStatus)
signal objective_completed(objective: QuestObjective)

func start_quest() -> void:
	status = QuestStatus.ACTIVE
	status_changed.emit(status)

func check_completion() -> void:
	for obj in objectives:
		if not obj.is_completed:
			return
	
	status = QuestStatus.COMPLETED
	status_changed.emit(status)
```

### `QuestObjective.gd`
A single, trackable goal within a quest.
```gdscript
class_name QuestObjective
extends Resource

@export var description: String
@export var required_amount: int = 1
var current_amount: int = 0
var is_completed: bool = false

signal updated
signal completed

func advance(amount: int = 1) -> void:
	if is_completed: return
	
	current_amount += amount
	updated.emit()
	
	if current_amount >= required_amount:
		is_completed = true
		completed.emit()
```

## 3. Global Quest Manager (Autoload)
To keep track of all active and completed quests across scenes, use a `QuestManager` Autoload.

```gdscript
extends Node

# Dictionary mapping Quest ID (String) to Quest (Resource)
var active_quests: Dictionary = {}

func accept_quest(quest: Quest) -> void:
	if not active_quests.has(quest.id):
		active_quests[quest.id] = quest
		quest.start_quest()

func update_objective(quest_id: String, objective_index: int, amount: int = 1) -> void:
	if active_quests.has(quest_id):
		var quest = active_quests[quest_id]
		if objective_index < quest.objectives.size():
			quest.objectives[objective_index].advance(amount)
			quest.check_completion()
```

## 4. Best Practices
- **Separation of Concerns**: The NPC provides the `Quest` resource to the `QuestManager`. The NPC does **not** track the player's progress.
- **Signals**: Use signals extensively. When an enemy dies, it should emit an `enemy_died(enemy_type)` signal that the `QuestManager` listens to, rather than the enemy interacting with the quest system directly.
