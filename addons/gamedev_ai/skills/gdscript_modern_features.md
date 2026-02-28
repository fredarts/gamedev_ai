# GDScript Modern Features

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
