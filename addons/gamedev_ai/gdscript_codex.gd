@tool
extends RefCounted
class_name GDScriptCodex
## Comprehensive GDScript 4.6.1 reference codex.
## Injected into the AI system prompt to ensure modern, correct code generation.

static func get_codex() -> String:
	return """
## GDScript 4.6.1 Codex — Mandatory Reference

You MUST follow this codex when generating GDScript. Any pattern listed under
"DEPRECATED" must NEVER appear in your output. Use the "MODERN" replacement instead.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 1. FILE STRUCTURE & CODE ORDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Every script must follow this order:

```gdscript
# 01. @tool / @icon / @static_unload
# 02. class_name
# 03. extends
# 04. ## Doc comment for the class
# 05. Signals
# 06. Enums
# 07. Constants
# 08. Static variables
# 09. @export variables
# 10. Regular variables
# 11. @onready variables
# 12. _static_init()
# 13. Static methods
# 14. Built-in virtual overrides: _init, _enter_tree, _ready, _process, _physics_process, etc.
# 15. Custom public methods
# 16. Custom private methods (prefix _)
# 17. Inner classes
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 2. NAMING CONVENTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- **Files & Folders**: `snake_case` → `my_script.gd`
- **Classes (class_name)**: `PascalCase` → `PlayerController`
- **Nodes**: `PascalCase` → `HealthBar`, `MainCamera`
- **Functions**: `snake_case` → `get_health()`
- **Variables**: `snake_case` → `move_speed`
- **Signals**: `snake_case` (past tense) → `health_changed`, `enemy_died`
- **Constants**: `CONSTANT_CASE` → `MAX_SPEED`
- **Enums**: `PascalCase` name, `CONSTANT_CASE` members:
  ```gdscript
  enum Direction { UP, DOWN, LEFT, RIGHT }
  ```
- **Private**: Prefix with `_` → `_internal_timer`, `func _calculate()`
- **Boolean variables**: Use prefixes like `is_`, `has_`, `can_` → `is_alive: bool`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 3. STATIC TYPING (ALWAYS USE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Always use static typing. Prefer `:=` when the type is obvious from the right side.

```gdscript
# Explicit type (when type is not obvious or is int/float ambiguous):
var health: int = 100
var speed: float = 200.0

# Inferred type (when type is clear from constructor/literal):
var direction := Vector2.ZERO
var enemies := []  # Array
var data := {}     # Dictionary

# Function signatures MUST have typed parameters and return types:
func take_damage(amount: int) -> void:
    health -= amount

func get_direction() -> Vector2:
    return Vector2.UP

# @onready — ALWAYS declare the explicit type since get_node cannot infer:
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $UI/HealthBar

# BAD — compiler infers Node, not the actual type:
# @onready var sprite := $Sprite2D  # WRONG — type is Node, not Sprite2D
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 4. ANNOTATIONS (MODERN SYSTEM — replaces keywords)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All annotations start with `@`. Key annotations:

```gdscript
@tool                   # Run script in editor
@icon("res://icon.svg") # Custom icon in editor
@static_unload          # Allow unloading static data

@export var hp: int = 10
@export_range(0, 100, 1) var health: int = 100
@export_range(0.0, 1.0, 0.01) var volume: float = 0.5
@export_enum("Warrior", "Mage", "Rogue") var class_type: int = 0
@export_file("*.tscn") var scene_path: String
@export_dir var save_dir: String
@export_multiline var description: String
@export_color_no_alpha var flat_color: Color
@export_node_path("Sprite2D", "AnimatedSprite2D") var sprite_path: NodePath
@export_flags("Fire", "Water", "Earth", "Wind") var elements: int = 0
@export_flags_2d_physics var collision_layer: int
@export_flags_2d_render var render_layer: int

# Grouping exports in the Inspector:
@export_group("Movement")
@export var speed: float = 100.0
@export var jump_force: float = 300.0

@export_subgroup("Advanced")
@export var acceleration: float = 10.0

@export_category("Combat")
@export var damage: int = 10

# Node references:
@onready var player: CharacterBody2D = $Player
@onready var anim: AnimationPlayer = $AnimationPlayer

# Export typed nodes directly (Godot 4 — no more NodePath + get_node):
@export var target_node: Node2D
@export var button: BaseButton
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 5. SIGNALS (MODERN SYNTAX)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```gdscript
# Declaration:
signal health_changed(old_value: int, new_value: int)
signal died
signal item_collected(item_name: String, quantity: int)

# Emitting — use .emit():
health_changed.emit(old_hp, new_hp)
died.emit()

# Connecting — use .connect():
func _ready() -> void:
    health_changed.connect(_on_health_changed)
    $Button.pressed.connect(_on_button_pressed)
    # With extra bound arguments:
    $Button.pressed.connect(_on_button_pressed.bind("extra_data"))

# Disconnecting:
health_changed.disconnect(_on_health_changed)

# One-shot connection (auto-disconnects after first call):
died.connect(_on_died, CONNECT_ONE_SHOT)

# Deferred connection:
health_changed.connect(_on_health_changed, CONNECT_DEFERRED)
```

**DEPRECATED signal patterns — NEVER use:**
```
# emit_signal("health_changed", old, new)  → use health_changed.emit(old, new)
# connect("pressed", self, "_on_pressed")  → use pressed.connect(_on_pressed)
# disconnect("pressed", self, "_on_pressed") → use pressed.disconnect(_on_pressed)
# yield(signal, "completed")               → use await signal
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 6. PROPERTIES (SETTERS & GETTERS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Use the modern `set` / `get` syntax. The old `setget` keyword is removed.

```gdscript
# MODERN — inline set/get:
var health: int = 100:
    set(value):
        health = clampi(value, 0, max_health)
        health_changed.emit(health)
    get:
        return health

# Computed property (no backing variable needed):
var milliseconds: int = 0
var seconds: int:
    get:
        return milliseconds / 1000
    set(value):
        milliseconds = value * 1000
```

**DEPRECATED — NEVER use:**
```
# var health setget set_health, get_health  — REMOVED in Godot 4
```

**Note**: In Godot 4, `set`/`get` are ALWAYS called, even from within the same class.
You do NOT need `self.` to trigger them (unlike Godot 3's `setget`).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 7. AWAIT (replaces yield)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```gdscript
# Wait for a signal:
await get_tree().create_timer(1.0).timeout
await $AnimationPlayer.animation_finished

# Wait for a coroutine:
var result = await some_async_function()

# Wait for next frame:
await get_tree().process_frame

# Wait for physics frame:
await get_tree().physics_frame
```

**DEPRECATED — NEVER use:**
```
# yield(get_tree().create_timer(1.0), "timeout")  — REMOVED
# yield(get_tree(), "idle_frame")                  — REMOVED
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 8. SUPER() (replaces dot-call syntax)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```gdscript
# MODERN:
func _ready() -> void:
    super()  # Calls parent _ready()
    # ... your code

func _process(delta: float) -> void:
    super(delta)  # Calls parent _process(delta)
    # ... your code

# Calling a specific parent method:
func custom_method() -> void:
    super.custom_method()  # Calls parent's custom_method
```

**CRITICAL**: `_ready()` and `_process()` no longer implicitly call the parent.
You MUST use `super()` if the parent class has logic in those methods.

**DEPRECATED — NEVER use:**
```
# ._ready()        — REMOVED
# .custom_method() — REMOVED
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 9. LAMBDA FUNCTIONS & CALLABLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```gdscript
# Lambda (anonymous function):
var my_lambda := func(x: int) -> int: return x * 2

# Lambda in signal connections:
$Button.pressed.connect(func(): print("Button pressed!"))

# Multi-line lambda:
var complex := func(a: int, b: int) -> int:
    var result := a + b
    print(result)
    return result

# Callable references:
var callable := Callable(self, "my_method")
var bound := my_method.bind(42)

# Calling:
callable.call()
my_lambda.call(5)  # Returns 10
```

**DEPRECATED — NEVER use:**
```
# funcref(self, "my_method")  — Use Callable(self, "method_name") or method_name directly
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 10. ABSTRACT CLASSES (NEW in Godot 4.5+)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```gdscript
@abstract
class_name BaseEnemy
extends CharacterBody2D

## Abstract classes cannot be instantiated directly.
## Subclasses MUST implement all abstract methods.

@abstract
func get_attack_damage() -> int

@abstract
func get_movement_pattern() -> Vector2

func take_damage(amount: int) -> void:
    # Concrete method — has implementation
    health -= amount
```

```gdscript
# Concrete subclass:
class_name Goblin
extends BaseEnemy

func get_attack_damage() -> int:
    return 15

func get_movement_pattern() -> Vector2:
    return Vector2(randf_range(-1, 1), randf_range(-1, 1))
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 11. STATIC VARIABLES & METHODS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```gdscript
class_name GameStats

# Static variables (shared across all instances, available in 4.1+):
static var total_enemies_killed: int = 0
static var high_score: int = 0

# Static methods:
static func reset_stats() -> void:
    total_enemies_killed = 0
    high_score = 0

# Static init (runs once when class is first loaded):
static func _static_init() -> void:
    print("GameStats class loaded")

# Usage from anywhere:
# GameStats.total_enemies_killed += 1
# GameStats.reset_stats()
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 12. TWEENS (Tween NODE removed — use create_tween)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```gdscript
# MODERN — create_tween() (no Tween node):
func flash_red() -> void:
    var tween := create_tween()
    tween.tween_property($Sprite2D, "modulate", Color.RED, 0.1)
    tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)

# Chaining:
func animate_entrance() -> void:
    var tween := create_tween()
    tween.tween_property(self, "position", target_pos, 0.5) \\
        .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "modulate:a", 1.0, 0.3)

# Parallel tweens:
func move_and_fade() -> void:
    var tween := create_tween().set_parallel(true)
    tween.tween_property(self, "position", Vector2(100, 100), 1.0)
    tween.tween_property(self, "modulate:a", 0.0, 1.0)

# Callbacks and delays:
func complex_animation() -> void:
    var tween := create_tween()
    tween.tween_callback($AudioPlayer.play)
    tween.tween_interval(0.5)
    tween.tween_property(self, "scale", Vector2(2, 2), 0.3)
    tween.tween_callback(queue_free)

# Await tween completion:
await tween.finished
```

**DEPRECATED — NEVER use:**
```
# var tween = Tween.new()    — Tween node REMOVED
# add_child(tween)           — REMOVED
# tween.interpolate_property — REMOVED
# tween.start()              — REMOVED
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 13. FULL DEPRECATED → MODERN MAPPING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| DEPRECATED (NEVER USE)                           | MODERN REPLACEMENT                                    |
|--------------------------------------------------|-------------------------------------------------------|
| `export var x`                                   | `@export var x`                                       |
| `onready var x`                                  | `@onready var x`                                      |
| `tool`                                           | `@tool`                                               |
| `master`, `puppet`, `slave`, `remotesync`        | Removed — use `@rpc` annotation                       |
| `setget set_fn, get_fn`                          | `var x: set(v): ... get: ...`                          |
| `yield(obj, "signal")`                           | `await obj.signal`                                    |
| `yield(get_tree(), "idle_frame")`                | `await get_tree().process_frame`                      |
| `.parent_method()`                               | `super.parent_method()` or `super()`                  |
| `emit_signal("name", args)`                      | `signal_name.emit(args)`                              |
| `connect("sig", target, "method")`               | `sig.connect(target.method)`                          |
| `disconnect("sig", target, "method")`            | `sig.disconnect(target.method)`                       |
| `is_connected("sig", target, "method")`          | `sig.is_connected(target.method)`                     |
| `funcref(obj, "method")`                         | `Callable(obj, "method")` or `obj.method`             |
| `instance()`                                     | `instantiate()`                                       |
| `Tween` node + `interpolate_property`            | `create_tween()` + `tween_property()`                 |
| `KinematicBody2D/3D`                             | `CharacterBody2D/3D`                                  |
| `Spatial`                                        | `Node3D`                                              |
| `Position2D/3D`                                  | `Marker2D/3D`                                         |
| `PoolStringArray`, `PoolByteArray`, etc.         | `PackedStringArray`, `PackedByteArray`, etc.           |
| `rotation_degrees`                               | `rotation` (displayed as degrees in Inspector)        |
| `rand_range(a, b)`                               | `randf_range(a, b)` or `randi_range(a, b)`            |
| `stepify()`                                      | `snapped()`                                           |
| `Color.white`, `Color.black`                     | `Color.WHITE`, `Color.BLACK` (uppercase)              |
| `var x = something`                              | `var x: Type = something` (always type)               |
| `has_no_area()`, `has_no_surface()`              | `has_area()`, `has_surface()` (inverted and renamed)  |
| `randomize()`                                    | Not needed — auto-called on project load              |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 14. COMMON RECIPES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**A) Character Movement (2D Platformer):**
```gdscript
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity
    var direction := Input.get_axis("ui_left", "ui_right")
    velocity.x = direction * speed if direction else move_toward(velocity.x, 0, speed)
    move_and_slide()
```

**B) Character Movement (3D FPS):**
```gdscript
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    move_and_slide()
```

**C) Scene Switching:**
```gdscript
get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
# Or packed:
var scene: PackedScene = preload("res://scenes/level.tscn")
get_tree().change_scene_to_packed(scene)
```

**D) Instantiating Scenes:**
```gdscript
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var enemy: CharacterBody2D = enemy_scene.instantiate()
enemy.position = Vector2(100, 200)
add_child(enemy)
```

**E) Timer Pattern:**
```gdscript
# Prefer Timer node over code-based timers for reusable timers.
# For one-shots:
await get_tree().create_timer(2.0).timeout
print("2 seconds passed")
```

**F) Input Handling:**
```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_ESCAPE:
                get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("attack"):
        perform_attack()
```

**G) Resource Pattern:**
```gdscript
# Define a custom resource:
class_name ItemData
extends Resource

@export var name: String = ""
@export var icon: Texture2D
@export var damage: int = 0
@export var description: String = ""

# Use it:
@export var weapon: ItemData
```

**H) Autoload Singleton Pattern:**
```gdscript
# In Project Settings > Autoloads, add as "GameManager"
extends Node

signal score_changed(new_score: int)

var score: int = 0:
    set(value):
        score = value
        score_changed.emit(score)
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 15. STRINGNAME OPTIMIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

StringName is cheaper for comparisons. Use `&"name"` syntax for:
- Dictionary keys used frequently
- Signal names in manual code
- Action names

```gdscript
# StringName literal:
var action := &"jump"
if Input.is_action_pressed(&"move_left"):
    pass
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 16. MATCH STATEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```gdscript
match state:
    State.IDLE:
        play_idle()
    State.RUNNING:
        play_run()
    State.JUMPING, State.FALLING:
        play_air()
    _:
        push_warning("Unknown state")

# With pattern guards (when keyword):
match value:
    var v when v > 0:
        print("Positive: ", v)
    var v when v < 0:
        print("Negative: ", v)
    _:
        print("Zero")
```
"""
