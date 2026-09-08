@tool
extends RefCounted
class_name DockGit

var _dock_owner: Node
var git_manager
var ai_provider
var locale_manager

var git_tab: VBoxContainer
var init_repo_btn: Button
var remote_container: HBoxContainer
var remote_url_input: LineEdit
var set_remote_btn: Button
var git_status_label: RichTextLabel
var pull_btn: Button
var refresh_git_btn: Button
var auto_generate_commit_btn: Button
var commit_msg_input: TextEdit
var commit_sync_btn: Button

var branch_label: RichTextLabel
var branch_name_input: LineEdit
var checkout_branch_btn: Button
var undo_changes_btn: Button
var force_pull_btn: Button
var force_push_btn: Button
var undo_confirm_dialog: ConfirmationDialog
var force_pull_confirm_dialog: ConfirmationDialog
var force_push_confirm_dialog: ConfirmationDialog

var _is_generating_commit: bool = false

func setup(dock_owner: Node, p_git_manager, p_ai_provider, p_locale_manager, nodes: Dictionary):
	_dock_owner = dock_owner
	git_manager = p_git_manager
	ai_provider = p_ai_provider
	locale_manager = p_locale_manager
	
	git_tab = nodes.get("git_tab")
	init_repo_btn = nodes.get("init_repo_btn")
	remote_container = nodes.get("remote_container")
	remote_url_input = nodes.get("remote_url_input")
	set_remote_btn = nodes.get("set_remote_btn")
	git_status_label = nodes.get("git_status_label")
	pull_btn = nodes.get("pull_btn")
	refresh_git_btn = nodes.get("refresh_git_btn")
	auto_generate_commit_btn = nodes.get("auto_generate_commit_btn")
	commit_msg_input = nodes.get("commit_msg_input")
	commit_sync_btn = nodes.get("commit_sync_btn")
	branch_label = nodes.get("branch_label")
	branch_name_input = nodes.get("branch_name_input")
	checkout_branch_btn = nodes.get("checkout_branch_btn")
	undo_changes_btn = nodes.get("undo_changes_btn")
	force_pull_btn = nodes.get("force_pull_btn")
	force_push_btn = nodes.get("force_push_btn")
	undo_confirm_dialog = nodes.get("undo_confirm_dialog")
	force_pull_confirm_dialog = nodes.get("force_pull_confirm_dialog")
	force_push_confirm_dialog = nodes.get("force_push_confirm_dialog")
	
	_connect_signals()
	update_git_status()

func _connect_signals():
	if git_manager:
		if not git_manager.git_operation_started.is_connected(_on_git_operation_started):
			git_manager.git_operation_started.connect(_on_git_operation_started)
		if not git_manager.git_operation_completed.is_connected(_on_git_operation_completed):
			git_manager.git_operation_completed.connect(_on_git_operation_completed)
			
	if init_repo_btn and not init_repo_btn.pressed.is_connected(_on_init_repo_pressed):
		init_repo_btn.pressed.connect(_on_init_repo_pressed)
	if set_remote_btn and not set_remote_btn.pressed.is_connected(_on_set_remote_pressed):
		set_remote_btn.pressed.connect(_on_set_remote_pressed)
	if pull_btn and not pull_btn.pressed.is_connected(_on_pull_pressed):
		pull_btn.pressed.connect(_on_pull_pressed)
	if refresh_git_btn and not refresh_git_btn.pressed.is_connected(update_git_status):
		refresh_git_btn.pressed.connect(update_git_status)
	if auto_generate_commit_btn and not auto_generate_commit_btn.pressed.is_connected(_on_auto_generate_commit_pressed):
		auto_generate_commit_btn.pressed.connect(_on_auto_generate_commit_pressed)
	if commit_sync_btn and not commit_sync_btn.pressed.is_connected(_on_commit_sync_pressed):
		commit_sync_btn.pressed.connect(_on_commit_sync_pressed)
	if checkout_branch_btn and not checkout_branch_btn.pressed.is_connected(_on_checkout_branch_pressed):
		checkout_branch_btn.pressed.connect(_on_checkout_branch_pressed)
		
	if undo_changes_btn and not undo_changes_btn.pressed.is_connected(func(): undo_confirm_dialog.popup_centered()):
		undo_changes_btn.pressed.connect(func(): undo_confirm_dialog.popup_centered())
	if force_pull_btn and not force_pull_btn.pressed.is_connected(func(): force_pull_confirm_dialog.popup_centered()):
		force_pull_btn.pressed.connect(func(): force_pull_confirm_dialog.popup_centered())
	if force_push_btn and not force_push_btn.pressed.is_connected(func(): force_push_confirm_dialog.popup_centered()):
		force_push_btn.pressed.connect(func(): force_push_confirm_dialog.popup_centered())
		
	if undo_confirm_dialog and not undo_confirm_dialog.confirmed.is_connected(_on_undo_changes_confirmed):
		undo_confirm_dialog.confirmed.connect(_on_undo_changes_confirmed)
	if force_pull_confirm_dialog and not force_pull_confirm_dialog.confirmed.is_connected(_on_force_pull_confirmed):
		force_pull_confirm_dialog.confirmed.connect(_on_force_pull_confirmed)
	if force_push_confirm_dialog and not force_push_confirm_dialog.confirmed.is_connected(_on_force_push_confirmed):
		force_push_confirm_dialog.confirmed.connect(_on_force_push_confirmed)

func set_ai_provider(provider):
	ai_provider = provider

