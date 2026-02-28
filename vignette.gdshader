shader_type canvas_item;
render_mode blend_mul;

uniform float vignette_intensity : hint_range(0.0, 2) = 0.6; // Aumentei o range e o default
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.9;
uniform vec4 vignette_rgb : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	// Centro da tela em UV é (0.5, 0.5)
	float dist = distance(UV, vec2(0.5));
	
	// Multiplica a distância pela intensidade.
	// Se intensidade for alta, 'val' chega a 1.0 mais rápido (vinheta maior).
	float val = dist * vignette_intensity;
	
	// Clamp para garantir 0-1
	val = clamp(val, 0.0, 1.0);
	
	// Suaviza a borda. Quanto menor o primeiro valor, mais suave o início.
	// smoothstep(edge0, edge1, x)
	val = smoothstep(0.0, 2, val);
	
	// Mistura:
	// val = 0 (centro) -> cor branca (1.0) -> multiply não afeta
	// val = 1 (borda) -> cor da vinheta (vignette_rgb) misturada pela opacidade
	
	// Cor final: começa branca e vai escurecendo nas bordas
	vec3 out_color = mix(vec3(1.0), vignette_rgb.rgb, val * vignette_opacity);
	
	COLOR = vec4(out_color, 1.0);
}
