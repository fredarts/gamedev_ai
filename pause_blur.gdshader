shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount : hint_range(0.0, 2.0) = 2.0;

void fragment() {
	vec4 blur = textureLod(screen_texture, SCREEN_UV, amount);
	COLOR = mix(blur, vec4(COLOR.rgb, 1.0), COLOR.a);
}
