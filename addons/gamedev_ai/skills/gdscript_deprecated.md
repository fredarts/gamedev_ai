# GDScript Deprecated -> Modern Mapping

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 13. FULL DEPRECATED → MODERN MAPPING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| DEPRECATED (NEVER USE)                           | MODERN REPLACEMENT                                    |
|--------------------------------------------------|-------------------------------------------------------|
| `export var x`                                   | `@export var x`                                       |
| `onready var x`                                  | `@onready var x`                                      |
| `tool`                                           | `@tool`                                               |
| `master`, `puppet`, `slave`, `remotesync`        | Removed — use `@rpc` annotation                       |
| `setget set_fn, get_fn`                          | `var x: set(v): ... get: ...`                          |
| `yield(obj, "signal")`                           | `await obj.signal`                                    |
| `yield(get_tree(), "idle_frame")`                | `await get_tree().process_frame`                      |
| `.parent_method()`                               | `super.parent_method()` or `super()`                  |
| `emit_signal("name", args)`                      | `signal_name.emit(args)`                              |
| `connect("sig", target, "method")`               | `sig.connect(target.method)`                          |
| `disconnect("sig", target, "method")`            | `sig.disconnect(target.method)`                       |
| `is_connected("sig", target, "method")`          | `sig.is_connected(target.method)`                     |
| `funcref(obj, "method")`                         | `Callable(obj, "method")` or `obj.method`             |
| `instance()`                                     | `instantiate()`                                       |
| `Tween` node + `interpolate_property`            | `create_tween()` + `tween_property()`                 |
| `KinematicBody2D/3D`                             | `CharacterBody2D/3D`                                  |
| `Spatial`                                        | `Node3D`                                              |
| `Position2D/3D`                                  | `Marker2D/3D`                                         |
| `PoolStringArray`, `PoolByteArray`, etc.         | `PackedStringArray`, `PackedByteArray`, etc.           |
| `rotation_degrees`                               | `rotation` (displayed as degrees in Inspector)        |
| `rand_range(a, b)`                               | `randf_range(a, b)` or `randi_range(a, b)`            |
| `stepify()`                                      | `snapped()`                                           |
| `Color.white`, `Color.black`                     | `Color.WHITE`, `Color.BLACK` (uppercase)              |
| `var x = something`                              | `var x: Type = something` (always type)               |
| `has_no_area()`, `has_no_surface()`              | `has_area()`, `has_surface()` (inverted and renamed)  |
| `randomize()`                                    | Not needed — auto-called on project load              |
