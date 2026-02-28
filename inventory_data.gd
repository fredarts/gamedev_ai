class_name InventoryData
extends Resource

## Armazena os dados inteiros do inventário de uma entidade, como a lista de slots.

signal inventory_updated

@export var slots: Array[InventorySlotData] = []

## Preenche o array com slots vazios e conecta os sinais.
func setup(size: int = 20) -> void:
	slots.clear()
	slots.resize(size)
	for i in range(size):
		var slot := InventorySlotData.new()
		slot.slot_updated.connect(_on_slot_changed)
		slots[i] = slot

## Adiciona um item ao inventário. Retorna true se coube tudo, false se encheu antes.
func add_item(item: ItemData, quantity: int = 1) -> bool:
	if item == null or quantity <= 0:
		return false
		
	# 1. Tentar empilhar em slots que já possuem o item (e não estão cheios)
	for slot in slots:
		if slot != null and slot.item_data == item:
			if slot.quantity < item.max_stack:
				var available_space := item.max_stack - slot.quantity
				if available_space >= quantity:
					slot.quantity += quantity
					return true
				else:
					slot.quantity += available_space
					quantity -= available_space
					
	# 2. Procurar um slot vazio para o que sobrou
	for slot in slots:
		if slot != null and slot.item_data == null:
			slot.set_item(item, quantity)
			return true
			
	return false # Não coube tudo (inventário cheio)

## Remove uma quantidade específica de um item pelo índice do slot.
func remove_item_at(index: int, amount: int = 1) -> void:
	if index < 0 or index >= slots.size() or slots[index] == null:
		return
	slots[index].quantity -= amount

func _on_slot_changed() -> void:
	inventory_updated.emit()
