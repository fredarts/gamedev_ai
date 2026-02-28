class_name LootTableEntry
extends Resource

## Define um item que pode ser dropado por um LootComponent.
## Configura a chance, o item em si e a quantidade.

@export_category("Configuração de Drop")
@export_range(0.0, 1.0) var chance: float = 0.5 ## Chance de 0.0 a 1.0 (ex: 0.5 = 50%)
@export var item_data: ItemData ## O Resource do Item que será dropado
@export_range(1, 100) var min_quantity: int = 1 ## Quantidade mínima
@export_range(1, 100) var max_quantity: int = 1 ## Quantidade máxima

func get_drop_count() -> int:
	if min_quantity == max_quantity:
		return min_quantity
	return randi_range(min_quantity, max_quantity)
