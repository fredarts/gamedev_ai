@tool
extends SceneTree

func _init():
	var theme = Theme.new()
	
	# --- Button Styles ---
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color(0.0, 0.0, 0.0, 0.5)
	style_normal.corner_radius_top_left = 5
	style_normal.corner_radius_top_right = 5
	style_normal.corner_radius_bottom_right = 5
	style_normal.corner_radius_bottom_left = 5
	style_normal.content_margin_top = 10
	style_normal.content_margin_bottom = 10
	style_normal.content_margin_left = 20
	style_normal.content_margin_right = 20
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	style_hover.border_color = Color(0.8, 0.8, 0.8, 0.5)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.05, 0.05, 0.05, 1.0)
	style_pressed.border_width_top = 2
	style_pressed.border_width_bottom = 0
	
	var style_focus = style_hover.duplicate()
	style_focus.set_border_width_all(2)
	style_focus.border_color = Color(1.0, 0.8, 0.2, 1.0) # Dourado para foco
	
	theme.set_stylebox("normal", "Button", style_normal)
	theme.set_stylebox("hover", "Button", style_hover)
	theme.set_stylebox("pressed", "Button", style_pressed)
	theme.set_stylebox("focus", "Button", style_focus)
	
	theme.set_color("font_color", "Button", Color(0.9, 0.9, 0.9))
	theme.set_color("font_hover_color", "Button", Color(1.0, 1.0, 1.0))
	theme.set_color("font_focus_color", "Button", Color(1.0, 1.0, 0.0))
	
	# --- Label Styles ---
	# Label padrão
	theme.set_color("font_shadow_color", "Label", Color(0,0,0,0.5))
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)
	
	# Salvar
	var err = ResourceSaver.save(theme, "res://game_theme.tres")
	if err == OK:
		print("Theme saved successfully to res://game_theme.tres")
	else:
		print("Error saving theme: ", err)
	
	quit()
