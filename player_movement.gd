extends CharacterBody2D

@export var speed = 200.0
var knockback_velocity = Vector2.ZERO

func _ready():
	# Zoom na câmera para ver melhor
	$Camera2D.zoom = Vector2(1.5, 1.5)

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	# Adiciona o vetor de empurrão (knockback)
	velocity += knockback_velocity
	
	# Reduz o empurrão gradualmente (fricção)
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
		
	move_and_slide()

func take_damage(source_position: Vector2, force: float):
	# Calcula a direção oposta à origem do dano
	var knockback_direction = global_position - source_position
	knockback_direction = knockback_direction.normalized()
	knockback_velocity = knockback_direction * force
