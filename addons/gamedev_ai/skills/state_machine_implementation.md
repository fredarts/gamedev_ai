# Godot 4.x State Machine Implementation Guide

This skill defines the standard architecture for implementing Finite State Machines (FSM) in Godot 4.x. Whenever you need to implement complex character logic, AI, or generic state management, you MUST use this Node-based approach.

## 1. Why use this architecture?
- **Decoupling**: Each state is an isolated script, making it easy to add or modify behaviors without creating spaghetti code.
- **Node-based Structure**: Leveraging Godot's Scene Tree, states are child nodes of the `StateMachine` node. This allows exposing `@export` variables in the inspector for each state individually.

## 2. The Base `State` Class
All states MUST inherit from this base class.

```gdscript
class_name State
extends Node

# Emitted when the state wants to transition to another state
signal transitioned(state: State, new_state_name: String)

# Called when the state machine enters this state.
func enter() -> void:
	pass

# Called when the state machine exits this state.
func exit() -> void:
	pass

# Called during _process
func update(_delta: float) -> void:
	pass

# Called during _physics_process
func physics_update(_delta: float) -> void:
	pass
```

## 3. The `StateMachine` Class
This script is attached to a node (usually a generic `Node`) that acts as the container for all `State` nodes.

```gdscript
class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Automatically detect all child State nodes
	for child in get_children():
		if child is State:
			# Store states in a dictionary using a lowercase name for easy lookup
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state: State, new_state_name: String) -> void:
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		printerr("StateMachine: State '%s' does not exist." % new_state_name)
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
```

## 4. Usage Example
To create an enemy with an `Idle` and `Follow` state:
1. Create a `StateMachine` node inside the enemy scene.
2. Add two `Node` children to the `StateMachine` called `Idle` and `Follow`.
3. Attach scripts to `Idle` and `Follow` that `extends State`.
4. In the `Idle` script, transition by calling: `transitioned.emit(self, "follow")`.
5. Assign the `Idle` node to the `initial_state` variable in the `StateMachine` inspector.

## 5. Best Practices
- **Never hardcode transitions inside the `StateMachine`**. Let the individual `State` scripts emit the `transitioned` signal.
- **Pass references correctly**: If states need to modify the parent entity (e.g., the `CharacterBody2D`), you can `@export var enemy: CharacterBody2D` in the `State` class, or pass it during an `init()` function called by the `StateMachine`.
