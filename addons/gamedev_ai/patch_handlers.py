import os

script_dir = os.path.dirname(os.path.abspath(__file__))
files = [
    os.path.join(script_dir, 'tools', 'script_tools.gd'),
    os.path.join(script_dir, 'tools', 'node_tools.gd'),
    os.path.join(script_dir, 'tools', 'file_tools.gd')
]

for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Apply fixes
    content = content.replace('if _undo_redo:', 'if _get_undo_redo():')
    content = content.replace('_undo_redo.', '_get_undo_redo().')
    content = content.replace('if _composite_action_name == "":', 'if not _is_composite():')
    content = content.replace(', self)', ', executor)')
    content = content.replace('_scan_fs()', 'EditorInterface.get_resource_filesystem().scan()')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print('Patch applied successfully to all 3 handlers')
