@tool
extends RefCounted

signal git_operation_started(operation: String)
signal git_operation_completed(operation: String, output: String, is_error: bool)

var _thread: Thread = null
var _is_busy: bool = false

func is_busy() -> bool:
	return _is_busy

func _cleanup_thread():
	if _thread and _thread.is_started():
		_thread.wait_to_finish()
	_thread = null

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_cleanup_thread()

func is_git_repo() -> bool:
	var dir = DirAccess.open("res://")
	if dir:
		return dir.dir_exists(".git")
	return false

func _execute_git(args: PackedStringArray) -> String:
	var output = []
	var exit_code = OS.execute("git", args, output, true, false)
	if output.size() > 0:
		return output[0]
	return ""

# ----------------- ASYNC INFRASTRUCTURE -----------------

func _run_async(callable: Callable, operation_name: String):
	if _is_busy:
		call_deferred("emit_signal", "git_operation_completed", operation_name, "Git is busy running another operation.", true)
		return
		
	_is_busy = true
	git_operation_started.emit(operation_name)
	_cleanup_thread()
	
	_thread = Thread.new()
	_thread.start(_worker_thread.bind(callable, operation_name))

func _worker_thread(callable: Callable, operation_name: String):
	var result = callable.call()
	call_deferred("_on_worker_finished", operation_name, result)

func _on_worker_finished(operation_name: String, result: Variant):
	_cleanup_thread()
	_is_busy = false
	
	var text_output = ""
	var is_err = false
	
	if result is Dictionary:
		text_output = result.get("output", "")
		is_err = result.get("is_error", false)
	elif result is String:
		text_output = result
		if text_output.begins_with("fatal:") or text_output.begins_with("error:") or text_output.begins_with("ERROR"):
			is_err = true
			
	git_operation_completed.emit(operation_name, text_output, is_err)

# ----------------- ASYNC OPERATIONS -----------------

func git_pull_async():
	_run_async(func(): return git_pull(), "pull")

func git_push_async():
	_run_async(func(): return git_push(), "push")

func git_commit_and_sync_async(message: String):
	_run_async(func():
		git_add_all()
		git_commit(message)
		var push_res = git_push()
		if push_res.strip_edges() == "":
			push_res = "Done."
		return push_res
	, "commit_sync")

func git_force_pull_async():
	_run_async(func(): return git_force_pull(), "force_pull")

func git_force_push_async(message: String = ""):
	_run_async(func():
		git_add_all()
		if message.strip_edges() != "":
			git_commit(message)
		var res = git_force_push()
		if res.strip_edges() == "":
			res = "Done."
		return res
	, "force_push")

func git_discard_changes_async():
	_run_async(func(): return git_discard_changes(), "discard_changes")

func git_checkout_branch_async(branch_name: String):
	_run_async(func(): return git_checkout_branch(branch_name), "checkout_branch")

func git_status_async():
	_run_async(func(): return git_status(), "status")

# ----------------- SYNCHRONOUS METHODS -----------------

func git_init() -> String:
	return _execute_git(["init"])

func git_status() -> String:
	return _execute_git(["status", "-s"])

func git_diff() -> String:
	return _execute_git(["diff"])

func git_add_all() -> String:
	return _execute_git(["add", "."])

func git_commit(message: String) -> String:
	return _execute_git(["commit", "-m", message])

func git_push() -> String:
	# Use -u origin HEAD to automatically set upstream for the current branch
	return _execute_git(["push", "-u", "origin", "HEAD"])

func git_force_push() -> String:
	# Force push to overwrite remote history (useful when local and remote are out of sync)
	return _execute_git(["push", "--force", "-u", "origin", "HEAD"])

func git_pull() -> String:
	return _execute_git(["pull", "origin", "HEAD"])

func git_remote_add(url: String) -> String:
	var existing = git_get_remote()
	if existing != "":
		return _execute_git(["remote", "set-url", "origin", url])
	else:
		return _execute_git(["remote", "add", "origin", url])

func git_get_remote() -> String:
	return _execute_git(["config", "--get", "remote.origin.url"]).strip_edges()

func git_discard_changes() -> String:
	_execute_git(["reset", "--hard", "HEAD"])
	return _execute_git(["clean", "-fd"])

func git_force_pull() -> String:
	var fetch_res = _execute_git(["fetch", "origin"])
	if fetch_res.begins_with("fatal:") or fetch_res.begins_with("error:"):
		return "ERROR during fetch:\n" + fetch_res
	var current_branch = git_get_current_branch()
	if current_branch == "":
		current_branch = "main"
	# Delete all tracked files so Git is forced to recreate everything fresh
	_execute_git(["rm", "-rf", "--cached", "."])
	_execute_git(["checkout", "origin/" + current_branch, "--", "."])
	var reset_res = _execute_git(["reset", "--hard", "origin/" + current_branch])
	if reset_res.begins_with("fatal:") or reset_res.begins_with("error:"):
		return "ERROR during reset:\n" + reset_res
	_execute_git(["clean", "-fd"])
	return "Success. All files downloaded fresh from origin/" + current_branch

func git_get_current_branch() -> String:
	return _execute_git(["rev-parse", "--abbrev-ref", "HEAD"]).strip_edges()

func git_checkout_branch(branch_name: String) -> String:
	# Check if branch exists
	var branches = _execute_git(["branch", "--list", branch_name]).strip_edges()
	if branches != "":
		return _execute_git(["checkout", branch_name])
	else:
		return _execute_git(["checkout", "-b", branch_name])
