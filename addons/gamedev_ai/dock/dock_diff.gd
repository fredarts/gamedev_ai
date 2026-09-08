@tool
extends RefCounted
class_name DockDiff

var _dock_owner: Node
var _tool_executor
var _locale_manager
var _diff_preview_panel: VBoxContainer
var _diff_display: RichTextLabel
var _apply_diff_btn: Button
var _skip_diff_btn: Button
var _chat_vbox: VBoxContainer

signal diff_resolved(applied: bool)

func setup(dock_owner: Node, tool_executor, locale_manager, diff_preview_panel: VBoxContainer, diff_display: RichTextLabel, apply_diff_btn: Button, skip_diff_btn: Button, chat_vbox: VBoxContainer):
	_dock_owner = dock_owner
	_tool_executor = tool_executor
	_locale_manager = locale_manager
	_diff_preview_panel = diff_preview_panel
	_diff_display = diff_display
	_apply_diff_btn = apply_diff_btn
	_skip_diff_btn = skip_diff_btn
	_chat_vbox = chat_vbox
	
	if _apply_diff_btn and not _apply_diff_btn.pressed.is_connected(_on_apply_diff_pressed):
		_apply_diff_btn.pressed.connect(_on_apply_diff_pressed)
	if _skip_diff_btn and not _skip_diff_btn.pressed.is_connected(_on_skip_diff_pressed):
		_skip_diff_btn.pressed.connect(_on_skip_diff_pressed)

func show_diff_preview(path: String, old_content: String, new_content: String, tool_name: String, _args: Dictionary):
	if not _diff_preview_panel or not _diff_display:
		return
		
	_diff_preview_panel.visible = true
	if _chat_vbox and _diff_preview_panel.get_parent() != _chat_vbox:
		_diff_preview_panel.reparent(_chat_vbox)
	if _chat_vbox:
		_chat_vbox.move_child(_diff_preview_panel, -1)
	
	_diff_display.scroll_following = false
	_diff_display.clear()
	_diff_display.append_text("[b]Modifying: " + path + "[/b] (" + tool_name + ")\n")
	
	if tool_name == "patch_script" or tool_name == "replace_selection":
		_diff_display.append_text("[color=red][s]" + _escape_bbcode(old_content) + "[/s][/color]\n")
		_diff_display.append_text("[color=green]" + _escape_bbcode(new_content) + "[/color]\n")
	else:
		if old_content == "":
			_diff_display.append_text("[color=green]" + _escape_bbcode(new_content) + "[/color]\n")
		else:
			_diff_display.append_text("[i]New content preview:[/i]\n")
			_diff_display.append_text(_escape_bbcode(new_content))

	if _dock_owner and _dock_owner.is_inside_tree():
		await _dock_owner.get_tree().process_frame
		var v_scroll = _diff_display.get_v_scroll_bar()
		if v_scroll:
			v_scroll.value = 0

func _on_apply_diff_pressed():
	if _diff_preview_panel:
		_diff_preview_panel.visible = false
	if _tool_executor:
		_tool_executor.confirm_pending_action()
	diff_resolved.emit(true)

func _on_skip_diff_pressed():
	if _diff_preview_panel:
		_diff_preview_panel.visible = false
	if _tool_executor:
		_tool_executor.cancel_pending_action()
	diff_resolved.emit(false)

func _escape_bbcode(text: String) -> String:
	return text.replace("[", "[lb]")
