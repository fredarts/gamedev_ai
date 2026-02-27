# GDScript Style Guide

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
