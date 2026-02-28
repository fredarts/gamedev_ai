# GDScript Signals and Tweens

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
