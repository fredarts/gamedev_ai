@tool
extends SceneTree

func _init() -> void:
	print("Setting up inputs...")
	
	_add_action("move_up", [KEY_W, KEY_UP], JOY_AXIS_LEFT_Y, -1.0, JOY_BUTTON_DPAD_UP)
	_add_action("move_down", [KEY_S, KEY_DOWN], JOY_AXIS_LEFT_Y, 1.0, JOY_BUTTON_DPAD_DOWN)
	_add_action("move_left", [KEY_A, KEY_LEFT], JOY_AXIS_LEFT_X, -1.0, JOY_BUTTON_DPAD_LEFT)
	_add_action("move_right", [KEY_D, KEY_RIGHT], JOY_AXIS_LEFT_X, 1.0, JOY_BUTTON_DPAD_RIGHT)
	
	_add_action("attack", [KEY_SPACE, KEY_J], -1, 0.0, JOY_BUTTON_X) # Quadrado
	_add_action("run", [KEY_SHIFT], -1, 0.0, JOY_BUTTON_A) # X (Cruz)
	_add_action("interact", [KEY_E], -1, 0.0, JOY_BUTTON_B) # Bolinha
	_add_action("potion", [KEY_H, KEY_Q], -1, 0.0, JOY_BUTTON_RIGHT_SHOULDER) # R1
	
	_add_action("pause", [KEY_ESCAPE], -1, 0.0, JOY_BUTTON_START) # Start
	_add_action("inventory", [KEY_TAB, KEY_I], -1, 0.0, JOY_BUTTON_BACK) # Select
	
	# Garante que os botões nativos da UI funcionem com o controle
	_add_action("ui_accept", [KEY_ENTER, KEY_SPACE], -1, 0.0, JOY_BUTTON_A) # X (Cruz) confirma
	_add_action("ui_cancel", [KEY_ESCAPE], -1, 0.0, JOY_BUTTON_Y) # Triângulo cancela/volta
	
	_add_action("ui_up", [KEY_UP, KEY_W], JOY_AXIS_LEFT_Y, -1.0, JOY_BUTTON_DPAD_UP)
	_add_action("ui_down", [KEY_DOWN, KEY_S], JOY_AXIS_LEFT_Y, 1.0, JOY_BUTTON_DPAD_DOWN)
	_add_action("ui_left", [KEY_LEFT, KEY_A], JOY_AXIS_LEFT_X, -1.0, JOY_BUTTON_DPAD_LEFT)
	_add_action("ui_right", [KEY_RIGHT, KEY_D], JOY_AXIS_LEFT_X, 1.0, JOY_BUTTON_DPAD_RIGHT)
	
	ProjectSettings.save()
	print("Input setup complete!")
	quit()

func _add_action(action_name: String, keys: Array, axis: int = -1, axis_value: float = 0.0, button: int = -1):
	var events = []
	
	for key in keys:
		var key_event = InputEventKey.new()
		key_event.physical_keycode = key
		events.append(key_event)
		
	if axis != -1:
		var joy_motion = InputEventJoypadMotion.new()
		joy_motion.axis = axis
		joy_motion.axis_value = axis_value
		events.append(joy_motion)
		
	if button != -1:
		var joy_button = InputEventJoypadButton.new()
		joy_button.button_index = button
		events.append(joy_button)
		
	var dict = {
		"deadzone": 0.2,
		"events": events
	}
	
	ProjectSettings.set_setting("input/" + action_name, dict)
