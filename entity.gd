class_name Entity
extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	RUN,
	ATTACK,
	HURT,
	DEATH
}

var current_state: State = State.IDLE

@export var animation_component: AnimationComponent
@export var health_component: Node
@export var movement_component: Node
@export var loot_component: Node ## Componente opcional para drops
@export var audio_component: Node2D ## Componente opcional para audio

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 800.0

func _ready() -> void:

	# 1. Busca automática dos componentes caso não estejam referenciados
	if not animation_component:
		animation_component = get_node_or_null("AnimationComponent")
	if not health_component:
		health_component = get_node_or_null("HealthComponent")
	if not movement_component:
		movement_component = get_node_or_null("MovementComponent")
	if not loot_component:
		loot_component = get_node_or_null("LootComponent")
	if not audio_component:
		audio_component = get_node_or_null("AudioComponent")
		
	# 2. Conecta os sinais de Vida para Ativar Animações de Dano e Morte Automaticamente
	if health_component:
		if health_component.has_signal("took_damage"):
			if not health_component.took_damage.is_connected(_on_took_damage):
				health_component.took_damage.connect(_on_took_damage)
		# Suporte legado para health_changed
		elif health_component.has_signal("health_changed"):
			if not health_component.health_changed.is_connected(_on_health_changed):
				health_component.health_changed.connect(_on_health_changed)
				
		if health_component.has_signal("died"):
			if not health_component.died.is_connected(_on_died):
				health_component.died.connect(_on_died)
			
	# 3. Conecta o sinal de fim de animação para Destravar as Ações (Ataque/Dano)
	if animation_component:
		if animation_component.has_signal("animation_finished"):
			if not animation_component.animation_finished.is_connected(_on_animation_finished):
				animation_component.animation_finished.connect(_on_animation_finished)
		elif animation_component.animation_player:
			if not animation_component.animation_player.animation_finished.is_connected(_on_animation_finished):
				animation_component.animation_player.animation_finished.connect(_on_animation_finished)

# =========================================================
# MÁQUINA DE ESTADOS - O CORAÇÃO DO SISTEMA
# =========================================================
func change_state(new_state: State) -> void:
	if current_state == State.DEATH:
		return # Um monstro morto não levanta e não muda de estado!
		
	current_state = new_state
	
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			if animation_component: animation_component.play("idle")
		State.WALK:
			if animation_component: animation_component.play("walk")
		State.RUN:
			if animation_component: animation_component.play("run")
		State.ATTACK:
			velocity = Vector2.ZERO # Trava o monstro no lugar para atacar
			if animation_component: animation_component.play("attack")
		State.HURT:
			velocity = Vector2.ZERO # Trava o monstro ao tomar porrada
			if animation_component: animation_component.play("hurt")
		State.DEATH:
			velocity = Vector2.ZERO # Cai morto
			if animation_component: animation_component.play("death")
			
			# Opcional: Desativa colisões para o Player passar por cima
			var col = get_node_or_null("CollisionShape2D")
			if col: col.set_deferred("disabled", true)
			
			# Solta o loot no momento da morte
			if loot_component and loot_component.has_method("drop_loot"):
				loot_component.drop_loot()

func apply_knockback(source_position: Vector2, force: float) -> void:
	if current_state == State.DEATH: return
	var direction_away := (global_position - source_position).normalized()
	if direction_away == Vector2.ZERO: direction_away = Vector2.RIGHT
	knockback_velocity = direction_away * force

## Função auxiliar para ser chamada pelo AnimationPlayer (Call Method Track)
func play_sfx(sfx_name: StringName) -> void:
	if audio_component:
		audio_component.play_sfx(sfx_name)

func _physics_process(delta: float) -> void:
	# Aplica knockback globalmente, sobrepondo o movimento normal
	if knockback_velocity.length() > 50:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		move_and_slide()
		return
	elif knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

	# 1. Trava de Ação: Se estiver atacando, tomando dano ou morto, só aplica física, não obedece controles!
	if current_state in [State.ATTACK, State.HURT, State.DEATH]:
		velocity = Vector2.ZERO # Garante que para de andar ao apanhar/atacar
		move_and_slide()
		return
		
	# 2. Atualiza a "Bússola Interna" automaticamente se estiver se movendo
	if velocity != Vector2.ZERO and animation_component:
		animation_component.update_direction(velocity)
	
	move_and_slide()

# =========================================================
# GATILHOS AUTOMÁTICOS
# =========================================================
func _on_took_damage(_amount: int) -> void:
	if current_state != State.DEATH:
		if animation_component:
			animation_component.flash_damage()
		# Se já estiver atacando, não interrompe para tocar HURT para manter fluido (Opcional)
		if current_state != State.ATTACK:
			change_state(State.HURT)

func _on_health_changed(old_value: int, new_value: int) -> void:
	# Compatibilidade legada caso use old_value e new_value
	if new_value < old_value and current_state != State.DEATH:
		if animation_component:
			animation_component.flash_damage()
		if current_state != State.ATTACK:
			change_state(State.HURT)

func _on_died() -> void:
	change_state(State.DEATH)

func _on_animation_finished(anim_name: String) -> void:
	# Limpa o sufixo da direção (ex: "attack_right" vira "attack")
	var base_anim = anim_name.split("_")[0]
	
	# Destrava o monstro após a ação terminar e devolve ele pro IDLE
	if current_state == State.ATTACK and base_anim == "attack":
		change_state(State.IDLE)
	elif current_state == State.HURT and base_anim == "hurt":
		change_state(State.IDLE)
	elif current_state == State.DEATH and base_anim == "death":
		queue_free()
