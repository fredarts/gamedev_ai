class_name ItemPickup
extends Area2D

## Cena genérica que representa QUALQUER item caído no chão do mundo.
## Ela lê as informações do Resource (ItemData) para se auto-configurar.

@export var item_data: ItemData

@onready var sprite: Sprite2D = $Sprite2D
@onready var light: PointLight2D = $Sprite2D/PointLight2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var _is_dropping: bool = false ## Flag para saber se está na animação de queda
var _float_tween: Tween ## Referência ao tween de flutuação para evitar conflitos

func _ready() -> void:
	# Se não tiver item_data, tenta carregar um padrão ou avisa erro
	if not item_data:
		push_warning("ItemPickup sem ItemData configurado: ", name)
		# Opcional: queue_free() se for crítico
		return
		
	_setup_visuals()
	
	# Se NÃO estiver caindo (instanciado direto no chão pelo editor), inicia flutuação
	if not _is_dropping:
		_start_floating_animation()
	
	# Conecta sinal de colisão com player
	body_entered.connect(_on_body_entered)

func _setup_visuals() -> void:
	# 1. Configura a arte pixel art
	if item_data.icon:
		sprite.texture = item_data.icon
	
	# 2. Garante colisor
	if not collision.shape:
		var circle := CircleShape2D.new()
		circle.radius = 12.0
		collision.shape = circle
	
	# 3. Configura a luz (Efeito Cinematográfico)
	if item_data.drop_light_color != Color.TRANSPARENT:
		light.color = item_data.drop_light_color
		light.enabled = true
	else:
		light.enabled = false

## Inicia a animação de "pulo/parábola" ao ser dropado de um monstro/baú
func launch_drop(target_position: Vector2, height: float = 16.0, duration: float = 0.5) -> void:
	if not is_node_ready():
		await ready
		
	_is_dropping = true
	collision.set_deferred("disabled", true) # Desativa colisão durante o voo
	
	# Tween principal para mover X/Y no mundo
	var tween_pos = create_tween()
	tween_pos.tween_property(self, "global_position", target_position, duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Tween secundário para o arco visual (Sprite Y)
	var tween_arc = create_tween()
	# Sobe
	tween_arc.tween_property(sprite, "position:y", -height, duration * 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Desce
	tween_arc.tween_property(sprite, "position:y", 0.0, duration * 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Quando terminar de cair
	tween_pos.finished.connect(_on_landed)

func _on_landed() -> void:
	_is_dropping = false
	collision.set_deferred("disabled", false) # Pode pegar agora (usando set_deferred por segurança física)
	
	# Efeito visual de impacto no chão (opcional, pode ser particulas de poeira)
	# O player pediu som e partícula no PICKUP, mas um "thud" aqui seria legal também.
	
	# Inicia a animação de idle
	_start_floating_animation()

## Cria uma animação contínua (Hover) de subir e descer suavemente
func _start_floating_animation() -> void:
	# Mata tweens anteriores no sprite para evitar conflito
	if _float_tween and _float_tween.is_valid():
		_float_tween.kill()
		
	_float_tween = create_tween().set_loops()
	# Sobe um pouco
	_float_tween.tween_property(sprite, "position:y", -4.0, 1.0).as_relative() \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Desce de volta
	_float_tween.tween_property(sprite, "position:y", 4.0, 1.0).as_relative() \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	# Otimização com StringName (&"Player") ou checando o script do corpo
	if body.name == &"Player" or body.has_method("add_to_inventory"):
		_pickup(body)

func _pickup(player_node: Node2D) -> void:
	# INTEGRAÇÃO COM O INVENTÁRIO
	if player_node.has_method("add_to_inventory"):
		var added = player_node.add_to_inventory(item_data)
		if not added:
			print("Inventário cheio! Não foi possível pegar o item: ", item_data.name if item_data else "Desconhecido")
			return # Impede de deletar o item se o inventário estiver cheio
		else:
			print("Pegou item: ", item_data.name if item_data else "Desconhecido")
	
	# Desabilita interação dupla
	collision.set_deferred("disabled", true)
	sprite.visible = false
	light.enabled = false
	
	# Instancia o efeito de partículas (Puff!) na posição do item
	if item_data.pickup_effect:
		var effect_instance := item_data.pickup_effect.instantiate() as Node2D
		if effect_instance:
			get_tree().current_scene.add_child(effect_instance)
			effect_instance.global_position = global_position # Usa posição global do Area2D
	
	# Se tiver som de pickup, toca e espera terminar antes de destruir
	if item_data.pickup_sound:
		audio_player.stream = item_data.pickup_sound
		audio_player.play()
		await audio_player.finished
	
	# Limpa o item do chão
	queue_free()
