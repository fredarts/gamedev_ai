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
