# Godot 4.x AI and Pathfinding Guide

This skill defines the standard architecture for implementing Navigation and Pathfinding in Godot 4.

## 1. The Core Nodes
Godot 4 drastically simplified navigation. You no longer need to call the `NavigationServer` directly for basic movement. You must use these two primary components:
1. **The Navigation Mesh**: Defined by a `NavigationRegion2D/3D` or built into a `TileMapLayer`'s Navigation Layer.
2. **The Agent**: The `NavigationAgent2D` or `NavigationAgent3D` attached to your moving entity limit.

## 2. Setting Up the Agent (CharacterBody)
Attach a `NavigationAgent` as a child of your `CharacterBody`. The script should look like this:

```gdscript
class_name Enemy
extends CharacterBody2D

const SPEED = 200.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var target_node: Node2D

func _ready() -> void:
    # Important: Agents need a frame or two to sync with the physics server
    # before they can generate paths.
    call_deferred("actor_setup")

func actor_setup() -> void:
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame
    
    # Optional: configure avoidance radius
    nav_agent.radius = 15.0 
    nav_agent.max_speed = SPEED

func _physics_process(delta: float) -> void:
    if not target_node:
        return
        
    # 1. Update the target position
    nav_agent.target_position = target_node.global_position
    
    # 2. Check if we reached the destination
    if nav_agent.is_navigation_finished():
        velocity = Vector2.ZERO
        move_and_slide()
        return

    # 3. Get the next point on the path
    var current_agent_position: Vector2 = global_position
    var next_path_position: Vector2 = nav_agent.get_next_path_position()
    
    # 4. Calculate the desired velocity
    var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * SPEED
    
    # 5. Avoidance or Direct Movement
    if nav_agent.avoidance_enabled:
        # Instead of moving directly, we tell the agent our intended velocity.
        # The agent will calculate avoidance and emit 'velocity_computed'.
        nav_agent.set_velocity(new_velocity)
    else:
        # If no avoidance, just move directly
        _on_navigation_agent_2d_velocity_computed(new_velocity)

# 6. Apply the computed velocity
# (Connect the `velocity_computed` signal from NavigationAgent2D to this function)
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
    velocity = safe_velocity
    move_and_slide()
```

## 3. Dynamic Obstacles and Avoidance
If multiple enemies are pushing into each other, you MUST enable `avoidance_enabled` on the `NavigationAgent`.
- Ensure they have different `avoidance_priority` values if some are heavier/larger.
- Only use `NavigationObstacle2D/3D` for dynamic, moving barriers (like a sliding door or a moving boulder) that *don't* bake into the permanent navmesh.

## 4. Re-baking Navigation at Runtime
If the player drops a static tower (Tower Defense) or destroys a wall, the navigation mesh becomes invalid.
Instead of obstacles, call `bake_navigation_mesh()` on your `NavigationRegion` to recalculate the permanent paths for all agents simultaneously.
