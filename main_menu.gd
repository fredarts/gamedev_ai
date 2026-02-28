extends Control

func _ready():
	# Conecta os sinais dos botões (clique) às funções
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Foca no primeiro botão para permitir navegação via gamepad/teclado
	$CenterContainer/VBoxContainer/StartButton.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()

func _on_start_pressed():
	# Muda para a cena do jogo. 
	# IMPORTANTE: Verifique se o nome do arquivo da sua cena de jogo é "world.tscn" ou "World.tscn".
	# Se der erro, verifique o nome exato na aba "FileSystem" e corrija aqui.
	if ResourceLoader.exists("res://world.tscn"):
		get_tree().change_scene_to_file("res://world.tscn")
	elif ResourceLoader.exists("res://World.tscn"):
		get_tree().change_scene_to_file("res://World.tscn")
	else:
		print("Erro: Cena do mundo não encontrada (esperado world.tscn)")

func _on_options_pressed():
	print("Opções: Ainda não implementado.")

func _on_quit_pressed():
	# Fecha o jogo
	get_tree().quit()
