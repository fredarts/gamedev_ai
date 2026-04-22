import re
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.abspath(os.path.join(script_dir, "..", ".."))
repo_path = os.path.join(script_dir, "tool_executor.gd")
# We can read from git using OS command
import subprocess

result = subprocess.run(["git", "show", "HEAD:addons/gamedev_ai/tool_executor.gd"], capture_output=True, text=True, cwd=project_root, encoding="utf-8")
orig_text = result.stdout

# Extract _remove_node
remove_node_match = re.search(r'(func _remove_node\(.*?\n)(?=func _|\Z)', orig_text, re.DOTALL)
remove_node_code = remove_node_match.group(1) if remove_node_match else ""

# Extract _remove_file
remove_file_match = re.search(r'(func _remove_file\(.*?\n)(?=func _|\Z)', orig_text, re.DOTALL)
remove_file_code = remove_file_match.group(1) if remove_file_match else ""

# Extract _move_files_batch
move_files_match = re.search(r'(func _move_files_batch\(.*?\n)(?=func _|\Z)', orig_text, re.DOTALL)
move_files_code = move_files_match.group(1) if move_files_match else ""

# Extract _apply_create_script
apply_create_match = re.search(r'(func _apply_create_script\(.*?\n)(?=func _|\Z)', orig_text, re.DOTALL)
apply_create_code = apply_create_match.group(1) if apply_create_match else ""

# Extract _apply_edit_script
apply_edit_match = re.search(r'(func _apply_edit_script\(.*?\n)(?=func _|\Z)', orig_text, re.DOTALL)
apply_edit_code = apply_edit_match.group(1) if apply_edit_match else ""

# Extract _apply_patch_script 
apply_patch_match = re.search(r'(func _apply_patch_script\(.*?\n)(?=func _|\Z)', orig_text, re.DOTALL)
apply_patch_code = apply_patch_match.group(1) if apply_patch_match else ""

# Extract _apply_replace_selection
apply_replace_match = re.search(r'(func _apply_replace_selection\(.*?\n)(?=func _|\Z)', orig_text, re.DOTALL)
apply_replace_code = apply_replace_match.group(1) if apply_replace_match else ""


def replace_self_with_executor(code):
    code = code.replace("self._undo_redo", "_get_undo_redo()")
    code = code.replace("self._composite_action_name", "_is_composite()")
    code = code.replace("_composite_action_name !=", "_is_composite() ")
    code = code.replace("tool_output.emit", "_emit_output")
    code = code.replace("add_do_method(self", "add_do_method(executor")
    code = code.replace("add_undo_method(self", "add_undo_method(executor")
    code = code.replace("create_action(self", "create_action(executor")
    # Replace the remaining references if any
    return code

# --- PATCH SCRIPT TOOLS ---
script_tools_path = os.path.join(script_dir, "tools", "script_tools.gd")
with open(script_tools_path, "r", encoding="utf-8") as f:
    st_text = f.read()

st_text = st_text.replace("executor._apply_create_script", "_apply_create_script")
st_text = st_text.replace("executor._apply_edit_script", "_apply_edit_script")
st_text = st_text.replace("executor._apply_patch_script", "_apply_patch_script")
st_text = st_text.replace("executor._apply_replace_selection", "_apply_replace_selection")

st_add = replace_self_with_executor(apply_create_code) + "\n" + replace_self_with_executor(apply_edit_code) + "\n" + replace_self_with_executor(apply_patch_code) + "\n" + replace_self_with_executor(apply_replace_code)
# We also have self._create_file_undoable -> executor._create_file_undoable in the add method because it is called in add_do_method as a string, but the object is now 'executor'.
# Wait, if there are direct calls to _create_file_undoable(path, content), those should be executor._create_file_undoable
st_add = st_add.replace("_create_file_undoable(", "executor._create_file_undoable(")
st_add = st_add.replace("executor.executor._create_file_undoable(", "executor._create_file_undoable(")

with open(script_tools_path, "w", encoding="utf-8") as f:
    f.write(st_text + "\n" + st_add)

# --- PATCH NODE TOOLS ---
node_tools_path = os.path.join(script_dir, "tools", "node_tools.gd")
with open(node_tools_path, "a", encoding="utf-8") as f:
    f.write("\n" + replace_self_with_executor(remove_node_code))

# --- PATCH FILE TOOLS ---
file_tools_path = os.path.join(script_dir, "tools", "file_tools.gd")
with open(file_tools_path, "a", encoding="utf-8") as f:
    ft_add = replace_self_with_executor(remove_file_code) + "\n" + replace_self_with_executor(move_files_code)
    ft_add = ft_add.replace("_delete_file_undoable(", "executor._delete_file_undoable(")
    f.write("\n" + ft_add)

print("Patching complete!")
