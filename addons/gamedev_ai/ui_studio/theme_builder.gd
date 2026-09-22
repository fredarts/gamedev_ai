@tool
extends RefCounted

# ==============================================================================
# --- Presets Definition ---
# ==============================================================================

const PRESETS = {
	"glassmorphism": {
		"name": "Sleek Glassmorphism",
		"bg_color": Color(0.07, 0.09, 0.15, 0.85),
		"surface_color": Color(0.11, 0.15, 0.24, 0.8),
		"primary_color": Color(0.23, 0.51, 0.96, 1.0), # #3B82F6
		"accent_color": Color(0.06, 0.72, 0.63, 1.0),  # #10B981
		"text_color": Color(0.95, 0.97, 1.0, 1.0),
		"text_disabled": Color(0.5, 0.55, 0.65, 0.6),
		"border_color": Color(1.0, 1.0, 1.0, 0.15),
		"corner_radius": 10,
		"border_width": 1,
		"shadow_size": 8,
		"shadow_color": Color(0.0, 0.0, 0.0, 0.35)
	},
	"cyberpunk": {
		"name": "Cyberpunk Neon",
		"bg_color": Color(0.04, 0.05, 0.08, 0.95),
		"surface_color": Color(0.08, 0.10, 0.15, 0.9),
		"primary_color": Color(0.0, 0.94, 1.0, 1.0),    # Cyan Neon #00F0FF
		"accent_color": Color(1.0, 0.0, 0.33, 1.0),    # Neon Pink #FF0055
		"text_color": Color(0.95, 0.98, 1.0, 1.0),
		"text_disabled": Color(0.4, 0.45, 0.55, 0.6),
		"border_color": Color(0.0, 0.94, 1.0, 0.6),
		"corner_radius": 2,
		"border_width": 2,
		"shadow_size": 12,
		"shadow_color": Color(0.0, 0.94, 1.0, 0.25)
	},
	"fantasy_gold": {
		"name": "RPG Fantasy Gold",
		"bg_color": Color(0.06, 0.08, 0.11, 0.95),
		"surface_color": Color(0.10, 0.13, 0.18, 0.95),
		"primary_color": Color(0.83, 0.69, 0.22, 1.0), # Gold #D4AF37
		"accent_color": Color(0.90, 0.22, 0.27, 1.0),  # Ruby Red
		"text_color": Color(0.96, 0.93, 0.85, 1.0),   # Parchment
		"text_disabled": Color(0.5, 0.48, 0.42, 0.6),
		"border_color": Color(0.83, 0.69, 0.22, 0.8),
		"corner_radius": 6,
		"border_width": 2,
		"shadow_size": 6,
		"shadow_color": Color(0.0, 0.0, 0.0, 0.6)
	},
	"cozy_pastel": {
		"name": "Cozy Pastel Casual",
		"bg_color": Color(0.18, 0.19, 0.26, 0.95),
		"surface_color": Color(0.24, 0.26, 0.35, 0.95),
		"primary_color": Color(0.02, 0.84, 0.63, 1.0), # Mint Green #06D6A0
		"accent_color": Color(1.0, 0.42, 0.42, 1.0),   # Coral #FF6B6B
		"text_color": Color(0.98, 0.98, 0.96, 1.0),
		"text_disabled": Color(0.6, 0.62, 0.7, 0.6),
		"border_color": Color(1.0, 1.0, 1.0, 0.12),
		"corner_radius": 20,
		"border_width": 0,
		"shadow_size": 4,
		"shadow_color": Color(0.0, 0.0, 0.0, 0.2)
	},
	"retro_pixel": {
		"name": "Retro Pixel 16-Bit",
		"bg_color": Color(0.08, 0.08, 0.08, 1.0),
		"surface_color": Color(0.15, 0.15, 0.15, 1.0),
		"primary_color": Color(0.95, 0.95, 0.95, 1.0),
		"accent_color": Color(1.0, 0.8, 0.0, 1.0),
		"text_color": Color(1.0, 1.0, 1.0, 1.0),
		"text_disabled": Color(0.4, 0.4, 0.4, 1.0),
		"border_color": Color(1.0, 1.0, 1.0, 1.0),
		"corner_radius": 0,
		"border_width": 3,
		"shadow_size": 0,
		"shadow_color": Color(0, 0, 0, 0)
	}
}

# ==============================================================================
# --- Theme Generation Engine ---
# ==============================================================================

