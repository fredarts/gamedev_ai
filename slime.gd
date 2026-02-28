class_name Slime
extends Entity

signal died(enemy_instance)

const POTION_SCENE = preload("res://potion.tscn")

@export var drop_chance: float = 0.25

@onready var ai_controller: AIController = $AIController
@onready var combat_comp: CombatComponent = $CombatComponent

func _ready() -> void:
	super()
	
	if not is_in_group("enemies"):
		add_to_group("enemies")

	collision_layer = 4
	collision_mask = 3
	
	if combat_comp:
		combat_comp.attack_performed.connect(_on_attack_performed)
		
	if health_component and health_component.has_signal("died"):
		health_component.died.connect(_on_slime_died)

func _on_attack_performed() -> void:
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
		var current_speed = movement_component.run_speed if is_chasing else movement_component.walk_speed
		velocity = direction * current_speed
		
		# Slime does not have a "run" animation, so let's use "walk" for both
		var target_state = State.WALK
		if current_state != target_state:
			change_state(target_state)
	else:
		velocity.x = move_toward(velocity.x, 0, 800 * delta)
		velocity.y = move_toward(velocity.y, 0, 800 * delta)
		if current_state != State.IDLE:
			change_state(State.IDLE)

	super(delta)

func _on_slime_died() -> void:
	if randf() <= drop_chance:
		call_deferred("spawn_loot")
	died.emit(self)

func spawn_loot() -> void:
	var potion = POTION_SCENE.instantiate()
	potion.global_position = global_position
	get_parent().add_child(potion)
