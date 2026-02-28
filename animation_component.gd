class_name AnimationComponent
extends Node

@export var sprite: Node2D # Pode ser Sprite2D ou AnimatedSprite2D
@export var animation_player: AnimationPlayer
@export var animated_sprite: AnimatedSprite2D
@export var attack_speed_scale: float = 1.0

signal animation_finished(anim_name: String)

var current_direction: String = "down" # Essa é a bússola interna (não a state machine)
var current_state: String = "idle"
var _base_speed_scale: float = 1.0

func _ready() -> void:
	if not sprite:
		sprite = get_parent().get_node_or_null("Sprite2D")
		if not sprite:
			sprite = get_parent().get_node_or_null("AnimatedSprite2D")
			
	if not animated_sprite and sprite is AnimatedSprite2D:
		animated_sprite = sprite as AnimatedSprite2D
		
	if animated_sprite and not animated_sprite.animation_finished.is_connected(_on_animated_sprite_finished):
		animated_sprite.animation_finished.connect(_on_animated_sprite_finished)
		
	if not animation_player:
		animation_player = get_parent().get_node_or_null("AnimationPlayer")
		
	if animation_player and not animation_player.animation_finished.is_connected(_on_animation_player_finished):
		animation_player.animation_finished.connect(_on_animation_player_finished)
		
	# Armazena a velocidade base configurada no editor
	if animation_player:
		_base_speed_scale = animation_player.speed_scale
	elif animated_sprite:
		_base_speed_scale = animated_sprite.speed_scale

func update_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
		
	# Calcula para que lado o monstro está olhando usando Matemática
	if abs(direction.x) > abs(direction.y):
		current_direction = "right" if direction.x > 0 else "left"
	else:
		current_direction = "down" if direction.y > 0 else "up"
	
	# Se a direção virar no meio de uma caminhada, atualiza!
	_play_current_animation()

func play(state_name: String) -> void:
	# Só muda de animação se o estado recebido da State Machine for novo
	if current_state != state_name:
		current_state = state_name
		_play_current_animation()

func _play_current_animation() -> void:
	# Aqui a mágica acontece: Mistura o ESTADO e a DIREÇÃO automaticamente
	var anim_name := current_state + "_" + current_direction
	
	if animation_player:
		if animation_player.has_animation(anim_name):
			if animation_player.current_animation != anim_name:
				animation_player.play(anim_name)
				if current_state == "attack":
					animation_player.speed_scale = _base_speed_scale * attack_speed_scale
				else:
					animation_player.speed_scale = _base_speed_scale
		elif animation_player.has_animation(current_state):
			if animation_player.current_animation != current_state:
				animation_player.play(current_state)
				if current_state == "attack":
					animation_player.speed_scale = _base_speed_scale * attack_speed_scale
				else:
					animation_player.speed_scale = _base_speed_scale
				
	elif animated_sprite:
		if animated_sprite.sprite_frames.has_animation(anim_name):
			if animated_sprite.animation != anim_name or not animated_sprite.is_playing():
				animated_sprite.play(anim_name)
				if current_state == "attack":
					animated_sprite.speed_scale = _base_speed_scale * attack_speed_scale
				else:
					animated_sprite.speed_scale = _base_speed_scale
		elif animated_sprite.sprite_frames.has_animation(current_state):
			if animated_sprite.animation != current_state or not animated_sprite.is_playing():
				animated_sprite.play(current_state)
				if current_state == "attack":
					animated_sprite.speed_scale = _base_speed_scale * attack_speed_scale
				else:
					animated_sprite.speed_scale = _base_speed_scale

func flash_damage() -> void:
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _on_animation_player_finished(anim_name: String) -> void:
	animation_finished.emit(anim_name)

func _on_animated_sprite_finished() -> void:
	if animated_sprite:
		animation_finished.emit(animated_sprite.animation)
