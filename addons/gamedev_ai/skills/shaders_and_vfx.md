# Godot 4.x Shaders, Materials & VFX

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 1. SHADER TYPES & STAGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Godot uses **GDShader**, a high-performance shading language similar to GLSL ES 3.0.
Every shader file (`.gdshader`) MUST begin with its shader type declaration:

- `shader_type canvas_item;` -> For 2D nodes (`Sprite2D`, `AnimatedSprite2D`, `ColorRect`, `TextureRect`, `Control`).
- `shader_type spatial;` -> For 3D meshes (`MeshInstance3D`, `CSGShape3D`, `Sprite3D`).
- `shader_type particles;` -> For GPU compute particle systems (`GPUParticles2D`, `GPUParticles3D`).
- `shader_type sky;` -> For custom skyboxes / procedural environments.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 2. UNIFORM HINTS & INSPECTOR EXPOSURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Always provide explicit uniform hints so Godot's Inspector automatically renders tailored widgets:

```glsl
// Color picker widget (linear to sRGB conversion handled by engine)
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Numeric Slider with min, max, and step
uniform float dissolve_amount : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform int blur_iterations : hint_range(1, 16) = 4;

// 2D & 3D Vectors
uniform vec2 scroll_speed = vec2(0.5, 0.0);
uniform vec3 wind_direction = vec3(1.0, 0.0, 0.5);

// Textures with sensible fallbacks
uniform sampler2D noise_texture : hint_default_white, filter_linear_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 3. BUILT-IN VARIABLES QUICK REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**CanvasItem (2D):**
- `COLOR`: Final output pixel color (`vec4`).
- `UV`: Normalized pixel coordinates [0.0, 1.0].
- `TEXTURE`: Bound texture asset.
- `TEXTURE_PIXEL_SIZE`: Size of a single pixel in UV space (`vec2(1.0/width, 1.0/height)`).
- `TIME`: Continuous global game time in seconds (`float`).
- `VERTEX`: Position of vertices in local space.

**Spatial (3D):**
- `ALBEDO`: Base surface color (`vec3`).
- `ALPHA`: Surface opacity [0.0, 1.0].
- `ROUGHNESS`: Surface roughness [0.0, 1.0].
- `METALLIC`: Metallic reflectivity [0.0, 1.0].
- `SPECULAR`: Specular highlight strength.
- `EMISSION`: Emissive light glow color and intensity (`vec3`).
- `NORMAL`: Surface normal vector in view space.
- `VIEW`: View direction vector pointing toward camera.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 4. CLASSIC GAME RECIPES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#### 4.1. 2D Damage Hit Flash
```glsl
shader_type canvas_item;

uniform bool active = true;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_modifier : hint_range(0.0, 1.0, 0.05) = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (active && color.a > 0.0) {
		color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);
	}
	COLOR = color;
}
```

#### 4.2. 2D Procedural Dissolve with Burning Edge
```glsl
shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0, 0.01) = 0.35;
uniform float burn_size : hint_range(0.0, 0.2, 0.01) = 0.08;
uniform vec4 burn_color : source_color = vec4(1.0, 0.4, 0.1, 1.0);

float pseudo_noise(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float noise = pseudo_noise(UV * 8.0);
	
	if (noise < dissolve_amount) {
		discard;
	} else if (noise < dissolve_amount + burn_size && tex_color.a > 0.0) {
		tex_color = burn_color;
	}
	COLOR = tex_color;
}
```

#### 4.3. 3D Toon / Cel Shading with Stepped Lighting
```glsl
shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform vec4 albedo_color : source_color = vec4(0.8, 0.4, 0.3, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.3, 0.15, 0.2, 1.0);
uniform float cuts : hint_range(1.0, 8.0, 1.0) = 3.0;
uniform float roughness : hint_range(0.0, 1.0, 0.05) = 0.5;

void fragment() {
	ALBEDO = albedo_color.rgb;
	ROUGHNESS = roughness;
}

void light() {
	float ndotl = dot(NORMAL, LIGHT);
	float stepped = floor(max(0.0, ndotl) * cuts) / cuts;
	vec3 diff = mix(shadow_color.rgb, albedo_color.rgb, stepped);
	DIFFUSE_LIGHT += diff * ATTENUATION * LIGHT_COLOR;
}
```

#### 4.4. 3D Fresnel Silhouette Rim Glow
```glsl
shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.1, 0.15, 0.25, 1.0);
uniform vec4 rim_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);
uniform float rim_power : hint_range(0.5, 8.0, 0.1) = 3.0;
uniform float emission_energy : hint_range(0.0, 10.0, 0.5) = 2.5;

void fragment() {
	ALBEDO = base_color.rgb;
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	EMISSION = rim_color.rgb * fresnel * emission_energy;
}
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 5. PERFORMANCE RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. **Vertex Math > Fragment Math**: The vertex function executes once per vertex (e.g. 4 times per quad sprite), while `fragment()` executes millions of times per frame for every covered pixel. Calculate sine waves, wind swaying, and matrix transformations in `vertex()` and pass via `varying`.
2. **Avoid Heavy Texture Branching**: Avoid dynamic loops containing texture sampling inside `fragment()`.
3. **Use Shader Synthesizer Tools**:
   - `generate_shader(preset: "hit_flash")` -> Auto-creates `.gdshader` and `.tres` `ShaderMaterial`.
   - `apply_shader_to_node(node_path: "%PlayerSprite", preset: "hit_flash")` -> Attaches material with Undo/Redo support.
