# All AI Tools (Tool Reference)

**Gamedev AI** features **65 built-in tools** that the assistant can execute autonomously during a chat conversation or via the local Model Context Protocol (MCP) server. These tools serve as the "mechanical arm" allowing the AI to directly interact with the Godot Engine.

---

## 🔧 1. Scripts & GDScript Code

### `create_script`
Creates a new GDScript file (`.gd`) at the specified path with static typing and engine best practices.
- **Parameters:** `path` (`res://...`), `content` (full GDScript code).

### `edit_script`
Replaces the entire content of an existing script with a new version.
- **Parameters:** `path`, `content`.
- ⚠️ *Deprecated in favor of `patch_script` to prevent accidental overwrites.*

### `patch_script`
Surgical edit: searches for an exact block of code within the script and replaces only that snippet with the new content without modifying the rest of the file.
- **Parameters:** `path`, `search_content` (exact block to find), `replace_content` (new block).

### `replace_selection`
Replaces the currently selected text in the Godot Script Editor (used by quick action buttons such as Refactor, Fix, and Explain).
- **Parameters:** `text` (new code).

### `view_file_outline`
Returns a structural outline of a script: `class_name`, `extends`, functions, signals, exports, enums, constants, and inner classes with their exact line numbers.
- **Parameters:** `path`.

### `get_lsp_diagnostics`
Queries the Godot Language Server Protocol (LSP) in real time to fetch compilation errors, syntax issues, and warnings without running the game.
- **Parameters:** `path`.

---

## 🌳 2. Nodes & Scene Tree Manipulation

### `add_node`
Adds a new node to the open scene in the editor (Node2D, CharacterBody2D/3D, Label, Button, etc.).
- **Parameters:** `parent_path` (use `.` for root), `type` (node class), `name`, `script_path` (optional).

### `remove_node`
Removes a node from the current Scene Tree. Requires user confirmation.
- **Parameters:** `node_path`.

### `set_property`
Edits any property of a node in the Inspector (position, rotation, scale, texture, colors, visibility).
- **Parameters:** `node_path`, `property`, `value`.

### `set_theme_override`
Sets a theme override on Control nodes (font size, colors, stylebox).
- **Parameters:** `node_path`, `override_type` (`color`, `constant`, `font`, `font_size`, `stylebox`), `name`, `value`.

### `connect_signal`
Connects an emitting node's signal to a receiving node's method in the current scene.
- **Parameters:** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (optional), `flags` (optional).

### `disconnect_signal`
Disconnects a previously connected signal between two nodes.
- **Parameters:** `source_path`, `signal_name`, `target_path`, `method_name`.

### `attach_script`
Attaches an existing GDScript file to a node in the scene.
- **Parameters:** `node_path`, `script_path`.

### `analyze_node_children`
Returns a detailed hierarchical sub-tree of a specific node up to a configurable depth.
- **Parameters:** `node_path`, `max_depth` (default: 5).

---

## 📂 3. Files, Scenes & Resources

### `read_file`
Reads the complete text content of any file in the project.
- **Parameters:** `path`.

### `list_dir`
Lists files and subdirectories within a project folder.
- **Parameters:** `path`.

### `find_file`
Searches for files in the project matching a name or extension pattern.
- **Parameters:** `pattern`.

### `remove_file`
Deletes a file or directory from disk after confirmation.
- **Parameters:** `path`.

### `move_files_batch`
Moves or renames multiple files in a batch operation, automatically updating Godot's internal dependencies.
- **Parameters:** `moves` (dictionary of old path to new path).

### `create_scene`
Creates a new scene file (`.tscn`) with the configured root node and opens it in the editor.
- **Parameters:** `path`, `root_type`, `root_name`.

### `instance_scene`
Instances a `.tscn` scene as a child of a node in the currently opened scene.
- **Parameters:** `parent_path`, `scene_path`, `name`.

### `create_resource`
Creates new resource files (`.tres`) for items, inventories, stats, or configuration data.
- **Parameters:** `path`, `type`, `properties` (optional).

---

## 🔍 4. Search, Inspection & Analysis

### `grep_search`
Full-text search with file extension filters across all project files.
- **Parameters:** `query`, `include` (optional), `max_results` (default: 20).

### `search_in_files`
Regular expression (Regex) search across all project GDScripts.
- **Parameters:** `pattern`.

