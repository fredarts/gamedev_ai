class_name Orc
extends Entity

@onready var health_comp: HealthComponent = $HealthComponent
@onready var move_comp: MovementComponent = $MovementComponent
@onready var anim_comp: AnimationComponent = $AnimationComponent
@onready var ai_controller: AIController = $AIController

func _ready() -> void:
	# Como Orc agora herda de Entity, chamamos o super() para inicializar a State Machine Base
	# A classe Entity JÁ conecta os sinais _on_health_changed e _on_died automaticamente!
	super()
	
	if not is_in_group("enemies"):
		add_to_group("enemies")
		
	# Configuração de Loot para teste
	var loot_comp = get_node_or_null("LootComponent")
	if loot_comp:
		# Adiciona a poção à tabela de drops
		var potion_entry = load("res://items/loot_potion_entry.tres")
		if potion_entry:
			loot_comp.loot_table.append(potion_entry)
		
	collision_layer = 4
	collision_mask = 3
	
	if ai_controller:
		# Inicializamos o AI apenas setando o dono, já que 'init' não existe no seu ai_controller.gd
		# (O seu script só precisa do 'get_direction', então não precisamos inicializar ele aqui se não tem função init)
		pass
		
	var combat_comp = get_node_or_null("CombatComponent")
	if combat_comp:
		combat_comp.attack_performed.connect(_on_attack_performed)
		# Garante que a hitbox monitore constantemente quem está dentro dela para não falhar o ataque
		if combat_comp.hitbox:
			combat_comp.hitbox.monitoring = true

func _on_attack_performed() -> void:
	# O inimigo só muda pro ataque se já não estiver em ação
	if current_state not in [State.ATTACK, State.HURT, State.DEATH]:
		change_state(State.ATTACK)

func _physics_process(delta: float) -> void:
	# 1. Se o monstro estiver morto, bloqueia o controle.
	if current_state == State.DEATH: return
	
	# 2. Se o monstro estiver atacando ou sofrendo dano, travar o movimento (fazer apenas a física de deslize)
	if current_state in [State.ATTACK, State.HURT]:
		# Não chama o super com delta senão ele tenta atualizar a bússola enquanto toma porrada.
		# Chama direto o move_and_slide que já está dentro do apply_knockback (ou do super)
		super(delta) 
		return
		
	# 3. Aqui a inteligência do Orc só define ONDE ele quer ir.
	# A State Machine do Entity cuida de que animação tocar e de virar o monstro para a direção correta.
	var direction: Vector2 = Vector2.ZERO
	var is_chasing: bool = false
	
	if ai_controller:
		if ai_controller.has_method("get_direction"):
			direction = ai_controller.get_direction(global_position)
		if ai_controller.has_method("is_chasing"):
			is_chasing = ai_controller.is_chasing()
	
	if direction != Vector2.ZERO:
		var current_speed = move_comp.run_speed if is_chasing else move_comp.walk_speed
		velocity = direction * current_speed
		
		var target_state = State.RUN if is_chasing else State.WALK
		if current_state != target_state:
			change_state(target_state)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 800 * delta)
		# Se não tem direção, ou ele tá atacando, ou tá parado.
		if velocity.length() < 10.0 and current_state not in [State.IDLE, State.ATTACK, State.HURT]:
			change_state(State.IDLE)

	super(delta) # Chama o physics process da classe base para aplicar o move_and_slide e atualizações de direção!
