# Godot 4.x Multiplayer and Networking Guide

This skill defines the standard architecture for implementing high-level multiplayer in Godot 4.

## 1. The Core Philosophy
Godot 4's multiplayer is built around the **Server-Authoritative** model by default. The server dictates the truth, and clients simply relay their inputs and simulate locally where appropriate.

Do NOT use older Godot 3.x keywords (`puppet`, `master`, `remote`). Godot 4 uses `@rpc` annotations and relies heavily on two specific nodes: `MultiplayerSynchronizer` and `MultiplayerSpawner`.

## 2. Remote Procedure Calls (RPC)
The `@rpc` annotation configures how a function is called over the network.
Common setups:
- `@rpc("any_peer", "call_local", "reliable")`: Anyone can call this, and it will also execute on the caller's machine. Good for chat messages or generic interactions.
- `@rpc("authority", "call_local", "unreliable")`: Only the authority (usually the server) can call this. Good for syncing continuous data (though Synchronizer is better).

Example of Client sending input to Server:
```gdscript
# Player.gd
func _physics_process(delta):
    if is_multiplayer_authority():
        var dir = Input.get_vector("left", "right", "up", "down")
        if dir != Vector2.ZERO:
            rpc_id(1, "receive_input", dir) # 1 is always the Server ID

@rpc("any_peer", "call_local", "reliable")
func receive_input(dir: Vector2):
    # Security: If we are the server, we might want to check if the peer ID matches
    var sender_id = multiplayer.get_remote_sender_id()
    if sender_id == str(name).to_int():
        velocity = dir * speed
```

## 3. MultiplayerSynchronizer (State Syncing)
Instead of sending RPCs every frame to update positions, use a `MultiplayerSynchronizer` node.
1. Add a `MultiplayerSynchronizer` as a child of your Player/Entity.
2. Under its `replication_config` (which creates a `SceneReplicationConfig` resource), add properties to replicate (e.g., `.:position`, `.:rotation`).
3. Set the `MultiplayerSynchronizer`'s `root_path` to the node containing those properties (usually `..`).
4. **Authority**: Make sure the `MultiplayerSynchronizer.set_multiplayer_authority(1)` is set to the Server (1) for server-authoritative movement, or to the specific client's ID `set_multiplayer_authority(peer_id)` if you want client-authoritative movement.

## 4. MultiplayerSpawner (Node Instantiation)
To dynamically spawn objects (players, bullets, enemies) across all clients seamlessly, use `MultiplayerSpawner`.

1. Add a `MultiplayerSpawner` to your Level scene.
2. Set its `spawn_path` to the Node where you want children to appear (e.g., a `Players` node).
3. Under `Auto Spawn List`, add the `.tscn` paths of the scenes you want to be able to spawn (e.g., `res://player.tscn`).
4. **Usage**: The Server simply calls `add_child(player_instance)` on the `Players` node. The `MultiplayerSpawner` detects this and automatically tells all clients to instantiate that exact same scene with the same Node Name!

### Player Spawning Example (Server-side)
```gdscript
# LevelManager.gd (Server only logic)
@onready var players_node = $Players
var player_scene = preload("res://player.tscn")

func _on_peer_connected(id: int):
    # Only the server spawns players
    if multiplayer.is_server():
        var p = player_scene.instantiate()
        p.name = str(id) # Important: Node name must be the peer ID for authority matching
        players_node.add_child(p, true) # true = force readable name
```

## 5. Peer ID Management
Always set a player node's `name` to `str(peer_id)`. Then, in the player's `_enter_tree()` or `_ready()`, call:
```gdscript
func _enter_tree():
    set_multiplayer_authority(name.to_int())
```
This ensures that the client owns their specific node (or their specific `MultiplayerSynchronizer`).
