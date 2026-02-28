extends Node

const ENEMY_SCENE = preload("res://slime.tscn")
const GAME_CAMERA_SCRIPT = preload("res://game_camera.gd")
const DAY_NIGHT_SCENE = preload("res://day_night_cycle.tscn")

@onready var player = $Player
@onready var hud = $HUD

# Referência para a nova câmera independente
var game_camera: Camera2D

func _ready():
	_setup_day_night_cycle()
	# Garante que o HUD processe input mesmo com o jogo pausado
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Configura HUD inicial
	var max_hp = player.health_component.max_health
	hud.update_health(player.health_component.health, max_hp)
	
	# Conecta sinais
	player.health_component.health_changed.connect(func(new_hp, new_max_hp): hud.update_health(new_hp, new_max_hp))
	player.died.connect(_on_player_died)
	
	# --- Configuração da Câmera ---
	_setup_game_camera()

	# --- Configuração Inimigos Iniciais ---
	for node in get_children():
		if node.is_in_group("enemies"):
			connect_enemy_signals(node)

func _setup_day_night_cycle():
	if not has_node("DayNightCycle"):
		var cycle = DAY_NIGHT_SCENE.instantiate()
		add_child(cycle)

func _setup_game_camera():
	# 1. Desativa a câmera interna do Player se existir
	var player_cam = player.get_node_or_null("Camera2D")
	if player_cam:
		player_cam.enabled = false
		player_cam.queue_free() # Remove para evitar confusão

	# 2. Cria a nova câmera independente
	game_camera = Camera2D.new()
	game_camera.name = "GameCamera"
	
	# Anexa o script de movimento suave
	game_camera.set_script(GAME_CAMERA_SCRIPT)
	
	# Configura propriedades do script
	game_camera.target = player
	game_camera.smooth_speed = 5.0 # Ajuste este valor para mais/menos suavidade
	
	# Adiciona à cena (World)
	add_child(game_camera)
	
	# Define posição inicial para não "pular"
	game_camera.global_position = player.global_position
	game_camera.make_current()

	# 3. Configura os limites da nova câmera
	_setup_camera_limits()

func _setup_camera_limits():
	var landscape = $Terrain
	if not landscape:
		return
		
	var bounds = Rect2()
	var first = true
	
	for child in landscape.get_children():
		if child is Sprite2D:
			var transform = child.global_transform
			var local_rect = child.get_rect()
			
			var corners = [
				transform * local_rect.position,
				transform * (local_rect.position + Vector2(local_rect.size.x, 0)),
				transform * (local_rect.position + Vector2(0, local_rect.size.y)),
				transform * (local_rect.position + local_rect.size)
			]
			
			for point in corners:
				if first:
					bounds.position = point
					bounds.size = Vector2.ZERO
					first = false
				else:
					bounds = bounds.expand(point)
	
	# Aplica na câmera independente
	if not first and game_camera:
		game_camera.limit_left = int(bounds.position.x)
		game_camera.limit_top = int(bounds.position.y)
		game_camera.limit_right = int(bounds.end.x)
		game_camera.limit_bottom = int(bounds.end.y)

func _on_player_died():
	hud.show_game_over()

func connect_enemy_signals(enemy):
	if enemy.has_signal("died"):
		if not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy_instance):
	GameManager.add_score(1) # Atualizado para usar função do GameManager
	# hud.update_score já é chamado pelo sinal score_updated
	var spawn_pos = enemy_instance.global_position
	schedule_respawn(spawn_pos)

func schedule_respawn(pos: Vector2):
	await get_tree().create_timer(5.0).timeout
	if not is_inside_tree():
		return
	spawn_enemy(pos)

func spawn_enemy(pos: Vector2):
	var new_enemy = ENEMY_SCENE.instantiate()
	new_enemy.global_position = pos
	add_child(new_enemy)
	connect_enemy_signals(new_enemy)
