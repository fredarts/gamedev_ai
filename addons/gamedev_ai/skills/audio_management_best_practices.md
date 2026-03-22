# Godot 4.x Audio Management Best Practices

This skill outlines the necessary architecture for playing sound effects (SFX) and Music smoothly in Godot 4 without clipping, stuttering, or disorganized audio coding.

## 1. The Golden Rule of Audio
**Never** put an `AudioStreamPlayer` directly inside an entity that gets destroyed (like a Bullet or an Enemy) if the sound is supposed to play *during* or *after* its destruction. When the node is freed (`queue_free()`), the audio cuts off abruptly.
Instead, use an **Audio Pooling** system via an Autoload.

## 2. Audio Buses
Always route audio to the proper bus. In the bottom panel of the editor (Audio), you should always have at least 3 buses:
1. `Master`
2. `Music` (routes to Master)
3. `SFX` (routes to Master)

When creating an `AudioStreamPlayer`, you MUST set its `bus` property to "Music" or "SFX". Never leave it on "Master" unless intentional.

## 3. The AudioManager (Autoload Pool)
To prevent creating and destroying audio nodes constantly, instantiate a "Pool" of generic players at the start of the game.

```gdscript
# AudioManager.gd (Autoload)
extends Node

var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE = 16

func _ready() -> void:
    for i in range(POOL_SIZE):
        var p = AudioStreamPlayer.new()
        p.bus = "SFX"
        add_child(p)
        sfx_pool.append(p)

# Call this from anywhere: AudioManager.play_sfx(preload("res://explosion.wav"))
func play_sfx(stream: AudioStream) -> void:
    for player in sfx_pool:
        if not player.playing:
            player.stream = stream
            player.play()
            return
    
    # Optional: If the pool is entirely full, we could forcefully hijack the oldest sound
    # or dynamically expand the pool. For most games, ignoring it is fine.
    printerr("AudioManager: SFX Pool is full!")
```

### Positional Audio (2D and 3D)
If you need sounds to come from specific positions (e.g., an explosion far away), you need separate pools for `AudioStreamPlayer2D` and `AudioStreamPlayer3D`. The function signature should accept a position:

```gdscript
func play_sfx_2d(stream: AudioStream, pos: Vector2) -> void:
    for player in sfx_pool_2d:
        if not player.playing:
            player.global_position = pos
            player.stream = stream
            player.play()
            return
```

## 4. Preventing Monotony (Godot 4 Randomizer)
Hearing the exact same footstep sound 100 times per minute is annoying. Godot 4 provides `AudioStreamRandomizer`. 
- Instead of using a `.wav` file directly in your scripts, create a new Resource of type `AudioStreamRandomizer`.
- Add 3 or 4 variations of the footstep `.wav` inside it.
- Set the `random_pitch` property to `1.1` (which means it will shift the pitch up or down by 10%).
- Pass this Randomizer resource to the `AudioManager.play_sfx()` function. The randomizer natively handles picking the variation and shifting the pitch!

## 5. Music Crossfading
Music is singular, so it doesn't need a pool. Use two `AudioStreamPlayer` nodes (Track A and Track B) and a `Tween` to crossfade their `volume_db` properties when switching songs over 2.0 seconds.
