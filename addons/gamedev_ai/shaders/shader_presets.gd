@tool
extends RefCounted

## Shader Presets Catalog
const CATEGORIES = {
	"2D Combat & FX": ["hit_flash", "dissolve_2d", "shield_bubble", "outline_2d"],
	"2D Stylized & Retro": ["pixelate_2d", "vhs_glitch", "hologram_2d", "chromatic_aberration"],
	"2D Nature & Ambience": ["water_ripple", "wind_sway_2d", "fire_lava"],
	"3D Spatial & Cel-Shading": ["toon_cel", "stylized_water_3d", "fresnel_rim", "dissolve_3d", "hologram_3d", "foliage_wind_3d"]
}

static func get_all_preset_names() -> Array[String]:
	var names: Array[String] = []
	for cat in CATEGORIES:
		for p in CATEGORIES[cat]:
			names.append(p)
	return names

static func resolve_preset(query: String) -> String:
	var q = query.to_lower().strip_edges()
	# Exact match
	if get_all_preset_names().has(q):
		return q
		
	# Alias / Keyword heuristic
	if "flash" in q or "hit" in q or "dano" in q or "piscar" in q:
		return "hit_flash"
	elif "toon" in q or "cel" in q or "anime" in q:
		return "toon_cel"
	elif "water" in q or "agua" in q or "água" in q or "wave" in q or "ripple" in q:
		return "stylized_water_3d" if ("3d" in q or "mesh" in q) else "water_ripple"
	elif "dissolve" in q or "desintegrar" in q or "burn" in q or "queimar" in q:
		return "dissolve_3d" if ("3d" in q or "mesh" in q) else "dissolve_2d"
	elif "outline" in q or "borda" in q or "contorno" in q:
		return "outline_2d"
	elif "shield" in q or "escudo" in q or "forcefield" in q or "campo de forca" in q:
		return "shield_bubble"
	elif "pixel" in q or "mosaic" in q or "retro" in q:
		return "pixelate_2d"
	elif "glitch" in q or "vhs" in q or "crt" in q:
		return "vhs_glitch"
	elif "holo" in q or "hologram" in q:
		return "hologram_3d" if ("3d" in q or "mesh" in q) else "hologram_2d"
	elif "wind" in q or "vento" in q or "folha" in q or "grass" in q or "grama" in q:
		return "foliage_wind_3d" if ("3d" in q or "mesh" in q) else "wind_sway_2d"
	elif "fresnel" in q or "rim" in q or "glow" in q or "aura" in q:
		return "fresnel_rim"
	elif "fire" in q or "fogo" in q or "lava" in q or "magma" in q:
		return "fire_lava"
	elif "chromatic" in q or "aberration" in q:
		return "chromatic_aberration"
		
	return "hit_flash"