static func build_theme(preset_or_name: String, custom_colors: Dictionary = {}, custom_metrics: Dictionary = {}) -> Theme:
	var cfg = PRESETS.get("glassmorphism").duplicate(true)
	var preset_key = preset_or_name.to_lower().strip_edges()
	if PRESETS.has(preset_key):
		cfg = PRESETS[preset_key].duplicate(true)

	# Override with user colors
	for k in custom_colors:
		var col_val = custom_colors[k]
		if col_val is Color:
			cfg[k] = col_val
		elif col_val is String:
			cfg[k] = Color.from_string(col_val, cfg.get(k, Color.WHITE))

	# Override with user metrics
	for m in custom_metrics:
		cfg[m] = custom_metrics[m]

	var theme = Theme.new()

	# 1. StyleBox Helpers
	var radius = int(cfg.get("corner_radius", 8))
	var border_w = int(cfg.get("border_width", 1))
	var shadow_s = int(cfg.get("shadow_size", 4))
	var shadow_col = cfg.get("shadow_color", Color(0, 0, 0, 0.3))

	var bg_col = cfg.get("bg_color")
	var surface_col = cfg.get("surface_color")
	var primary_col = cfg.get("primary_color")
	var accent_col = cfg.get("accent_color")
	var text_col = cfg.get("text_color")
	var text_disabled_col = cfg.get("text_disabled")
	var border_col = cfg.get("border_color")

	# 2. Configure Panels
	var panel_sb = _create_stylebox(surface_col, border_col, radius, border_w, shadow_s, shadow_col)
	theme.set_stylebox("panel", "Panel", panel_sb)
	theme.set_stylebox("panel", "PanelContainer", panel_sb)

	var popup_sb = _create_stylebox(bg_col, border_col, radius + 2, border_w + 1, shadow_s + 4, shadow_col)
	theme.set_stylebox("panel", "PopupPanel", popup_sb)
	theme.set_stylebox("panel", "PopupMenu", popup_sb)

	# 3. Configure Buttons
	var btn_normal = _create_stylebox(surface_col, border_col, radius, border_w, shadow_s / 2, shadow_col, 6, 12)
	var btn_hover = _create_stylebox(surface_col.lightened(0.12), primary_col, radius, border_w + 1, shadow_s, shadow_col, 6, 12)
	var btn_pressed = _create_stylebox(primary_col.darkened(0.2), primary_col, radius, border_w, 0, Color.TRANSPARENT, 6, 12)
	var btn_disabled = _create_stylebox(surface_col.darkened(0.4), border_col.darkened(0.5), radius, border_w, 0, Color.TRANSPARENT, 6, 12)
	var btn_focus = _create_stylebox(Color.TRANSPARENT, primary_col, radius, border_w + 1, 0, Color.TRANSPARENT, 6, 12)

	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_stylebox("focus", "Button", btn_focus)

	theme.set_color("font_color", "Button", text_col)
	theme.set_color("font_hover_color", "Button", text_col.lightened(0.2))
	theme.set_color("font_pressed_color", "Button", primary_col.lightened(0.3))
	theme.set_color("font_disabled_color", "Button", text_disabled_col)
	theme.set_color("font_focus_color", "Button", text_col)

	# 4. Configure LineEdit & TextEdit
	var edit_normal = _create_stylebox(bg_col.darkened(0.2), border_col, radius, border_w, 0, Color.TRANSPARENT, 6, 10)
	var edit_focus = _create_stylebox(bg_col.darkened(0.2), primary_col, radius, border_w + 1, shadow_s, shadow_col, 6, 10)
	theme.set_stylebox("normal", "LineEdit", edit_normal)
	theme.set_stylebox("focus", "LineEdit", edit_focus)
	theme.set_stylebox("normal", "TextEdit", edit_normal)
	theme.set_stylebox("focus", "TextEdit", edit_focus)
	theme.set_color("font_color", "LineEdit", text_col)
	theme.set_color("font_color", "TextEdit", text_col)
	theme.set_color("caret_color", "LineEdit", primary_col)

	# 5. Configure ProgressBar
	var pb_bg = _create_stylebox(bg_col.darkened(0.3), border_col, radius / 2, border_w, 0, Color.TRANSPARENT, 2, 2)
	var pb_fill = _create_stylebox(primary_col, Color.TRANSPARENT, radius / 2, 0, shadow_s / 2, primary_col * 0.4, 2, 2)
	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill", "ProgressBar", pb_fill)
	theme.set_color("font_color", "ProgressBar", text_col)

	# 6. Configure HSlider & VSlider
	var slider_grabber = _create_stylebox(primary_col, Color.WHITE, max(radius, 6), 1, shadow_s, shadow_col, 4, 4)
	var slider_grabber_hl = _create_stylebox(primary_col.lightened(0.2), Color.WHITE, max(radius, 6), 2, shadow_s + 2, shadow_col, 4, 4)
	theme.set_stylebox("slider", "HSlider", pb_bg)
	theme.set_stylebox("grabber_area", "HSlider", pb_fill)
	theme.set_stylebox("grabber_area_highlight", "HSlider", pb_fill)

	# 7. Configure Labels & RichTextLabel
	theme.set_color("font_color", "Label", text_col)
	theme.set_color("font_color", "RichTextLabel", text_col)
	theme.set_color("font_shadow_color", "Label", shadow_col)
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)

	# 8. Configure TabContainer
	var tab_selected = _create_stylebox(surface_col, primary_col, radius, border_w, 0, Color.TRANSPARENT, 8, 14)
	var tab_unselected = _create_stylebox(bg_col, border_col, radius, border_w, 0, Color.TRANSPARENT, 6, 12)
	theme.set_stylebox("tab_selected", "TabContainer", tab_selected)
	theme.set_stylebox("tab_unselected", "TabContainer", tab_unselected)
	theme.set_stylebox("panel", "TabContainer", panel_sb)

	return theme

# ==============================================================================
# --- Internal Helpers ---
# ==============================================================================

static func _create_stylebox(bg_col: Color, border_col: Color, radius: int, border_w: int, shadow_size: int, shadow_col: Color, pad_v: int = 4, pad_h: int = 4) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col

	if border_w > 0:
		sb.border_color = border_col
		sb.border_width_left = border_w
		sb.border_width_top = border_w
		sb.border_width_right = border_w
		sb.border_width_bottom = border_w

	if radius > 0:
		sb.corner_radius_top_left = radius
		sb.corner_radius_top_right = radius
		sb.corner_radius_bottom_left = radius
		sb.corner_radius_bottom_right = radius
		sb.corner_detail = 6

	if shadow_size > 0:
		sb.shadow_size = shadow_size
		sb.shadow_color = shadow_col
		sb.shadow_offset = Vector2(0, shadow_size / 3.0)

	sb.content_margin_top = pad_v
	sb.content_margin_bottom = pad_v
	sb.content_margin_left = pad_h
	sb.content_margin_right = pad_h

	sb.anti_aliasing = true
	return sb
