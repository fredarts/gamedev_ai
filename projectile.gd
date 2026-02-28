extends Area2D

const SPEED = 400.0
var direction = Vector2.RIGHT

func _ready():
	# --- CONFIGURAÇÃO CRÍTICA DE COLISÃO ---
	# O Projétil precisa MONITORAR colisões para disparar sinais.
	monitoring = true
	monitorable = false 
	# Collision Layer/Mask configurados na cena (projectile.tscn)

	# --- CONEXÃO DO SINAL ---
	# Conecta o sinal body_entered à função _on_body_entered se ainda não estiver conectado.
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	# Destroi o projétil após 2 segundos
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * SPEED * delta

func _on_body_entered(body):
	# Verifica se bateu em um Inimigo
	if body.is_in_group("enemies"):
		var hc = body.get_node_or_null("HealthComponent")
		if hc and hc.has_method("take_damage"):
			hc.take_damage(1)
		elif body.has_method("take_damage"):
			body.take_damage(1)
		
		# Knockback
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position, 300.0)
			
		queue_free() # Destroi o projétil ao acertar inimigo
	
	# Verifica se bateu em Parede/Mundo (não é Player nem Area2D)
	# O Player deve ser ignorado para não se auto-atingir logo ao nascer
	elif not body.is_in_group("player") and not body is Area2D:
		queue_free()
