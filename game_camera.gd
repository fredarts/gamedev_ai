extends Camera2D

# O alvo que a câmera deve seguir
@export var target: Node2D
@export var smooth_speed: float = 5.0

func _ready():
	# Habilita o sistema nativo de suavização da Godot
	position_smoothing_enabled = true
	position_smoothing_speed = smooth_speed
	
	# Opcional: Para Pixel Art, isso ajuda a evitar "tremeliques" sub-pixel
	# Mas o principal é a suavização acima.
	# get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS

func _physics_process(delta):
	if is_instance_valid(target):
		# Apenas definimos a posição "ideal" aqui.
		# A propriedade 'position_smoothing_enabled' vai fazer a câmera
		# "viajar" até essa posição suavemente a cada frame de renderização,
		# eliminando o jitter causado por diferenças de FPS.
		global_position = target.global_position
