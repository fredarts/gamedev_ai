class_name InventoryUI
extends Control

## Controla a janela principal do inventário.

@onready var slot_grid: GridContainer = $Background/SlotGrid
@onready var prev_button: TextureButton = $Background/PrevButton
@onready var next_button: TextureButton = $Background/NextButton
@onready var close_button: TextureButton = $Background/CloseButton

var item_tooltip: ItemTooltip
const TOOLTIP_SCENE: PackedScene = preload("res://item_tooltip.tscn")

@export var inventory_component: InventoryComponent
@export var slot_scene: PackedScene = preload("res://inventory_slot_ui.tscn")

var slots_ui: Array[InventorySlotUI] = []

var is_animating: bool = false
@export var transition_duration: float = 0.2

func _ready() -> void:
	# Oculta o inventário ao iniciar (apenas durante a gameplay, no editor fica visível)
	if not Engine.is_editor_hint():
		visible = false
		modulate.a = 0.0
	
	if has_node("ItemTooltip"):
		item_tooltip = $ItemTooltip as ItemTooltip
	else:
		item_tooltip = TOOLTIP_SCENE.instantiate() as ItemTooltip
		item_tooltip.name = "ItemTooltip"
		add_child(item_tooltip)
	
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	# Aguardar um frame para garantir que o InventoryComponent esteja totalmente inicializado
	await get_tree().process_frame
	
	# Se o componente não foi definido no editor, tenta buscar no pai ou avô (que é o Player)
	if inventory_component == null:
		var current = get_parent()
		while current != null:
			if current.has_node("InventoryComponent"):
				set_inventory_component(current.get_node("InventoryComponent"))
				break
			current = current.get_parent()

func set_inventory_component(comp: InventoryComponent) -> void:
	inventory_component = comp
	if inventory_component.inventory_data:
		inventory_component.inventory_data.inventory_updated.connect(update_ui)
		_create_slots()

func _create_slots() -> void:
	var data := inventory_component.inventory_data
	if data == null: return
	
	slots_ui.clear()
	
	var existing_slots = slot_grid.get_children()
	
	if existing_slots.size() > 0:
		for i in range(existing_slots.size()):
			var slot_inst = existing_slots[i] as InventorySlotUI
			if slot_inst:
				slots_ui.append(slot_inst)
				slot_inst.slot_index = i
				_connect_slot_signals(slot_inst)
				if i < data.slots.size():
					slot_inst.update_slot(data.slots[i])
	else:
		for i in range(data.slots.size()):
			var slot_inst = slot_scene.instantiate() as InventorySlotUI
			if slot_inst == null:
				continue
				
			slot_grid.add_child(slot_inst)
			slots_ui.append(slot_inst)
			slot_inst.slot_index = i
			_connect_slot_signals(slot_inst)
			slot_inst.update_slot(data.slots[i])

func _connect_slot_signals(slot_inst: InventorySlotUI) -> void:
	if not slot_inst.slot_mouse_entered.is_connected(_on_slot_mouse_entered):
		slot_inst.slot_mouse_entered.connect(_on_slot_mouse_entered)
	if not slot_inst.slot_mouse_exited.is_connected(_on_slot_mouse_exited):
		slot_inst.slot_mouse_exited.connect(_on_slot_mouse_exited)
	if not slot_inst.slot_clicked.is_connected(_on_slot_clicked):
		slot_inst.slot_clicked.connect(_on_slot_clicked)

func _on_slot_clicked(index: int, button_index: int) -> void:
	# Só processar cliques com botão esquerdo ou do gamepad (A)
	if button_index != MOUSE_BUTTON_LEFT:
		return
		
	var data = inventory_component.inventory_data
	if data and index < data.slots.size():
		var slot_data = data.slots[index]
		if slot_data and slot_data.item_data is ConsumableItemData:
			_use_consumable(index, slot_data.item_data as ConsumableItemData)

func _use_consumable(index: int, consumable: ConsumableItemData) -> void:
	# Procurar o jogador ou entidade dona do inventário
	var owner = inventory_component.get_parent()
	if not owner: return
	
	var used = false
	
	# Checar HealthComponent
	var health_comp = owner.get_node_or_null("HealthComponent")
	if health_comp and consumable.health_restored > 0:
		if health_comp.health < health_comp.max_health:
			if owner.has_method("heal"):
				owner.heal(consumable.health_restored)
			else:
				health_comp.heal(consumable.health_restored)
			used = true
	
	if used:
		# Remover do inventário
		inventory_component.inventory_data.remove_item_at(index, 1)
		
		# Som de uso (se houver)
		var audio = owner.get_node_or_null("AudioComponent")
		if audio and audio.has_method("play_sfx"):
			audio.play_sfx("heal") # Ou outro som configurado
		
		# Atualiza a UI da tooltip se acabou o item
		var slot_data = inventory_component.inventory_data.slots[index]
		if slot_data == null or slot_data.item_data == null:
			item_tooltip.hide_info()
		else:
			item_tooltip.display_info(slot_data.item_data)

func _on_slot_mouse_entered(index: int) -> void:
	var data = inventory_component.inventory_data
	if data and index < data.slots.size():
		var slot_data = data.slots[index]
		if slot_data and slot_data.item_data:
			item_tooltip.display_info(slot_data.item_data)

func _on_slot_mouse_exited(index: int) -> void:
	item_tooltip.hide_info()

func update_ui() -> void:
	if not visible or inventory_component == null:
		return
		
	var data := inventory_component.inventory_data
	for i in range(data.slots.size()):
		if i < slots_ui.size():
			slots_ui[i].update_slot(data.slots[i])

# Para ser chamado pelo Input ("I")
func toggle() -> void:
	if is_animating:
		return
		
	if not visible:
		_open_inventory()
	else:
		_close_inventory()

func _open_inventory() -> void:
	is_animating = true
	visible = true
	update_ui()
	
	if slots_ui.size() > 0:
		slots_ui[0].grab_focus()
	
	if has_node("OpenSound"):
		var sound = get_node("OpenSound")
		if sound is AudioStreamPlayer and sound.stream != null:
			sound.play()
	
	# Posição inicial (escala zero para "crescer")
	scale = Vector2(0.8, 0.8)
	# Centralizar o pivot point pro zoom ficar legal
	pivot_offset = size / 2
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, transition_duration)
	tween.tween_property(self, "modulate:a", 1.0, transition_duration)
	
	await tween.finished
	is_animating = false

func _close_inventory() -> void:
	is_animating = true
	
	if is_instance_valid(item_tooltip):
		item_tooltip.hide_info()
	
	# Tocar o som, se houver um AudioStreamPlayer (você pode adicionar um no editor depois)
	if has_node("CloseSound"):
		var sound = get_node("CloseSound")
		if sound is AudioStreamPlayer:
			sound.play()
			
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), transition_duration)
	tween.tween_property(self, "modulate:a", 0.0, transition_duration)
	
	await tween.finished
	visible = false
	is_animating = false

func _on_close_button_pressed() -> void:
	if not is_animating and visible:
		_close_inventory()
