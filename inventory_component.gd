class_name InventoryComponent
extends Node

## Componente responsável por gerenciar o inventário de uma entidade (como o Player).
## Serve como ponte entre a lógica de dados (InventoryData) e o resto do jogo.

signal item_added(item: ItemData, quantity: int)
signal inventory_full

@export var inventory_data: InventoryData:
	set(value):
		inventory_data = value
		if inventory_data and not inventory_data.inventory_updated.is_connected(_on_inventory_updated):
			inventory_data.inventory_updated.connect(_on_inventory_updated)

func _ready() -> void:
	if inventory_data == null:
		# Cria um inventário padrão de 20 espaços caso nenhum seja atribuído no editor
		inventory_data = InventoryData.new()
		inventory_data.setup(20)

## Tenta adicionar um item ao inventário.
func add_item(item: ItemData, quantity: int = 1) -> bool:
	if inventory_data.add_item(item, quantity):
		item_added.emit(item, quantity)
		return true
	
	inventory_full.emit()
	return false

func _on_inventory_updated() -> void:
	# Este sinal pode ser ouvido pela interface visual para ser atualizada
	pass
