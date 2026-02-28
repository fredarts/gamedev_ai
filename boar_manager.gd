extends Node

@export var boar_scene: PackedScene
@export var boar_count: int = 3

var boars: Array = [] # Removido tipagem estática se não houver class_name

func _ready():
	# Conecta os sinais dos boars
	spawn_boars()
	
	# Conecta o sinal de morte de cada boar
	for boar in boars:
		if boar.has_method("connect") and boar.has_user_signal("died"):
			boar.connect("died", Callable(self, "boar_died"))

func spawn_boars():
	for i in range(boar_count):
		var boar = boar_scene.instantiate()
		add_child(boar)
		boar.position = Vector2(randf_range(100, 800), randf_range(100, 600))
		boars.append(boar)
		
		# Conecta o sinal de morte de cada boar
		if boar.has_method("connect") and boar.has_user_signal("died"):
			boar.connect("died", Callable(self, "boar_died"))

func all_boars_dead() -> bool:
	return get_alive_boars().is_empty()

func get_alive_boars() -> Array:
	# Filtra boars que ainda existem na memória e não estão marcados para deletar
	return boars.filter(func(b): return is_instance_valid(b) and not b.is_queued_for_deletion())

func boar_attacked(boar):
	# Lógica quando um boar é atacado
	# Pode reduzir vida, mudar animação, etc.
	pass

func boar_died(boar):
	# Remove o boar da lista quando ele morre
	boars.erase(boar)
	
	# Verifica se todos os boars morreram
	if all_boars_dead():
		# Notifica o GameManager (se existir)
		if has_node("/root/GameManager"):
			var game_manager = get_node("/root/GameManager")
			game_manager.boars_defeated()
