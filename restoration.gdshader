shader_type canvas_item;

uniform vec4 effect_color : source_color = vec4(0.2, 1.0, 0.4, 1.0); // Verde vida
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Coordenada Y invertida (0 na base, 1 no topo para cálculo de altura)
	float height = 1.0 - UV.y;
	
	// Efeito de onda subindo
	// A onda é centrada no valor de 'progress'
	float wave = 1.0 - abs(progress - height);
	wave = clamp(wave, 0.0, 1.0);
	wave = pow(wave, 8.0); // Deixa a onda bem estreita e definida
	
	// Gradiente de fundo que preenche conforme sobe
	float fill = smoothstep(progress - 0.2, progress, height);
	
	// Cor do efeito
	vec3 c = effect_color.rgb;
	
	// Intensidade do efeito
	float fade = 1.0 - smoothstep(0.8, 1.0, progress);
	float intensity = (wave + fill * 0.3) * fade;
	
	// Aplica o efeito sobre a cor original, respeitando a transparência da textura
	vec3 final_color = mix(tex_color.rgb, c, intensity);
	
	COLOR = vec4(final_color, tex_color.a);
}
