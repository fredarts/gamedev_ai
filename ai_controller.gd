class_name AIController
extends Node

enum State { ROAM, CHASE }

var current_state: State = State.ROAM
var target_player: Node2D = null

var roam_target: Vector2 = Vector2.ZERO
var roam_timer: float = 0.0

@onready var entity: CharacterBody2D = get_parent() as CharacterBody2D
@onready var movement: MovementComponent = entity.get_node("MovementComponent")
@onready var player_detector: Area2D = entity.get_node("PlayerDetector")

func _ready() -> void:
	# Definir um alvo de patrulha inicial
	_pick_new_roam_target()
	
	# Conectar sinais do PlayerDetector (Area2D)
	if player_detector:
		if not player_detector.body_entered.is_connected(_on_player_detector_body_entered):
			player_detector.body_entered.connect(_on_player_detector_body_entered)
		if not player_detector.body_exited.is_connected(_on_player_detector_body_exited):
			player_detector.body_exited.connect(_on_player_detector_body_exited)

var current_direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	match current_state:
		State.ROAM:
			_process_roam(delta)
		State.CHASE:
			_process_chase(delta)

func get_direction(current_position: Vector2) -> Vector2:
	return current_direction

func is_chasing() -> bool:
	return current_state == State.CHASE

func _process_roam(delta: float) -> void:
	roam_timer -= delta
	
	# Se chegou ao destino ou o tempo acabou, escolhe novo ponto
	if roam_timer <= 0.0 or entity.global_position.distance_to(roam_target) < 10.0:
		_pick_new_roam_target()
	
	# Mover na direção do alvo de patrulha
	current_direction = entity.global_position.direction_to(roam_target)

func _process_chase(_delta: float) -> void:
	if target_player:
		# Se estiver muito perto do player, para de andar para permitir o ataque
		# Usa 30.0 pixels para evitar colisão física direta com as paredes do Player
		if entity.global_position.distance_to(target_player.global_position) < 15.0:
			current_direction = Vector2.ZERO
		else:
			# Mover constantemente na direção do jogador
			current_direction = entity.global_position.direction_to(target_player.global_position)
	else:
		current_direction = Vector2.ZERO

func _pick_new_roam_target() -> void:
	# Escolhe uma posição aleatória em um raio de 100 pixels
	var random_offset := Vector2(randf_range(-100.0, 100.0), randf_range(-100.0, 100.0))
	roam_target = entity.global_position + random_offset
	roam_timer = randf_range(2.0, 5.0) # Move-se para o novo ponto por 2 a 5 segundos

func _on_player_detector_body_entered(body: Node2D) -> void:
	# Identifica se é o Player (pelo nome, grupo ou script)
	if body.name == "Player" or body.is_in_group("player") or body.has_method("is_player"):
		target_player = body
		current_state = State.CHASE

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null
		current_state = State.ROAM
		_pick_new_roam_target()
