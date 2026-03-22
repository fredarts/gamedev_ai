# Godot 4.x Input Handling and Remapping Guide

This skill defines the standard architecture for handling advanced inputs and allowing players to remap controls at runtime in Godot 4.

## 1. Core Concepts
- Never use `Input.is_key_pressed()`. ALWAYS use the `InputMap` (e.g., `Input.is_action_pressed("jump")`).
- Input remapping at runtime is done by modifying the `InputMap` singleton and then saving those changes to disk so they persist between sessions.

## 2. Reading Inputs Properly
When checking inputs inside `_physics_process` or `_process`, use:
- `Input.is_action_pressed("action")` -> For continuous holding (e.g., walking, charging).
- `Input.is_action_just_pressed("action")` -> For single triggers (e.g., jumping, shooting).
- `Input.is_action_just_released("action")` -> For release triggers (e.g., releasing a charged bow).

## 3. Remapping Architecture

### Step 1: The Remapping Logic
To remap an action, you must first clear its existing events, then add the new `InputEvent`.

```gdscript
# InputManager.gd (Autoload recommended)
extends Node

# Remaps a specific action to a new InputEvent (Key or Joypad Button)
func remap_action(action_name: String, new_event: InputEvent) -> void:
    if InputMap.has_action(action_name):
        # Clear existing events for this action
        InputMap.action_erase_events(action_name)
        # Assign the new event
        InputMap.action_add_event(action_name, new_event)
```

### Step 2: The UI Button for Remapping
Create a custom `Button` script for the settings menu that listens for the next input when clicked.

```gdscript
# RemapButton.gd
extends Button

@export var action_to_remap: String

func _ready() -> void:
    toggle_mode = true
    update_text()

func _toggled(button_pressed: bool) -> void:
    if button_pressed:
        text = "Press any key..."
        set_process_unhandled_input(true)
    else:
        update_text()
        set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
    if button_pressed:
        if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
            if event.is_pressed():
                # Call our Autoload manager to change the mapping
                InputManager.remap_action(action_to_remap, event)
                button_pressed = false # Untoggle the button
                accept_event() # Consume the input

func update_text() -> void:
    var events = InputMap.action_get_events(action_to_remap)
    if events.size() > 0:
        text = events[0].as_text()
    else:
        text = "Unassigned"
```

## 4. Saving and Loading Keybinds
Because `InputMap` changes are only in memory, you MUST save them to a `ConfigFile` or JSON when the player changes them.

```gdscript
# Inside your InputManager.gd
const BINDINGS_FILE = "user://keybindings.cfg"

func save_keybindings() -> void:
    var config = ConfigFile.new()
    for action in InputMap.get_actions():
        # Filter out built-in Godot actions (ui_up, ui_down, etc) unless you want them remappable
        if not action.begins_with("ui_"):
            var events = InputMap.action_get_events(action)
            if events.size() > 0:
                config.set_value("bindings", action, events[0])
    
    config.save(BINDINGS_FILE)

func load_keybindings() -> void:
    var config = ConfigFile.new()
    if config.load(BINDINGS_FILE) == OK:
        for action in config.get_section_keys("bindings"):
            var event = config.get_value("bindings", action)
            remap_action(action, event)
```

## 5. Summary Check
When developing a system with customizable controls, ALWAYS provide:
1. An `InputManager` to abstract the `InputMap` API.
2. A safe persistence layer using `ConfigFile.set_value` and `InputMap.action_get_events`.
