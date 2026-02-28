# Godot 4.6 UI & UX Patterns

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 1. CONTROL NODES STRICTNESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When building User Interfaces, **exclusively use nodes that inherit from `Control` (the green nodes)**. 
Never mix `Node2D` (blue nodes) like `Sprite2D` inside a UI hierarchy, as they do not respect layout rules, anchors, or viewport scaling.

If you need an image in the UI, use `TextureRect`. If you need an animated image, use `AnimatedTexture` inside a `TextureRect`.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 2. ANCHORS AND CONTAINERS (RESPONSIVE UI)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Godot's UI is robust if you use the built-in layout systems instead of hardcoding pixel positions.

**Containers:**
Always use Containers to manage lists or grids. Containers automatically override the `position` and `size` of their children.
- **`VBoxContainer`**: Stacks children vertically.
- **`HBoxContainer`**: Stacks children horizontally.
- **`MarginContainer`**: Adds padding around its children (using Theme Overrides > Constants).

**Size Flags (`size_flags_horizontal` / `vertical`):**
When a Control is inside a Container, its Size Flags dictate how it behaves.
- **Fill**: The control expands to fill the available space allocated by the container.
- **Expand**: The control pushes other controls away to grab as much empty space as possible.

```gdscript
# Typical Responsive Menu Structure:
# 
# CanvasLayer (For separating UI from the game world)
# └── MarginContainer (Anchored to Full Rect, sets screen padding)
#     └── VBoxContainer (Vertical list of menu items)
#         ├── Label (Title)
#         ├── HBoxContainer (Row with buttons)
#         │   ├── Button (Start)
#         │   └── Button (Options)
#         └── RichTextLabel (Credits, Size Flags Vertical = Expand+Fill to push to bottom)
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 3. THEMING AND STYLEBOXFLAT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Avoid modifying the "Theme Overrides" of individual buttons or panels directly unless it is a unique, one-off element.

Instead, create a `Theme` resource globally.
- Apply the `Theme` to the root `Control` node of your scene. All children will inherit it.
- To create a background for a Panel or a Button, do not use a `TextureRect` with an imported PNG. Use a **`StyleBoxFlat`**.

`StyleBoxFlat` allows you to create highly performant, resolution-independent UI shapes directly in the engine:
- Solid background colors
- Rounded corners (`corner_radius_top_left`, etc.)
- Drop shadows (`shadow_size`, `shadow_offset`)
- Borders (`border_width_bottom`, etc.)

This is the standard for modern, flat, or material UI design in Godot 4.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 4. RESOLUTION INDEPENDENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

In `Project Settings > Display > Window`:
- Set `Stretch Mode` to `canvas_items` (ensures 2D elements and UI scale sharply without being rasterized to a low internal resolution first).
- Set `Aspect` to `expand` (to support ultrawide or different mobile aspect ratios) or `keep` (if you want black bars for forced pixel-perfect ratios).
