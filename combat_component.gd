class_name CombatComponent
extends Node

## Sinal emitido quando um ataque é realizado com sucesso (inicia o cooldown).
signal attack_performed
## Sinal emitido quando o dano é efetivamente causado a um alvo.
signal damage_dealt(amount: int, is_critical: bool, target: Node)

@export_group("Stats")
## Dano base do ataque.
@export var base_damage: int = 10
## Chance de causar um acerto crítico (0.0 a 1.0).
@export_range(0.0, 1.0) var critical_chance: float = 0.1
## Multiplicador de dano aplicado no acerto crítico.
@export var critical_multiplier: float = 2.0
## Força de empurrão (knockback) aplicada ao alvo.
@export var knockback_force: float = 200.0

@export_group("Timing")
## Tempo em segundos antes que a entidade possa atacar novamente.
@export var attack_cooldown: float = 1.0
## Se ativo, permite atingir vários alvos num único ataque (ideal para espadas do Player).
@export var hit_multiple_targets: bool = false

@export_group("References")
## Opcional: O Area2D usado como hitbox (área de acerto). 
## Se preenchido, o componente tenta atacar automaticamente o que entrar na área.
@export var hitbox: Area2D

var _can_attack: bool = true
var _cooldown_timer: Timer
var _hit_targets: Array[Node] = []
var _was_monitoring: bool = false

func _ready() -> void:
	_setup_cooldown_timer()
	
	if hitbox:
		# Conecta aos sinais de Area e Body para suportar Hurtboxes e Corpos Físicos (CharacterBody2D)
		hitbox.area_entered.connect(_on_hitbox_entered)
		hitbox.body_entered.connect(_on_hitbox_entered)

func _setup_cooldown_timer() -> void:
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.wait_time = attack_cooldown
	_cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(_cooldown_timer)

## Tenta realizar um ataque contra o alvo. Retorna 'true' se o ataque for bem-sucedido.
func attempt_attack(target: Node) -> bool:
	if not _can_attack or not is_instance_valid(target):
		return false
		
	if target in _hit_targets:
		return false # Já atingiu neste ataque!
		
	var did_damage: bool = _deal_damage_to(target)
	
	if did_damage:
		_hit_targets.append(target)
		
		# Avisa que o ataque ocorreu
		attack_performed.emit()
		
		# Só entra em cooldown instantâneo se for ataque focado (ex: mordida de Orc).
		# Espadas (múltiplos alvos) são controladas pela duração da Hitbox.
		if not hit_multiple_targets:
			_start_cooldown()
			
		# Imprime no Output do Godot para termos certeza de quantas vezes ele atacou
		print("[Combat] Ataque realizado contra: ", target.name, " | Dano causado.")
		
	return did_damage

func _deal_damage_to(target: Node) -> bool:
	if not is_instance_valid(target): return false
	
	var health_comp: Node = _find_health_component(target)
	
	if health_comp and health_comp.has_method("take_damage"):
		var damage_info: Dictionary = _calculate_damage()
		var final_damage: int = damage_info["amount"]
		var is_crit: bool = damage_info["is_critical"]
		
		# Aplica o dano chamando a função do HealthComponent
		health_comp.take_damage(final_damage)
		
		# Aplica knockback
		var root_target: Node = target
		if not root_target.has_method("apply_knockback") and root_target.owner and root_target.owner.has_method("apply_knockback"):
			root_target = root_target.owner
			
		if root_target.has_method("apply_knockback") and is_instance_valid(owner):
			root_target.apply_knockback(owner.global_position, knockback_force)
		
		damage_dealt.emit(final_damage, is_crit, target)
		return true
		
	return false

func _calculate_damage() -> Dictionary:
	var is_crit: bool = randf() <= critical_chance
	var final_damage: int = base_damage
	
	if is_crit:
		final_damage = int(float(base_damage) * critical_multiplier)
		
	return {
		"amount": final_damage,
		"is_critical": is_crit
	}

func _start_cooldown() -> void:
	_can_attack = false
	_cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	_can_attack = true
	_hit_targets.clear()

func _physics_process(delta: float) -> void:
	if hitbox:
		# Detecta quando a Hitbox acabou de ser ligada (início do ataque da espada)
		if hitbox.monitoring and not _was_monitoring:
			_hit_targets.clear()
		_was_monitoring = hitbox.monitoring

	if not _can_attack or not hitbox or not hitbox.monitoring:
		return
		
	# Tenta atacar continuamente alvos que permanecem dentro da Hitbox
	for body in hitbox.get_overlapping_bodies():
		if body == owner or body.owner == owner: continue
		attempt_attack(body)
			
	for area in hitbox.get_overlapping_areas():
		if area == owner or area.owner == owner: continue
		attempt_attack(area)

func _on_hitbox_entered(node: Node) -> void:
	# Evita que o dono do ataque bata nele mesmo
	if node == owner or node.owner == owner:
		return
		
	# Tenta atingir o corpo do CharacterBody
	attempt_attack(node)
		
	# Tenta atingir o dono da Hitbox/Hurtbox (caso o Area2D seja filho do Inimigo)
	if node.owner and node.owner != owner:
		attempt_attack(node.owner)

## Busca de forma inteligente o HealthComponent no alvo.
func _find_health_component(target: Node) -> Node:
	# 1. Busca PRIMEIRO por um filho chamado "HealthComponent" para priorizar a composição
	var comp := target.get_node_or_null("HealthComponent")
	if comp and comp.has_method("take_damage"):
		return comp
		
	# 2. Varre os filhos procurando um componente que tenha o método take_damage
	for child in target.get_children():
		if child.name == "HealthComponent" or child.has_method("take_damage"):
			return child
			
	# 3. Se não achou nenhum componente filho, tenta o próprio alvo
	if target.has_method("take_damage"):
		return target
			
	return null
