extends CanvasLayer

@onready var hp_bar: TextureProgressBar = $HUDControl/HPBar
@onready var sp_bar: TextureProgressBar = $HUDControl/SPBar
@onready var stamina_bar: TextureProgressBar = $HUDControl/StaminaBar
@onready var exp_bar: TextureProgressBar = $HUDControl/EXPBar

# Game Over nodes
const GAME_OVER_SCENE = preload("res://game_over.tscn")
var game_over_instance = null

# Reference to the pause menu instance
var pause_menu_instance = null
const PAUSE_MENU_SCENE = preload("res://menu.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Instantiate the new separated Pause Menu scene
	pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu_instance)
	if pause_menu_instance.has_method("hide"):
		pause_menu_instance.hide()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if game_over_instance and is_instance_valid(game_over_instance) and game_over_instance.visible:
		return
		
	if pause_menu_instance:
		pause_menu_instance.toggle_pause()

func update_health(current: int, max_hp: int):
	if not is_instance_valid(hp_bar):
		return
	hp_bar.max_value = max_hp
	hp_bar.value = current

func update_sp(current: int, max_sp: int):
	if not is_instance_valid(sp_bar):
		return
	sp_bar.max_value = max_sp
	sp_bar.value = current

func update_stamina(current: int, max_stamina: int):
	if not is_instance_valid(stamina_bar):
		return
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current

func update_exp(current: int, max_exp: int):
	if not is_instance_valid(exp_bar):
		return
	exp_bar.max_value = max_exp
	exp_bar.value = current

func show_game_over():
	if game_over_instance == null:
		game_over_instance = GAME_OVER_SCENE.instantiate()
		add_child(game_over_instance)
	
	game_over_instance.visible = true
	get_tree().paused = true
