extends CanvasLayer

func _ready():
	# Ensure menu works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func init_game_over():
	$Control/Panel/VBoxContainer/TitleLabel.text = "GAME OVER"
	$Control/Panel/VBoxContainer/ResumeButton.visible = false
	show()
	get_tree().paused = true

func init_pause():
	$Control/Panel/VBoxContainer/TitleLabel.text = "PAUSED"
	$Control/Panel/VBoxContainer/ResumeButton.visible = true
	show()
	get_tree().paused = true

func _on_resume_button_pressed():
	hide()
	get_tree().paused = false

func _on_restart_button_pressed():
	get_tree().paused = false
	GameManager.score = 0
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	get_tree().quit()
