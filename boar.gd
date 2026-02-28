class_name Boar
extends Entity

signal died(boar)

@onready var health_comp: HealthComponent = $HealthComponent
@onready var move_comp: MovementComponent = $MovementComponent
@onready var anim_comp: AnimationComponent = $AnimationComponent
@onready var ai_controller: AIController = $AIController

func _ready() -> void:
	super()
	
	if not is_in_group("enemies"):
		add_to_group("enemies")
		
	# Configuração de Loot
	var loot_comp = get_node_or_null("LootComponent")
	if loot_comp:
		var meat_entry = load("res://items/loot_boar_meat_entry.tres")
		if meat_entry:
			loot_comp.loot_table.append(meat_entry)
		
	collision_layer = 4
	collision_mask = 3
	
	var combat_comp = get_node_or_null("CombatComponent")
	if combat_comp:
		combat_comp.attack_performed.connect(_on_attack_performed)
		if combat_comp.hitbox:
			combat_comp.hitbox.monitoring = true
			
	if health_comp:
		health_comp.died.connect(_on_boar_died)

func _on_boar_died() -> void:
	emit_signal("died", self)

func _on_attack_performed() -> void:
	if current_state not in [State.ATTACK, State.HURT, State.DEATH]:
		change_state(State.ATTACK)

func _physics_process(delta: float) -> void:
	if current_state == State.DEATH: return
	
	if current_state in [State.ATTACK, State.HURT]:
		super(delta) 
		return
		
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
		if velocity.length() < 10.0 and current_state not in [State.IDLE, State.ATTACK, State.HURT]:
			change_state(State.IDLE)

	super(delta)
