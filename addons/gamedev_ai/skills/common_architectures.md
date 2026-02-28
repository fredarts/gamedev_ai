# Godot 4.6 Gameplay Architectures

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 1. COMPOSITION OVER INHERITANCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Avoid deep inheritance trees (e.g., `BaseNode` -> `Entity` -> `Character` -> `Enemy` -> `Goblin`). Deep inheritance in GDScript becomes rigid and hard to refactor.

Instead, use **Composition**. Create small, reusable scripts attached to basic `Node`s that provide specific functionality. An entity is simply a root node with several "Components" attached as children.

```gdscript
# The Player Scene structure:
# CharacterBody2D (Player)
# ├── Sprite2D
# ├── CollisionShape2D
# ├── HealthComponent (Node) <- Stores max_hp, current_hp, take_damage()
# ├── HitboxComponent (Area2D) <- Detects incoming attacks and forwards to HealthComponent
# └── MovementComponent (Node) <- Handles velocity logic
```

**Why this is better:**
If you want to create a destructible barrel later, you don't need to inherit from `Enemy`. You just stick a `HealthComponent` and `HitboxComponent` on a `StaticBody2D`.

```gdscript
# HealthComponent.gd
class_name HealthComponent extends Node

signal died
signal health_changed(new_health: int)

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
    current_health = max_health

func damage(amount: int) -> void:
    current_health = maxi(0, current_health - amount)
    health_changed.emit(current_health)
    if current_health <= 0:
        died.emit()
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 2. FINITE STATE MACHINES (FSM)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For complex characters or AI, do not use massive `if/elif` blocks or `switch/match` statements inside `_physics_process)`. 

Use a Node-based State Machine.

```gdscript
# The Enemy Scene structure:
# CharacterBody2D (Enemy)
# ├── StateMachine (Node) <- The manager
# │   ├── IdleState (Node)
# │   ├── ChaseState (Node)
# │   └── AttackState (Node)
```

**Base State Class:**
```gdscript
class_name State extends Node

signal transitioned(new_state_name: StringName)

# Export a generic Entity so the state can move it
@export var entity: CharacterBody2D

func enter() -> void:
    pass

func exit() -> void:
    pass

func update(_delta: float) -> void:
    pass

func physics_update(_delta: float) -> void:
    pass
```

**State Machine Manager:**
```gdscript
class_name StateMachine extends Node

@export var initial_state: State
var current_state: State

func _ready() -> void:
    for child in get_children():
        if child is State:
            child.transitioned.connect(_on_child_transition)
    
    if initial_state:
        current_state = initial_state
        current_state.enter()

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)

func _on_child_transition(new_state_name: StringName) -> void:
    var next_state = find_child(String(new_state_name)) as State
    if not next_state or next_state == current_state: return
    
    current_state.exit()
    current_state = next_state
    current_state.enter()
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 3. EVENT BUS (AUTOLOAD SIGNALS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For systems that are far apart in the scene tree (e.g., the Player dying needing to update the UI Scoreboard), do not use `get_node("../../UI")`. This tightly couples scenes.

Instead, create an Autoload singleton called `GlobalEvents.gd` or `EventBus.gd` containing only signals.

```gdscript
# EventBus.gd (Autoload)
extends Node

signal player_died
signal score_updated(new_score: int)
```

```gdscript
# Player.gd
func die() -> void:
    EventBus.player_died.emit()
    queue_free()
```

```gdscript
# GameOverUI.gd
func _ready() -> void:
    EventBus.player_died.connect(show_game_over_screen)
```