func update_git_status():
	if not git_manager: return
	if not git_manager.is_git_repo():
		git_status_label.text = locale_manager.tr("no_git_repo")
		init_repo_btn.visible = true
		remote_container.visible = false
		pull_btn.disabled = true
		commit_sync_btn.disabled = true
		auto_generate_commit_btn.disabled = true
	else:
		init_repo_btn.visible = false
		remote_container.visible = true
		pull_btn.disabled = false
		commit_sync_btn.disabled = false
		auto_generate_commit_btn.disabled = false
		
		var current_remote = git_manager.git_get_remote()
		if current_remote != "":
			remote_url_input.text = current_remote
			
		var branch = git_manager.git_get_current_branch()
		branch_label.text = locale_manager.tr("current_branch") + "[b]" + branch + "[/b]"
			
		var status = git_manager.git_status()
		if status.strip_edges() == "":
			git_status_label.text = "[color=green]" + locale_manager.tr("working_tree_clean") + "[/color]"
		else:
			git_status_label.text = locale_manager.tr("pending_changes") + "\n" + status

func _set_git_busy(busy: bool):
	pull_btn.disabled = busy
	commit_sync_btn.disabled = busy
	auto_generate_commit_btn.disabled = busy
	checkout_branch_btn.disabled = busy
	undo_changes_btn.disabled = busy
	force_pull_btn.disabled = busy
	force_push_btn.disabled = busy
	if busy:
		git_status_label.text = "[color=yellow]" + locale_manager.tr("working_please_wait") + "[/color]"

func _on_git_operation_started(operation: String):
	_set_git_busy(true)
	match operation:
		"pull":
			git_status_label.text = "[color=yellow]" + locale_manager.tr("pulling_from_github") + "[/color]"
		"commit_sync":
			git_status_label.text = "[color=yellow]" + locale_manager.tr("committing_pushing") + "[/color]"
		"force_pull":
			git_status_label.text = "[color=yellow]" + locale_manager.tr("force_pulling") + "[/color]"
		"force_push":
			git_status_label.text = "[color=yellow]" + locale_manager.tr("force_pushing") + "[/color]"
		"discard_changes":
			git_status_label.text = "[color=yellow]" + locale_manager.tr("undoing_uncommitted") + "[/color]"
		"checkout_branch":
			git_status_label.text = "[color=yellow]" + locale_manager.tr("switching_branch") + "[/color]"
		_:
			git_status_label.text = "[color=yellow]" + locale_manager.tr("working_please_wait") + "[/color]"

func _on_git_operation_completed(operation: String, output: String, is_error: bool):
	_set_git_busy(false)
	var color = "red" if is_error else "green"
	match operation:
		"pull":
			git_status_label.text = locale_manager.tr("pull_result") + "\n" + output
		"commit_sync":
			git_status_label.text = locale_manager.tr("push_result") + "\n" + output
			commit_msg_input.text = ""
		"force_pull":
			git_status_label.text = "[color=" + color + "]" + locale_manager.tr("force_pull_complete") + "[/color]\n" + output
		"force_push":
			git_status_label.text = "[color=" + color + "]" + locale_manager.tr("force_push_complete") + "[/color]\n" + output
			commit_msg_input.text = ""
		"discard_changes":
			git_status_label.text = "[color=" + color + "]" + locale_manager.tr("modifications_discarded") + "[/color]\n" + output
		"checkout_branch":
			git_status_label.text = output
			branch_name_input.text = ""
		_:
			git_status_label.text = "[color=" + color + "]" + output + "[/color]"
			
	if _dock_owner and _dock_owner.is_inside_tree():
		await _dock_owner.get_tree().create_timer(3.0).timeout
		update_git_status()

func _on_set_remote_pressed():
	var url = remote_url_input.text.strip_edges()
	if url == "": return
	git_manager.git_remote_add(url)
	update_git_status()

func _on_init_repo_pressed():
	git_manager.git_init()
	update_git_status()

func _on_pull_pressed():
	git_manager.git_pull_async()

func _on_checkout_branch_pressed():
	var branch_name = branch_name_input.text.strip_edges()
	if branch_name == "": return
	git_manager.git_checkout_branch_async(branch_name)

func _on_undo_changes_confirmed():
	git_manager.git_discard_changes_async()
	
func _on_force_pull_confirmed():
	git_manager.git_force_pull_async()

func _on_force_push_confirmed():
	var msg = commit_msg_input.text.strip_edges()
	git_manager.git_force_push_async(msg)

func _on_commit_sync_pressed():
	var msg = commit_msg_input.text.strip_edges()
	if msg == "": msg = "Updates"
	git_manager.git_commit_and_sync_async(msg)

func _on_auto_generate_commit_pressed():
	if git_manager.git_status().strip_edges() == "":
		commit_msg_input.text = locale_manager.tr("no_changes_to_commit")
		return
	
	if ai_provider == null or ai_provider.api_key == "":
		commit_msg_input.text = locale_manager.tr("ai_not_configured")
		return
		
	commit_msg_input.text = locale_manager.tr("generating")
	auto_generate_commit_btn.disabled = true
	_is_generating_commit = true
	var diff = git_manager.git_diff()
	var prompt = "You are an expert developer. Write a clear, concise Git commit message for the following diff. Only return the commit message snippet without any markdown formatting or explanations:\n\n" + diff
	ai_provider.send_prompt(prompt, "", [], [])

func handle_ai_commit_response(response: String) -> bool:
	if _is_generating_commit:
		_is_generating_commit = false
		commit_msg_input.text = response.strip_edges()
		auto_generate_commit_btn.disabled = false
		return true
	return false

func handle_ai_commit_error() -> bool:
	if _is_generating_commit:
		_is_generating_commit = false
		auto_generate_commit_btn.disabled = false
		commit_msg_input.text = "Error generating commit message."
		return true
	return false
