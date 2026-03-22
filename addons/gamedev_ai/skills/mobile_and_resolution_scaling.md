# Godot 4.x Mobile Controls and Resolution Scaling Guide

This skill defines the standard architecture for handling Touch Screens, Safe Areas (notches), and adapting your game to multiple resolutions (Aspect Ratios) in Godot 4.

## 1. Handling Multiple Resolutions
Godot 4 handles resolution scaling at the project level. Never manually scale individual background images to fit the screen.

Go to **Project -> Project Settings -> Display -> Window**:
- **Size**: Set your base resolution (e.g., 1920x1080 for PC, or 1080x1920 for Portrait Mobile).
- **Stretch Mode**: 
  - `canvas_items` (formerly `2d`): Best for 2D games. It renders UI and sprites crisply regardless of the window size.
  - `viewport`: Renders the game at exactly the base resolution and then linearly scales the final image. Pixel art games **MUST** use this.
- **Stretch Aspect**:
  - `keep`: Keeps the exact aspect ratio (adds black bars if the screen is wider/taller).
  - `expand`: Expands the view to fill the screen (great for UI that anchors to the edges).

### UI Anchoring
To support multiple aspects, **never** hardcode `position` for UI elements. Always use anchors (Control nodes).
- Set a minimap to the Top-Right anchor.
- Set a health bar to the Top-Left anchor.
- When the screen expands, these elements will stay glued to the corners.

## 2. Setting Up Touch Controls
Do not write complex `_input(event as InputEventScreenTouch)` logic for basic buttons.

### On-Screen Gameplay Buttons (D-Pad, Attack)
Always use the `TouchScreenButton` node for gameplay controls.
1. Add a `TouchScreenButton` to a `CanvasLayer` (so it draws over the camera).
2. Set its `texture_normal`.
3. In the Inspector, set `action` to the exact name in your InputMap (e.g., `ui_left` or `jump`).
4. **Result**: Touching this button automatically fakes a keyboard press for that action! Your player script doesn't need to change a single line of code; `Input.is_action_pressed("jump")` will return `true`.

## 3. Emulating Touch from Mouse
During development on PC, go to **Project -> Project Settings -> Input Devices -> Pointing** and enable `Emulate Touch From Mouse`. This allows you to click your `TouchScreenButton` nodes with your mouse to test mobile controls.

## 4. Safe Areas (Mobile Notches)
Modern phones have camera notches or rounded corners that can cover your UI.
To prevent this, wrap your main UI inside a `MarginContainer` and apply the OS safe area dynamically:

```gdscript
# SafeAreaUI.gd
extends MarginContainer

func _ready() -> void:
    # Get the safe area for the current screen
    var safe_area: Rect2i = DisplayServer.get_display_safe_area()
    var window_size: Vector2i = DisplayServer.window_get_size()
    
    # Calculate margins
    var left_margin = safe_area.position.x
    var top_margin = safe_area.position.y
    var right_margin = window_size.x - (safe_area.position.x + safe_area.size.x)
    var bottom_margin = window_size.y - (safe_area.position.y + safe_area.size.y)
    
    # Apply to the MarginContainer
    add_theme_constant_override("margin_left", left_margin)
    add_theme_constant_override("margin_top", top_margin)
    add_theme_constant_override("margin_right", right_margin)
    add_theme_constant_override("margin_bottom", bottom_margin)
```
Place all your UI elements *inside* this `MarginContainer`, and they will never be blocked by a notch.
