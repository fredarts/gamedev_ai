extends Entity

signal health_changed(new_health)
signal died

const PROJECTILE_SCENE = preload("res://projectile.tscn")

var friction = 400.0
var last_direction = Vector2.RIGHT 

@onready var anim: Sprite2D = $Sprite2D

func _ready():
	super()
	collision_layer = 2 # Garante que o Player está na Layer 2
	if not is_in_group("player"):
		add_to_group("player")
		
	if animation_component:
		animation_component.attack_speed_scale = 2.0
		
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_changed.emit(health_component.health)
	
	if anim.material is ShaderMaterial:
		(anim.material as ShaderMaterial).set_shader_parameter("progress", 0.0)

	var combat = get_node_or_null("CombatComponent")
	var hitbox = get_node_or_null("Hitbox")
	
	if combat and hitbox:
		combat.hitbox = hitbox
		combat.hit_multiple_targets = true # A espada bate em vários
		combat.attack_cooldown = 0.5 # Acompanha a velocidade do novo ataque
		hitbox.monitoring = false # Só liga quando atacar
		hitbox.monitorable = true

func _setup_light():
	var light = PointLight2D.new()
	var texture = GradientTexture2D.new()
	texture.width = 300
	texture.height = 300
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.8, 0.8)
	
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(0, 0, 0, 0))
	texture.gradient = gradient
	
	light.texture = texture
	light.color = Color(1, 0.9, 0.7)
	light.energy = 0.8
	add_child(light)

func _unhandled_input(event):
	if current_state == State.DEATH: return
	
	# Abrir inventário
	if event.is_action_pressed("inventory"):
		var inv_ui = get_node_or_null("InventoryUI")
		if inv_ui == null:
			inv_ui = get_node_or_null("CanvasLayer/InventoryUI")
		if inv_ui and inv_ui.has_method("toggle"):
			inv_ui.toggle()
	
	# Ataque/Tiro
	if event.is_action_pressed("attack"):
		attack()

func _physics_process(delta):
	if current_state == State.DEATH: return
	
	if Input.is_action_just_pressed("potion"):
		use_potion()
		
	if current_state in [State.ATTACK, State.HURT]:
		super(delta)
		return
	
	# Movimento do Jogador
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var is_running = Input.is_action_pressed("run") or Input.is_key_pressed(KEY_SHIFT)
	
	if direction != Vector2.ZERO:
		var current_speed = movement_component.run_speed if is_running else movement_component.walk_speed
		velocity = direction * current_speed
		last_direction = direction
		
		var target_state = State.RUN if is_running else State.WALK
		if current_state != target_state:
			change_state(target_state)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if velocity.length() < 10.0 and current_state != State.IDLE:
			change_state(State.IDLE)

	super(delta)

func attack():
	if current_state in [State.ATTACK, State.HURT, State.DEATH]: return
	change_state(State.ATTACK)
	
	var hitbox = get_node_or_null("Hitbox")
	if not hitbox: return
	
	# Reposiciona a Hitbox para a direção que o player está olhando
	var facing_dir = _get_facing_direction()
	hitbox.position = facing_dir * 15.0 # Ajuste a distância da hitbox
	
	# Limpa os alvos atingidos anteriormente no CombatComponent
	var combat = get_node_or_null("CombatComponent")
	if combat:
		combat._hit_targets.clear()
	
	# Liga a Hitbox para bater em quem tiver perto
	hitbox.monitoring = true
		
	# Espera o fim da animação para desligar a hitbox
	if animation_component.has_signal("animation_finished"):
		await animation_component.animation_finished
	elif animation_component.animation_player:
		await animation_component.animation_player.animation_finished
	else:
		await get_tree().create_timer(0.4).timeout # Fallback
		
	hitbox.monitoring = false

func _get_facing_direction() -> Vector2:
	if not animation_component: return last_direction
	
	match animation_component.current_direction:
		"up": return Vector2.UP
		"down": return Vector2.DOWN
		"left": return Vector2.LEFT
		"right": return Vector2.RIGHT
		_: return last_direction

func _on_took_damage(amount: int) -> void:
	super(amount) # Toca Hurt
	blink_damage()
	
func _on_health_changed(new_health: int, max_health: int) -> void:
	health_changed.emit(new_health)

func _on_died() -> void:
	health_changed.emit(0)
	super() # Deixa a Entity mudar pra DEATH e tocar a animação
	died.emit()
	# Aqui no Player, a Entity tentará dar queue_free() quando a animação acabar. 
	# Para não quebrar cenas que esperam o player morto, talvez o GameManager precise lidar com isso.

func blink_damage():
	for i in range(3):
		if anim: anim.modulate.a = 0.5
		await get_tree().create_timer(0.1).timeout
		if anim: anim.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout

func heal(amount: int):
	if current_state == State.DEATH: return
	var old_health = health_component.health
	health_component.heal(amount)
	if health_component.health > old_health:
		play_restoration_effect()

func collect_potion(texture: Texture2D, color: Color) -> bool:
	return GameManager.collect_potion(texture, color)

func use_potion():
	if current_state == State.DEATH: return
	
	# Procura no inventário por um item consumível que restaure vida
	var inv = get_node_or_null("InventoryComponent")
	if inv and inv.inventory_data:
		var data = inv.inventory_data
		for i in range(data.slots.size()):
			var slot = data.slots[i]
			if slot and slot.item_data is ConsumableItemData:
				var consumable = slot.item_data as ConsumableItemData
				if consumable.health_restored > 0 and health_component.health < health_component.max_health:
					# Usa a poção
					heal(consumable.health_restored)
					data.remove_item_at(i, 1)
					
					# Toca o som de cura se existir
					var audio = get_node_or_null("AudioComponent")
					if audio and audio.has_method("play_sfx"):
						audio.play_sfx("heal")
					return # Sai após usar 1 poção
					
		# Se chegou aqui, ou não achou poção, ou a vida já tá cheia
		if health_component.health >= health_component.max_health:
			print("Vida já está cheia!")
		else:
			print("Nenhuma poção no inventário!")
			
	else:
		# Fallback para o sistema antigo do GameManager (caso exista no mapa antigo)
		if not GameManager.has_potion: return
		if health_component.health < health_component.max_health:
			if GameManager.use_potion():
				heal(1)
		else:
			print("Vida já está cheia!")

func play_restoration_effect():
	if not anim: return
	var mat = anim.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("progress", 0.0)
		var tween = create_tween()
		tween.tween_method(func(val): mat.set_shader_parameter("progress", val), 0.0, 1.0, 2.0)

func add_to_inventory(item: ItemData, quantity: int = 1) -> bool:
	var inv = get_node_or_null("InventoryComponent")
	if inv and inv.has_method("add_item"):
		return inv.add_item(item, quantity)
	return false
