extends CanvasLayer

@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var options_button: Button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		resume_game()
		get_viewport().set_input_as_handled()

func toggle_pause():
	if visible:
		resume_game()
	else:
		pause_game()

func pause_game():
	visible = true
	get_tree().paused = true
	
	# Foca no primeiro botão para permitir navegação via teclado
	if resume_button:
		resume_button.grab_focus()

func resume_game():
	visible = false
	get_tree().paused = false

func _on_resume_button_pressed():
	resume_game()

func _on_options_button_pressed():
	print("Opções clicado!")

func _on_quit_button_pressed():
	get_tree().quit()
