class_name InventorySlotUI
extends TextureRect

signal slot_clicked(index: int, button_index: int)
signal slot_mouse_entered(index: int)
signal slot_mouse_exited(index: int)

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $Icon/QuantityLabel

var slot_index: int = -1

func _ready() -> void:
	# Inicialmente escondemos o ícone e a quantidade
	icon.texture = null
	quantity_label.text = ""
	
	focus_mode = Control.FOCUS_ALL
	
	# Usar sinais da GUI de clique e foco
	gui_input.connect(_on_gui_input)
	
	# Usar sinais de hover para tooltip
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_focus_entered() -> void:
	modulate = Color(1.5, 1.5, 1.5, 1.0) # Highlight visual
	slot_mouse_entered.emit(slot_index)

func _on_focus_exited() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	slot_mouse_exited.emit(slot_index)

func _on_mouse_entered() -> void:
	grab_focus()

func _on_mouse_exited() -> void:
	pass

func update_slot(slot_data: InventorySlotData) -> void:
	if slot_data == null or slot_data.item_data == null:
		icon.texture = null
		quantity_label.text = ""
		return
		
	icon.texture = slot_data.item_data.icon
	
	if slot_data.quantity > 1:
		quantity_label.text = str(slot_data.quantity)
	else:
		quantity_label.text = ""

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		slot_clicked.emit(slot_index, event.button_index)
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		slot_clicked.emit(slot_index, MOUSE_BUTTON_LEFT)


# -- SISTEMA DE DRAG AND DROP (Godot 4 Nativo) --

func _get_drag_data(_at_position: Vector2) -> Variant:
	if icon.texture == null:
		return null
		
	var data = { "type": "inventory_slot", "index": slot_index }
	
	# Criar um preview visual (o item acompanhando o mouse)
	var preview_texture := TextureRect.new()
	preview_texture.texture = icon.texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.custom_minimum_size = Vector2(32, 32)
	
	var preview := Control.new()
	preview.add_child(preview_texture)
	preview_texture.position = -preview_texture.custom_minimum_size / 2.0
	
	set_drag_preview(preview)
	
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "inventory_slot"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# Este nó não sabe trocar os itens, ele emite um sinal global ou pede pro InventoryUI resolver
	# Idealmente, o InventoryUI deveria estar escutando ou podemos fazer um SignalBus
	pass
