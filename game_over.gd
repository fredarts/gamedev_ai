extends Control

@onready var restart_button = $VBoxContainer/RestartButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var background = $Background

const PAUSE_MATERIAL = preload("res://pause_material.tres")

func _ready():
	# Garante que o menu process input mesmo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Configura o fundo com o material de blur e cor escura (efeito visual igual ao pause)
	if background:
		background.material = PAUSE_MATERIAL
		background.color = Color(0, 0, 0, 0.2)
		# Garante que cubra a tela toda
		background.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Conecta os sinais dos botões
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Foca no botão de reiniciar para permitir navegação via teclado/gamepad
	if restart_button.is_inside_tree():
		restart_button.grab_focus()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
		get_viewport().set_input_as_handled()
