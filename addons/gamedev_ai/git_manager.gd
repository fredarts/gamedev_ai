extends RefCounted

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