static func get_preset(name: String) -> Dictionary:
	match name:
		# ================= 2D COMBAT & FX =================
		"hit_flash":
			return {
				"name": "Hit Flash",
				"type": "canvas_item",
				"description": "Solid damage flash blink for 2D sprites upon taking hit.",
				"code": """shader_type canvas_item;

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
""",
				"default_uniforms": {
					"active": true,
					"flash_color": Color(1.0, 1.0, 1.0, 1.0),
					"flash_modifier": 1.0
				}
			}

		"dissolve_2d":
			return {
				"name": "Dissolve 2D",
				"type": "canvas_item",
				"description": "Procedural disintegrating dissolve with glowing burning edge.",
				"code": """shader_type canvas_item;

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
""",
				"default_uniforms": {
					"dissolve_amount": 0.35,
					"burn_size": 0.08,
					"burn_color": Color(1.0, 0.4, 0.1, 1.0)
				}
			}

		"outline_2d":
			return {
				"name": "Outline 2D",
				"type": "canvas_item",
				"description": "Pixel-perfect or smoothed outline highlight for 2D sprites.",
				"code": """shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float outline_width : hint_range(0.0, 10.0, 0.5) = 2.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * outline_width;
	vec4 col = texture(TEXTURE, UV);
	
	if (col.a < 0.1) {
		float a = texture(TEXTURE, UV + vec2(0.0, -size.y)).a +
				  texture(TEXTURE, UV + vec2(0.0, size.y)).a +
				  texture(TEXTURE, UV + vec2(-size.x, 0.0)).a +
				  texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
		if (a > 0.1) {
			COLOR = outline_color;
		} else {
			COLOR = col;
		}
	} else {
		COLOR = col;
	}
}
""",
				"default_uniforms": {
					"outline_color": Color(1.0, 0.85, 0.2, 1.0),
					"outline_width": 2.0
				}
			}

		"shield_bubble":
			return {
				"name": "Shield Bubble",
				"type": "canvas_item",
				"description": "Pulsing sci-fi energy shield with rim refraction and pulse waves.",
				"code": """shader_type canvas_item;

uniform vec4 shield_color : source_color = vec4(0.2, 0.7, 1.0, 0.75);
uniform float pulse_speed : hint_range(0.5, 8.0, 0.1) = 3.0;
uniform float rim_intensity : hint_range(0.1, 3.0, 0.1) = 1.5;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv) * 2.0;
	
	float alpha = smoothstep(0.8, 1.0, dist) * rim_intensity;
	float pulse = (sin(TIME * pulse_speed - dist * 10.0) + 1.0) * 0.25;
	
	vec4 base = texture(TEXTURE, UV);
	vec4 shield = shield_color;
	shield.a = clamp((alpha + pulse) * shield_color.a, 0.0, 1.0);
	
	COLOR = mix(base, shield, shield.a);
}
""",
				"default_uniforms": {
					"shield_color": Color(0.2, 0.7, 1.0, 0.75),
					"pulse_speed": 3.0,
					"rim_intensity": 1.5
				}
			}

		# ================= 2D STYLIZED & RETRO =================
		"pixelate_2d":
			return {
				"name": "Pixelate / Retro Mosaic",
				"type": "canvas_item",
				"description": "Dynamic pixelation filter for retro or transition effects.",
				"code": """shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 64.0, 1.0) = 8.0;

void fragment() {
	vec2 uv = floor(UV / (TEXTURE_PIXEL_SIZE * pixel_size)) * (TEXTURE_PIXEL_SIZE * pixel_size);
	COLOR = texture(TEXTURE, uv);
}
""",
				"default_uniforms": {
					"pixel_size": 8.0
				}
			}

		"vhs_glitch":
			return {
				"name": "VHS Glitch & Scanlines",
				"type": "canvas_item",
				"description": "Retro tape aberration, chromatic split, and horizontal scanlines.",
				"code": """shader_type canvas_item;

uniform float scanline_count : hint_range(10.0, 300.0, 5.0) = 120.0;
uniform float scanline_intensity : hint_range(0.0, 1.0, 0.05) = 0.25;
uniform float rgb_split : hint_range(0.0, 0.05, 0.001) = 0.006;
uniform float glitch_speed : hint_range(0.5, 10.0, 0.5) = 4.0;

void fragment() {
	vec2 uv = UV;
	
	// Glitch offset
	float glitch = sin(TIME * glitch_speed + uv.y * 20.0) * 0.002;
	uv.x += glitch;
	
	// RGB Split
	float r = texture(TEXTURE, uv + vec2(rgb_split, 0.0)).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - vec2(rgb_split, 0.0)).b;
	float a = texture(TEXTURE, uv).a;
	
	// Scanlines
	float scanline = sin(uv.y * scanline_count) * 0.5 + 0.5;
	vec3 final_color = vec3(r, g, b) * mix(1.0, scanline, scanline_intensity);
	
	COLOR = vec4(final_color, a);
}
""",
				"default_uniforms": {
					"scanline_count": 120.0,
					"scanline_intensity": 0.25,
					"rgb_split": 0.006,
					"glitch_speed": 4.0
				}
			}

		"hologram_2d":
			return {
				"name": "Hologram 2D",
				"type": "canvas_item",
				"description": "Cyan glowing hologram with holographic flicker and scanlines.",
				"code": """shader_type canvas_item;

uniform vec4 holo_color : source_color = vec4(0.2, 0.9, 1.0, 0.8);
uniform float scanline_speed : hint_range(0.5, 10.0, 0.5) = 3.0;
uniform float flicker_speed : hint_range(1.0, 30.0, 1.0) = 15.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	if (base.a <= 0.0) {
		discard;
	}
	
	float lines = sin(UV.y * 80.0 + TIME * scanline_speed) * 0.5 + 0.5;
	float flicker = sin(TIME * flicker_speed) * 0.1 + 0.9;
	
	vec3 col = holo_color.rgb * base.rgb * lines * flicker;
	COLOR = vec4(col, base.a * holo_color.a);
}
""",
				"default_uniforms": {
					"holo_color": Color(0.2, 0.9, 1.0, 0.8),
					"scanline_speed": 3.0,
					"flicker_speed": 15.0
				}
			}

		"chromatic_aberration":
			return {
				"name": "Chromatic Aberration",
				"type": "canvas_item",
				"description": "Lens RGB prism displacement around edges.",
				"code": """shader_type canvas_item;

uniform float offset : hint_range(0.0, 0.05, 0.001) = 0.01;

void fragment() {
	vec2 shift = (UV - vec2(0.5)) * offset;
	float r = texture(TEXTURE, UV + shift).r;
	float g = texture(TEXTURE, UV).g;
	float b = texture(TEXTURE, UV - shift).b;
	float a = texture(TEXTURE, UV).a;
	
	COLOR = vec4(r, g, b, a);
}
""",
				"default_uniforms": {
					"offset": 0.01
				}
			}

		# ================= 2D NATURE & AMBIENCE =================
		"water_ripple":
			return {
				"name": "Water Ripple / Distortion",
				"type": "canvas_item",
				"description": "2D underwater or ripple surface wave distortion.",
				"code": """shader_type canvas_item;

uniform float wave_speed : hint_range(0.5, 8.0, 0.1) = 2.5;
uniform float wave_freq : hint_range(5.0, 50.0, 1.0) = 20.0;
uniform float wave_amplitude : hint_range(0.001, 0.05, 0.001) = 0.015;
uniform vec4 water_tint : source_color = vec4(0.2, 0.6, 0.9, 0.3);

void fragment() {
	vec2 uv = UV;
	uv.x += sin(uv.y * wave_freq + TIME * wave_speed) * wave_amplitude;
	uv.y += cos(uv.x * wave_freq + TIME * wave_speed) * wave_amplitude;
	
	vec4 color = texture(TEXTURE, uv);
	COLOR = mix(color, water_tint, water_tint.a);
}
""",
				"default_uniforms": {
					"wave_speed": 2.5,
					"wave_freq": 20.0,
					"wave_amplitude": 0.015,
					"water_tint": Color(0.2, 0.6, 0.9, 0.3)
				}
			}

		"wind_sway_2d":
			return {
				"name": "Wind Sway 2D",
				"type": "canvas_item",
				"description": "Breeze swaying animation computed efficiently in vertex function.",
				"code": """shader_type canvas_item;

uniform float wind_speed : hint_range(0.5, 10.0, 0.5) = 3.0;
uniform float wind_strength : hint_range(0.0, 50.0, 1.0) = 15.0;

void vertex() {
	// Top vertices sway more than roots/base (assuming UV.y = 0 is top)
	float influence = 1.0 - UV.y;
	VERTEX.x += sin(TIME * wind_speed + VERTEX.y * 0.02) * wind_strength * influence;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
}
""",
				"default_uniforms": {
					"wind_speed": 3.0,
					"wind_strength": 15.0
				}
			}

		"fire_lava":
			return {
				"name": "Fire & Lava Flow",
				"type": "canvas_item",
				"description": "Dynamic scrolling fiery plasma and magma.",
				"code": """shader_type canvas_item;

uniform vec4 hot_color : source_color = vec4(1.0, 0.9, 0.2, 1.0);
uniform vec4 mid_color : source_color = vec4(1.0, 0.25, 0.05, 1.0);
uniform vec4 dark_color : source_color = vec4(0.2, 0.02, 0.02, 1.0);
uniform float flow_speed : hint_range(0.1, 5.0, 0.1) = 1.2;

void fragment() {
	vec2 uv = UV * 3.0;
	float n = sin(uv.x * 4.0 + TIME * flow_speed) + cos(uv.y * 4.0 - TIME * flow_speed * 1.3);
	n = (n + 2.0) / 4.0;
	
	vec4 col = mix(dark_color, mid_color, smoothstep(0.2, 0.6, n));
	col = mix(col, hot_color, smoothstep(0.6, 0.95, n));
	
	COLOR = col;
}
""",
				"default_uniforms": {
					"hot_color": Color(1.0, 0.9, 0.2, 1.0),
					"mid_color": Color(1.0, 0.25, 0.05, 1.0),
					"dark_color": Color(0.2, 0.02, 0.02, 1.0),
					"flow_speed": 1.2
				}
			}

		# ================= 3D SPATIAL & CEL-SHADING =================
		"toon_cel":
			return {
				"name": "Toon / Cel Shading 3D",
				"type": "spatial",
				"description": "Anime style stepped lighting with ramp threshold and rim light.",
				"code": """shader_type spatial;
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
""",
				"default_uniforms": {
					"albedo_color": Color(0.8, 0.4, 0.3, 1.0),
					"shadow_color": Color(0.3, 0.15, 0.2, 1.0),
					"cuts": 3.0,
					"roughness": 0.5
				}
			}

		"fresnel_rim":
			return {
				"name": "Fresnel Rim / Energy Aura 3D",
				"type": "spatial",
				"description": "3D silhouette aura and energy shield glow based on view angle.",
				"code": """shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.1, 0.15, 0.25, 1.0);
uniform vec4 rim_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);
uniform float rim_power : hint_range(0.5, 8.0, 0.1) = 3.0;
uniform float emission_energy : hint_range(0.0, 10.0, 0.5) = 2.5;

void fragment() {
	ALBEDO = base_color.rgb;
	
	// Fresnel computation
	float fresnel = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	fresnel = pow(fresnel, rim_power);
	
	EMISSION = rim_color.rgb * fresnel * emission_energy;
}
""",
				"default_uniforms": {
					"base_color": Color(0.1, 0.15, 0.25, 1.0),
					"rim_color": Color(0.3, 0.8, 1.0, 1.0),
					"rim_power": 3.0,
					"emission_energy": 2.5
				}
			}

		"stylized_water_3d":
			return {
				"name": "Stylized Water 3D",
				"type": "spatial",
				"description": "Dynamic vertex waves with shallow water tint and surface specular.",
				"code": """shader_type spatial;

uniform vec4 deep_color : source_color = vec4(0.05, 0.2, 0.5, 0.9);
uniform vec4 shallow_color : source_color = vec4(0.2, 0.7, 0.8, 0.8);
uniform float wave_speed : hint_range(0.1, 4.0, 0.1) = 1.5;
uniform float wave_height : hint_range(0.0, 1.0, 0.02) = 0.15;
uniform float wave_frequency : hint_range(0.5, 10.0, 0.5) = 3.0;

void vertex() {
	float wave = sin(VERTEX.x * wave_frequency + TIME * wave_speed) * cos(VERTEX.z * wave_frequency + TIME * wave_speed);
	VERTEX.y += wave * wave_height;
}

void fragment() {
	ALBEDO = mix(deep_color.rgb, shallow_color.rgb, 0.5);
	ROUGHNESS = 0.1;
	SPECULAR = 0.8;
}
""",
				"default_uniforms": {
					"deep_color": Color(0.05, 0.2, 0.5, 0.9),
					"shallow_color": Color(0.2, 0.7, 0.8, 0.8),
					"wave_speed": 1.5,
					"wave_height": 0.15,
					"wave_frequency": 3.0
				}
			}

		"dissolve_3d":
			return {
				"name": "Dissolve 3D",
				"type": "spatial",
				"description": "3D mesh procedural dissolve with glowing fiery boundary.",
				"code": """shader_type spatial;

uniform vec4 albedo : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float dissolve_amount : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float edge_width : hint_range(0.0, 0.2, 0.01) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 0.3, 0.0, 1.0);

float noise3(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

void fragment() {
	float n = noise3(VERTEX * 2.0);
	if (n < dissolve_amount) {
		discard;
	} else if (n < dissolve_amount + edge_width) {
		ALBEDO = edge_color.rgb;
		EMISSION = edge_color.rgb * 4.0;
	} else {
		ALBEDO = albedo.rgb;
	}
}
""",
				"default_uniforms": {
					"albedo": Color(0.5, 0.5, 0.5, 1.0),
					"dissolve_amount": 0.3,
					"edge_width": 0.05,
					"edge_color": Color(1.0, 0.3, 0.0, 1.0)
				}
			}

		"hologram_3d":
			return {
				"name": "Hologram 3D",
				"type": "spatial",
				"description": "3D sci-fi projection with vertical scanlines and rim transparency.",
				"code": """shader_type spatial;
render_mode cull_disabled;

uniform vec4 holo_color : source_color = vec4(0.1, 0.8, 1.0, 0.7);
uniform float scan_speed : hint_range(0.5, 8.0, 0.5) = 3.0;
uniform float scan_lines : hint_range(10.0, 100.0, 5.0) = 40.0;

void fragment() {
	float scan = sin(VERTEX.y * scan_lines + TIME * scan_speed) * 0.5 + 0.5;
	float fresnel = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	
	ALBEDO = holo_color.rgb;
	EMISSION = holo_color.rgb * (fresnel + scan * 0.5);
	ALPHA = holo_color.a * clamp(fresnel + scan * 0.4, 0.0, 1.0);
}
""",
				"default_uniforms": {
					"holo_color": Color(0.1, 0.8, 1.0, 0.7),
					"scan_speed": 3.0,
					"scan_lines": 40.0
				}
			}

		"foliage_wind_3d":
			return {
				"name": "Foliage & Grass Wind 3D",
				"type": "spatial",
				"description": "3D vertex wind sway simulation for vegetation and grass.",
				"code": """shader_type spatial;

uniform vec4 albedo : source_color = vec4(0.2, 0.6, 0.15, 1.0);
uniform float wind_speed : hint_range(0.5, 5.0, 0.1) = 2.0;
uniform float wind_strength : hint_range(0.0, 1.0, 0.05) = 0.25;

void vertex() {
	// Upper vertices sway more (assuming positive Y is foliage top)
	float height = max(0.0, VERTEX.y);
	VERTEX.x += sin(TIME * wind_speed + VERTEX.z * 1.5) * wind_strength * height;
}

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = 0.8;
}
""",
				"default_uniforms": {
					"albedo": Color(0.2, 0.6, 0.15, 1.0),
					"wind_speed": 2.0,
					"wind_strength": 0.25
				}
			}

	return {}
