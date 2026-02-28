# GDScript Recipes and Patterns

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
