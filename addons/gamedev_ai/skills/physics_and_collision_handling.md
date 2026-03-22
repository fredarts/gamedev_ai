# Godot 4.x Physics and Collision Handling Guide

This skill defines the standard architecture for setting up physics, collisions, and character movement in Godot 4.

## 1. Collision Layers vs. Collision Masks (CRITICAL)
Always configure your Physics Settings thoughtfully. Do NOT leave everything on Layer 1.
- **Collision Layer**: What am I? (e.g., I am a Player on Layer 2)
- **Collision Mask**: What can I hit/see? (e.g., I look for World on Layer 1 and Enemies on Layer 3)

### Naming Layers
Always go to **Project -> Project Settings -> Layer Names -> 2D/3D Physics** and name your layers:
1. `World`
2. `Player`
3. `Enemies`
4. `PlayerProjectiles`
5. `EnemyProjectiles`
6. `Interactables` (NPCs, Chests)

## 2. CharacterBody2D / CharacterBody3D (`move_and_slide`)
In Godot 4, `move_and_slide()` takes **zero arguments**. It relies on internal properties of the `CharacterBody` node.

```gdscript
class_name Player
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
    # 1. Apply Gravity
    if not is_on_floor():
        velocity.y += gravity * delta

    # 2. Handle Jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # 3. Get Input Direction (-1, 0, or 1)
    var direction := Input.get_axis("move_left", "move_right")
    
    # 4. Apply Horizontal Velocity
    if direction:
        velocity.x = direction * SPEED
    else:
        # Smoothly stop when no input is pressed
        velocity.x = move_toward(velocity.x, 0, SPEED)

    # 5. Move the Character
    # No arguments needed! It automatically uses 'velocity' and handles sliding.
    move_and_slide()
```

## 3. Handling Interactions (Area vs PhysicsBody)
- **StaticBody / CharacterBody / RigidBody**: Use these if things should physically stop each other (bump, push, block).
- **Area**: Use this if objects should temporarily overlap or trigger events (Pickup items, Spikes, Detection zones).

When an Area detects an overlapping body, always ensure you are checking the type or group before applying logic:

```gdscript
func _on_hitbox_body_entered(body: Node2D) -> void:
    if body is Player:
        body.take_damage(10)
        
    # OR using groups
    if body.is_in_group("Enemies"):
        body.die()
```

## 4. RayCast Performance
- Raycasts are extremely fast. Use `RayCast2D/3D` for hitscan weapons, vision cones, or checking distances to the floor.
- Always use the `target_position` relative property, and remember you can force an update using `force_raycast_update()` if you move the raycast and need an instant answer on the same physics frame.
- Set the `collision_mask` of the RayCast precisely so it only hits what matters (e.g., walls/enemies, ignoring friendly projectiles).
