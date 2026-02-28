shader_type canvas_item;

// Define o modo de mistura como 'multiply' para agir como iluminação (luz branca = normal, escura = noite)
render_mode blend_mul;

uniform sampler2D gradient_texture : source_color;
uniform float time_of_day : hint_range(0.0, 1.0);

void fragment() {
	// Amostra a cor do gradiente baseada no horário (eixo X da textura)
	// O eixo Y é irrelevante para GradientTexture1D, usamos 0.5
	vec4 cycle_color = texture(gradient_texture, vec2(time_of_day, 0.5));
	
	// A saída do shader é a cor que multiplicará a tela
	COLOR = cycle_color;
}
