# All AI Tools (Tool Reference)

Gamedev AI has **27 built-in tools** that the AI can call autonomously during a conversation. These tools are the "mechanical arm" that allows the AI to interact directly with the Godot Engine, and each is described below grouped by category.

## 🔧 Scripts (Code Creation and Editing)

### `create_script`
Creates a new GDScript file (`.gd`) at the specified path with the provided content. The AI uses this tool to generate scripts from scratch.
- **Parameters:** `path` (res://...), `content` (full GDScript code)

### `edit_script`
Replaces the entire content of an existing script with a new version. The AI will read the file first to ensure it has the latest version.
- **Parameters:** `path`, `content`
- ⚠️ *Deprecated in favor of `patch_script` for surgical edits.*

### `patch_script`
Surgical edit: searches for an exact block of code within the script and replaces only that snippet with the new content. Ideal for small fixes without rewriting the whole file.
- **Parameters:** `path`, `search_content` (exact block to find), `replace_content` (new block)

### `replace_selection`
Replaces the currently selected text in the Godot Script Editor. Works in conjunction with quick action buttons (Refactor, Fix, Explain).
- **Parameters:** `text` (new code to replace selection)

### `view_file_outline`
Returns a script's structure without the full code: `class_name`, `extends`, functions, signals, exports, enums, inner classes, and constants with line numbers.
- **Parameters:** `path`

---

## 🌳 Nodes (Scene Tree Manipulation)

### `add_node`
Adds a new node to the open scene in the editor. Can create any Godot Node type (Node2D, CharacterBody3D, Label, Button, etc.).
- **Parameters:** `parent_path` (use `.` for root), `type` (node class), `name`, `script_path` (optional)

### `remove_node`
Removes a node from the current Scene Tree. Requires user confirmation as being a destructive action.
- **Parameters:** `node_path`

### `set_property`
Sets a property on a scene node (position, size, text, color, etc.). Accepts numbers, vectors, colors, and strings.
- **Parameters:** `node_path`, `property`, `value`

### `set_theme_override`
Sets a theme override on a Control node (font size, font color, style).
- **Parameters:** `node_path`, `override_type` (color/constant/font/font_size/stylebox), `name`, `value`

### `connect_signal`
Connects an emitting node's signal to a receiving node's method in the current scene.
- **Parameters:** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (optional), `flags` (optional)

### `disconnect_signal`
Disconnects a previously connected signal between two nodes.
- **Parameters:** `source_path`, `signal_name`, `target_path`, `method_name`

### `attach_script`
Attaches an existing GDScript to a node in the scene.
- **Parameters:** `node_path`, `script_path`

### `analyze_node_children`
Returns a detailed dump of a specific node's subtree in the edited scene. Useful for exploring deep hierarchies.
- **Parameters:** `node_path`, `max_depth` (default: 5)

---

## 📂 Files and Project

### `read_file`
Reads the full content of any project file.
- **Parameters:** `path`

### `list_dir`
Lists the contents of a project directory.
- **Parameters:** `path`

### `find_file`
Searches for a project file by name (partial match).
- **Parameters:** `pattern`

### `remove_file`
Deletes a file or directory from the project. Requires confirmation.
- **Parameters:** `path`

### `move_files_batch`
Moves or renames multiple files/directories in a single batch operation. Automatically updates all internal Godot references (`.tscn`, `.tres`).
- **Parameters:** `moves` (dictionary mapping old paths to new ones)

### `create_scene`
Creates a new scene file (`.tscn`) and opens it in the editor.
- **Parameters:** `path`, `root_type`, `root_name`

### `instance_scene`
Instances an existing `.tscn` scene as a child of another node in the current scene.
- **Parameters:** `parent_path`, `scene_path`, `name`

### `create_resource`
Creates a new Resource file (`.tres`). Useful for assets like Items, Stats, or custom configurations.
- **Parameters:** `path`, `type`, `properties` (optional)

---

## 🔍 Search and Analysis

### `grep_search`
Searches for text inside project files. Returns matching lines with path and line number.
- **Parameters:** `query`, `include` (extension filter, optional), `max_results` (default: 20)

### `search_in_files`
Searches regex patterns in all project `.gd` files to find uses of variables, functions, or specific logic.
- **Parameters:** `pattern` (regular expression)

### `get_class_info`
Returns detailed information about a Godot class (Engine or Custom): base class, properties, methods, and signals.
- **Parameters:** `class_name`

### `capture_editor_screenshot`
Takes a screenshot of the entire Godot Editor window and automatically attaches it to the next prompt for visual analysis.

---

## 🧠 Memory and Knowledge

### `save_memory`
Saves a persistent fact to the project memory that will be available in all future chat sessions.
- **Parameters:** `category` (architecture/convention/preference/bug_fix/project_info), `content`

### `list_memories`
Lists all persistent facts stored for this project.

### `delete_memory`
Deletes a specific memory fact by its ID.
- **Parameters:** `id`

### `read_skill`
Reads a Skill documentation file from the AI's internal library to learn best practices before programming.
- **Parameters:** `skill_name`

---

## 🗄️ Vector Database (RAG)

### `index_codebase`
Indexes the entire project (`.gd`) into a local Vector Database for semantic search. Must be executed before using `semantic_search`.

### `semantic_search`
Performs a semantic vector search on the indexed codebase to find highly relevant code snippets based on meaning, not exact text matching.
- **Parameters:** `query`

---

## 🧪 Tests

### `run_tests`
Executes a test script or command. Useful for checking changes with GUT, GdUnit4, or custom test scripts.
- **Parameters:** `test_script_path` (optional)
