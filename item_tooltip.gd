class_name ItemTooltip
extends NinePatchRect

@onready var item_icon: TextureRect = $MarginContainer/VBoxContainer/HeaderHBox/ItemIcon
@onready var item_name: Label = $MarginContainer/VBoxContainer/HeaderHBox/TitleVBox/ItemName
@onready var item_type: Label = $MarginContainer/VBoxContainer/HeaderHBox/TitleVBox/ItemType
@onready var item_rarity: Label = $MarginContainer/VBoxContainer/ItemRarity
@onready var item_stats: Label = $MarginContainer/VBoxContainer/ItemStats
@onready var item_description: RichTextLabel = $MarginContainer/VBoxContainer/ItemDescription

func _ready() -> void:
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not Engine.is_editor_hint():
		hide()

func _process(_delta: float) -> void:
	if visible and not Engine.is_editor_hint():
		var mouse_pos := get_global_mouse_position()
		# O Offset para ficar do lado do mouse e não em cima dele
		var offset := Vector2(10, 10)
		var target_pos := mouse_pos + offset
		
		var viewport_rect := get_viewport_rect()
		
		# Mantém escala fixa de 1.0 para o tooltip não encolher se o CanvasGroup redimensionar
		scale = Vector2.ONE
		
		if target_pos.x + size.x > viewport_rect.size.x:
			target_pos.x = mouse_pos.x - size.x - offset.x
		if target_pos.y + size.y > viewport_rect.size.y:
			target_pos.y = mouse_pos.y - size.y - offset.y
			
		global_position = target_pos.round()

func display_info(data: ItemData) -> void:
	if data == null:
		hide()
		return
		
	item_name.text = data.name
	item_icon.texture = data.icon
	
	var rarity_text := "Comum"
	var rarity_color := Color.WHITE
	
	match data.rarity:
		ItemData.Rarity.COMMON:
			rarity_text = "Comum"
			rarity_color = Color(0.8, 0.8, 0.8)
		ItemData.Rarity.UNCOMMON:
			rarity_text = "Incomum"
			rarity_color = Color(0.2, 0.8, 0.2)
		ItemData.Rarity.RARE:
			rarity_text = "Raro"
			rarity_color = Color(0.2, 0.5, 1.0)
		ItemData.Rarity.EPIC:
			rarity_text = "Épico"
			rarity_color = Color(0.6, 0.2, 0.8)
		ItemData.Rarity.LEGENDARY:
			rarity_text = "Lendário"
			rarity_color = Color(1.0, 0.8, 0.1)
			
	item_rarity.text = "Raridade: " + rarity_text
	
	# Usando color e outline do theme_override como no editor
	item_name.add_theme_color_override("font_color", rarity_color)
	# Garante que o outline preto fique mantido
	item_name.add_theme_color_override("font_outline_color", Color.BLACK)
	item_name.add_theme_constant_override("outline_size", 2)
	
	var stats_text = "Peso: %.1f | Valor: %d Ouro\n\n" % [data.weight, data.price]
	
	if data is WeaponItemData:
		var w_data := data as WeaponItemData
		var attack_type_str := "Corpo-a-corpo" if w_data.attack_type == WeaponItemData.AttackType.MELEE else "À Distância"
		var magic_str := " Mágica" if w_data.is_magical else " Física"
		item_type.text = "Arma " + attack_type_str + magic_str
		stats_text += "Dano Bônus: +%d" % [w_data.damage_bonus]
		
	elif data is ConsumableItemData:
		var c_data := data as ConsumableItemData
		item_type.text = "Consumível"
		if c_data.health_restored > 0:
			stats_text += "Restaura %d de Vida" % [c_data.health_restored]
			
	elif data is ShieldItemData:
		var s_data := data as ShieldItemData
		item_type.text = "Escudo"
		stats_text += "Defesa Base: %d" % [s_data.base_defense]
		
	else:
		item_type.text = "Material"
		
	item_stats.text = stats_text.strip_edges()
	
	# Usando a formatação de rich text para a descrição não ficar da mesma cor do status
	item_description.text = "[color=#603928]%s[/color]" % data.description
	
	show()
	
	# Permite que o Tooltip cresça automaticamente para caber o texto com fontes maiores
	$MarginContainer.reset_size()
	var new_size = $MarginContainer.get_minimum_size()
	
	# Garante que ele não encolha absurdamente
	new_size.x = max(new_size.x, custom_minimum_size.x)
	size = new_size

func hide_info() -> void:
	hide()
