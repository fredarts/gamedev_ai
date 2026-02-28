# Godot 4.6 Shaders and VFX

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 1. SHADER TYPES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Godot uses its own shading language: **GDShader**, similar to GLSL.
Every shader file (`.gdshader`) must start by specifying its type:

- `shader_type canvas_item;` -> For 2D nodes (`Sprite2D`, `ColorRect`, Control nodes).
- `shader_type spatial;` -> For 3D meshes and materials.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 2. BUILT-IN VARIABLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**CanvasItem (2D) Built-ins:**
- `COLOR`: The output color for the current pixel (RGBA format, `vec4`).
- `UV`: Normalized coordinates (0.0 to 1.0) of the current pixel on the sprite.
- `TEXTURE`: The default texture assigned to the node.
- `TIME`: Global elapsed time in seconds (`float`), mostly used for animations.
- `FRAGCOORD`: Actual pixel coordinate on the physical screen.

To read the color of the sprite's texture at the current UV, you must sample it:
```glsl
vec4 tex_color = texture(TEXTURE, UV);
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 3. EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#### 3.1. The "Hit Flash" (Blinking solid white when taking damage)
A very common pattern in 2D games. We expose a `flash_active` variable to the Inspector.

```glsl
shader_type canvas_item;

// Exposed to the Inspector. Use a Tween in GDScript to animate this from 0 to 1 or boolean over time.
uniform bool flash_active = false;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Read the original texture pixel
    vec4 current_color = texture(TEXTURE, UV);
    
    // If the pixel is completely transparent, keep it transparent
    if (current_color.a > 0.0) {
        if (flash_active) {
            // Replace the RGB but keep the original Alpha
            COLOR = vec4(flash_color.rgb, current_color.a);
        } else {
            COLOR = current_color;
        }
    } else {
        COLOR = current_color;
    }
}
```

#### 3.2. Scrolling Texture (e.g., Water, Lava, Backgrounds)

```glsl
shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.5, 0.0);

void fragment() {
    // Offset the UV by the speed multiplied by global TIME
    vec2 scrolled_uv = UV + (scroll_speed * TIME);
    
    // Sample the texture at the new offset position
    COLOR = texture(TEXTURE, scrolled_uv);
}
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 4. PERFORMANCE BEST PRACTICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The `fragment()` function runs for EVERY PIXEL the node occupies. Do not perform heavy math (e.g., sine waves, complex multiplication) inside `fragment()` if it can be avoided.

Perform math in the `vertex()` function (which runs once per vertex, like the 4 corners of a Sprite) and pass the result to `fragment()` using a **`varying`** variable. Interpolation is essentially free.

```glsl
shader_type canvas_item;

// Calculate a pulsing wave in vertex, pass to fragment
varying float pulsing_wave;

void vertex() {
    // Cheap per-vertex calculation
    pulsing_wave = (sin(TIME * 5.0) + 1.0) / 2.0; 
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    // Cheap per-pixel read
    COLOR = tex * pulsing_wave; 
}
```