### `get_class_info`
Queries Godot's `ClassDB` to extract methods, properties, signals, and constants of any engine or custom class.
- **Parameters:** `class_name`.

### `capture_editor_screenshot`
Captures a real-time screenshot of the Godot editor window for multimodal AI vision analysis.

---

## 🧠 5. Persistent Memory & Knowledge (RAG)

### `save_memory`
Saves an architectural decision, convention, preference, or pattern into the persistent project memory.
- **Parameters:** `category` (`architecture`, `convention`, `preference`, `bug_fix`, `project_info`), `content`.

### `list_memories`
Lists all persistent memories saved for this project.

### `delete_memory`
Deletes a specific memory entry by its unique ID.
- **Parameters:** `id`.

### `read_skill`
Loads the content of one of the 25 built-in game development engineering skills.
- **Parameters:** `skill_name`.

### `index_codebase`
Generates vector embeddings of all project scripts into the local Vector DB.

### `semantic_search`
Performs vector semantic search by intent and meaning across the indexed codebase.
- **Parameters:** `query`.

---

## 🔊 6. Audio & Procedural Sound Effects (SFX)

### `generate_sfx`
Procedurally synthesizes retro/arcade WAV sound effects (jumps, lasers, explosions, coins, powerups, clicks, hits).
- **Parameters:** `preset` (`jump`, `laser`, `explosion`, `coin`, `powerup`, `hit`, `click`), `save_path` (optional).

### `play_sfx_preview`
Generates and plays a real-time synthesized sound preview without writing to disk.
- **Parameters:** `preset`.

---

## 🎨 7. Shaders & Visual Synthesizer

### `generate_shader`
Generates custom `.gdshader` files for 2D canvas, 3D spatial materials, or screen post-processing.
- **Parameters:** `preset` (`dissolve`, `hologram`, `outline`, `hit_flash`, `water`, `pixelate`, `glow`, `glitch`, `fire`, etc.), `mode` (`canvas_item`, `spatial`, `particles`), `save_path` (optional).

### `apply_shader_to_node`
Creates or updates a `ShaderMaterial` and attaches it to the selected 2D or 3D node.
- **Parameters:** `node_path`, `shader_path`, `uniform_values` (optional).

### `get_shader_presets_list`
Returns the complete catalog of available shader presets and their configurable uniforms.

---

## 🗺️ 8. TileMaps, Terrains & Procedural Dungeons

### `configure_tileset_atlas`
Configures a texture atlas for a `TileSet`, setting up tile size, physics collision layers, and terrain sets.
- **Parameters:** `texture_path`, `tile_size` (e.g. `[16, 16]`), `save_path`, `terrain_set_config`, `physics_config`.

### `build_tilemap_layout`
Paints an entire 2D matrix level layout onto a `TileMapLayer`.
- **Parameters:** `layer_node_path`, `layout_matrix` (2D array of tile IDs), `source_id`.

### `paint_terrain_cells`
Paints terrain cells with auto-tiling using Godot 4's native terrain system.
- **Parameters:** `layer_node_path`, `terrain_set`, `terrain_id`, `cell_coordinates`.

### `read_tilemap_layout`
Reads placed tile coordinates and IDs from a bounding box region of a TileMap.
- **Parameters:** `layer_node_path`, `bounding_box` (optional).

### `clear_tilemap_region`
Clears tiles from a rectangular area or coordinate list.
- **Parameters:** `layer_node_path`, `rect` or `cell_coordinates`.

### `generate_procedural_dungeon`
Generates complete procedural dungeons (rooms, corridors, doors, stairs, seeds) using BSP, Random Walk, or Cellular Automata algorithms and writes them to the TileMap.
- **Parameters:** `width`, `height`, `algorithm`, `min_room_size`, `max_rooms`, `seed` (optional).

### `scaffold_autotile_bitmasks`
Automatically configures 2x2, 3x3 minimal, 16-pipe, or 47-tile terrain bitmasks on a TileSet resource.
- **Parameters:** `tileset_path`, `terrain_set`, `terrain_id`, `pattern_type`.

### `get_atlas_image`
Extracts and inspects texture atlas slices and sub-image coordinates.
- **Parameters:** `tileset_path`, `source_id`, `atlas_coords`.

---

