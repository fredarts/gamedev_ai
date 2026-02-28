class_name LootComponent
extends Node

## Componente responsável por gerenciar e dropar itens (Loot) quando a entidade morre ou é destruída.
## Deve ser configurado com uma lista de LootTableEntries.

@export_category("Configuração de Loot")
@export var loot_table: Array[LootTableEntry] = [] ## Lista de itens que podem cair
@export var drop_radius: float = 30.0 ## Raio máximo onde os itens vão cair (espalhados)
@export var drop_height: float = 16.0 ## Altura da parábola visual
@export var drop_duration: float = 0.5 ## Tempo que o item leva para cair

## Cena base do ItemPickup para ser instanciada
const ITEM_PICKUP_SCENE: PackedScene = preload("res://item_pickup.tscn")

## Chamado externamente (ex: pelo HealthComponent ao morrer)
func drop_loot() -> void:
	if loot_table.is_empty():
		return
		
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		push_warning("LootComponent precisa estar dentro de um Node2D!")
		return
		
	var drop_position: Vector2 = parent.global_position
	
	for entry in loot_table:
		if not entry.item_data:
			continue
			
		# Rola o dado (0.0 a 1.0)
		if randf() <= entry.chance:
			var count: int = entry.get_drop_count()
			for i in range(count):
				_spawn_item(entry.item_data, drop_position)

func _spawn_item(item_data: ItemData, origin: Vector2) -> void:
	var pickup_instance = ITEM_PICKUP_SCENE.instantiate()
	
	# Configura o dado do item ANTES de adicionar à árvore
	pickup_instance.item_data = item_data
	
	# Adiciona à cena atual (World) para não ser deletado junto com o monstro
	get_tree().current_scene.call_deferred("add_child", pickup_instance)
	
	# Configura posição inicial e alvo
	pickup_instance.global_position = origin
	
	var random_angle: float = randf() * TAU
	var random_distance: float = randf_range(10.0, drop_radius)
	var target_offset: Vector2 = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	var target_pos: Vector2 = origin + target_offset
	
	# Chama o método de lançamento que agora lida com _ready pendente
	if pickup_instance.has_method("launch_drop"):
		pickup_instance.launch_drop(target_pos, drop_height, drop_duration)
