# Godot 4.6 Performance Optimization

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 1. MULTIMESH FOR RENDERING EFFICIENCY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When you need to render thousands of identical or similar objects (like grass, bullets, or crowds), DO NOT instantiate thousands of `Sprite2D` or `MeshInstance3D` nodes. This will bottleneck the CPU.

Instead, use `MultiMeshInstance2D` (or 3D) coupled with a `MultiMesh` resource. A MultiMesh renders all instances in a **single draw call**.

```gdscript
# Example: Spawning 1000 bullets efficiently using MultiMesh
@onready var multi_mesh_instance: MultiMeshInstance2D = $MultiMeshInstance2D

func setup_bullets(positions: Array[Vector2]) -> void:
    var multimesh := MultiMesh.new()
    multimesh.mesh = preload("res://assets/bullet_mesh.tres") # Must be a Mesh, not a Texture
    multimesh.instance_count = positions.size()
    
    for i in range(positions.size()):
        var xform = Transform2D(0.0, positions[i])
        multimesh.set_instance_transform_2d(i, xform)
        
    multi_mesh_instance.multimesh = multimesh
```

**Advanced (RenderingServer):**
For absolute peak performance (e.g., millions of particles where you still need custom physics logic), bypass the SceneTree entirely and use the `RenderingServer`.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 2. OBJECT POOLING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Avoid calling `instantiate()` and `queue_free()` frequently during gameplay (e.g., for standard bullets). Frequent memory allocation and destruction causes frame drops and garbage collection spikes.

Use an **Object Pool**:
1. Pre-instantiate a batch of objects at the start of the level.
2. When needed, find a "dead" object, reset its state, and make it visible.
3. When destroyed, simply hide it and mark it as "dead" instead of freeing it.

```gdscript
class_name BulletPool extends Node

@export var bullet_scene: PackedScene
@export var pool_size: int = 50

var _pool: Array[Node2D] = []

func _ready() -> void:
    for i in range(pool_size):
        var bullet = bullet_scene.instantiate()
        bullet.hide()
        bullet.process_mode = Node.PROCESS_MODE_DISABLED
        add_child(bullet)
        _pool.append(bullet)

func get_bullet() -> Node2D:
    for bullet in _pool:
        if not bullet.visible:
            return bullet
    
    # Optional: Expand pool if dry
    push_warning("Bullet pool exhausted!")
    return null

func spawn_bullet(pos: Vector2) -> void:
    var b = get_bullet()
    if b:
        b.position = pos
        b.show()
        b.process_mode = Node.PROCESS_MODE_INHERIT
        # b.reset_state() # Call a custom method to reset health/velocity
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 3. STRINGNAME OPTIMIZATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`StringName` (`&"string"`) is significantly faster than standard `String` (`"string"`) for comparisons and hash lookups because it is interned.

**Always use `&"..."` for:**
- `Input.is_action_pressed(&"jump")`
- `dict.has(&"health")` or `dict[&"health"]`
- `emit_signal(&"my_signal")`
- `anim_player.play(&"run")`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 4. GDSCRIPT EXECUTION BEST PRACTICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- **Avoid `get_node()` or `$` in loops/`_process`**: This traverses the scene tree every frame. Always cache nodes using `@onready` at the top of the script.
- **Avoid string paths**: Use exported node types directly in Godot 4.
  *Bad:* `@export var target_path: NodePath` -> `get_node(target_path)`
  *Good:* `@export var target: Node2D`
- **Use Typed Arrays**: `Array[int]` is faster and safer than a generic `Array`.
- **Remove empty `_process()`**: Even an empty `func _process(delta): pass` adds overhead. Delete it if unused.
- **Avoid `print()` in loops**: Console output is highly unoptimized and will stall the game thread.