## 🏃 9. Animations & State Machines

### `create_animation`
Creates new animations in `AnimationPlayer` with property tracks, length, and loop modes.
- **Parameters:** `player_node_path`, `animation_name`, `library_name`, `length`, `loop_mode`, `tracks`.

### `setup_spritesheet_animation`
Slices a spritesheet (`Sprite2D`) and builds animations with automatic FPS calculation and `RESET` track.
- **Parameters:** `player_node_path`, `sprite_node_path`, `animation_name`, `start_frame`, `frame_count`, `fps`, `loop_mode`.

### `add_animation_event_track`
Adds method call or audio tracks at specific animation timestamps (e.g. trigger hitbox spawn on frame 3).
- **Parameters:** `player_node_path`, `animation_name`, `timestamp`, `event_type`, `target_node_path`, `method_name_or_property`, `method_args_or_value`.

### `inspect_animation_player`
Inspects libraries, animation tracks, durations, and properties of an `AnimationPlayer`.
- **Parameters:** `player_node_path`.

### `create_state_machine`
Sets up an `AnimationTree` with an `AnimationNodeStateMachine` root.
- **Parameters:** `tree_node_path`, `anim_player_path`, `states`, `transitions`, `start_state`.

### `create_blend_space_2d`
Creates and configures 2D blend spaces (e.g. for 4-way or 8-way character movement).
- **Parameters:** `tree_node_path`, `state_name`, `blend_points`, `blend_mode`, `min_space`, `max_space`.

### `connect_state_machine_transition`
Creates and configures transitions between state machine nodes with crossfade and switch modes.
- **Parameters:** `tree_node_path`, `from_state`, `to_state`, `switch_mode`, `xfade_time`.

### `inspect_animation_tree`
Returns the complete hierarchy of nodes, states, and transitions in an `AnimationTree`.
- **Parameters:** `tree_node_path`.

### `setup_character_animation_suite`
Scaffolds a character's complete animation rig in a single step: creates `AnimationPlayer`, `AnimationTree`, State Machine (`Idle`, `Walk`, `Run`, `Jump`, `Attack`), and binds it to `Sprite2D`.
- **Parameters:** `parent_path`, `sprite_node_path`.

---

## 🖥️ 10. UI Studio & Themes

### `generate_ui_theme`
Generates full `.tres` Theme resources with typography, buttons, panels, dialogue boxes, and StyleBoxes.
- **Parameters:** `preset_or_name` (`glassmorphism`, `cyberpunk`, `retro_rpg`, `minimal_dark`, `scifi`), `save_path`, `colors`, `metrics`, `set_as_project_theme`.

### `create_responsive_ui_component`
Instantiates pre-built responsive UI components with automatic screen anchors.
- **Parameters:** `component_type` (`hud`, `pause_menu`, `inventory_grid`, `dialogue_box`, `main_menu`), `save_path`, `theme_path`, `parent_node_path`.

### `apply_theme_to_scene`
Recursively applies a Theme resource to the scene root or a specific UI branch.
- **Parameters:** `theme_path`, `node_path`.

### `inspect_theme`
Inspects properties, colors, and fonts defined in a `.tres` Theme file.
- **Parameters:** `theme_path`.

---

## ⚡ 11. OmniTools, Reflection & Debugger

### `omni_eval`
Evaluates and executes dynamic GDScript code blocks and mathematical expressions in real-time within the editor context.
- **Parameters:** `code`, `context_node_path` (optional).

### `omni_manage`
Executes advanced reflection, `ClassDB` queries, and in-memory node manipulation.
- **Parameters:** `action`, `query`, `target`.

### `get_runtime_errors`
Captures error messages, warnings, and stack traces emitted by the Godot debugger while the game is running.
- **Parameters:** `clear_after_read` (optional).

### `get_runtime_status`
Reports the runtime state of the active Godot debug session (running, paused, stopped).

---

## 🧪 12. Testing & Auditing

### `run_tests`
Executes automated unit or integration test suites in the project.
- **Parameters:** `test_script_path` (optional).

### `audit_scene`
Performs an architectural audit on the open scene, checking for orphan nodes, missing scripts, and performance warnings.

### `audit_script`
Runs static analysis on a GDScript file to detect anti-patterns, scope bugs, and typing errors.
- **Parameters:** `path`.
