class_name InventorySlotData
extends Resource

## Armazena os dados de um único espaço (slot) do inventário.

signal slot_updated

@export var item_data: ItemData
@export var quantity: int = 0:
	set(value):
		quantity = value
		if quantity <= 0:
			item_data = null
			quantity = 0
		slot_updated.emit()

func set_item(new_item: ItemData, new_quantity: int) -> void:
	item_data = new_item
	quantity = new_quantity
	slot_updated.emit()
