extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var vignette: ColorRect = $UI_Layer/Vignette

# Duração do dia em segundos (60 segundos = 1 minuto)
@export var day_duration: float = 60.0
# Tempo atual (0.0 a 1.0), começa ao meio-dia (0.5)
@export var time_of_day: float = 0.5

var gradient: Gradient
var initial_color: Color

func _ready() -> void:
	if not canvas_modulate:
		push_error("DayNightCycle: CanvasModulate node not found!")
		return
		
	if not vignette:
		push_error("DayNightCycle: Vignette node not found inside UI_Layer!")
	else:
		# Configura o Vignette
		vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
		vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Carrega e aplica o shader de vinheta
		var vignette_shader = load("res://vignette.gdshader")
		if vignette_shader:
			var vignette_mat = ShaderMaterial.new()
			vignette_mat.shader = vignette_shader
			vignette.material = vignette_mat
		else:
			push_error("DayNightCycle: Could not load vignette.gdshader")

	setup_gradient()

func _process(delta: float) -> void:
	# Atualiza o tempo
	var time_speed = 1.0 / day_duration
	time_of_day += time_speed * delta
	
	if time_of_day >= 1.0:
		time_of_day = 0.0 # Reinicia o dia
	
	# Aplica a cor do ciclo ao CanvasModulate
	if canvas_modulate and gradient:
		var color = gradient.sample(time_of_day)
		canvas_modulate.color = color

func setup_gradient() -> void:
	gradient = Gradient.new()
	
	# Configura o ponto 0 (Início - Meia-noite)
	gradient.set_color(0, Color(0.1, 0.1, 0.25)) # Azul escuro
	gradient.set_offset(0, 0.0)
	
	# Ponto Final (índice 1 original) -> Noite
	gradient.set_color(1, Color(0.1, 0.1, 0.25))
	
	# Adiciona os intervalos do dia
	gradient.add_point(0.25, Color(0.8, 0.5, 0.4)) # Amanhecer (Alaranjado)
	gradient.add_point(0.5, Color(1.0, 1.0, 1.0))  # Meio-dia (Branco total)
	gradient.add_point(0.75, Color(0.4, 0.3, 0.6)) # Entardecer (Roxo/Azulado)
