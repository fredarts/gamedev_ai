---
description: Godot Project Structure and File Organization Best Practices
---
# Godot Project Structure & File Organization

Organizing a Godot project effectively is crucial for scalability, especially in Godot 4 where scenes and scripts often compose complex hierarchies. As an AI assistant, you **must never** dump files directly into the `res://` folder. 

Always think carefully about **WHERE** a file belongs before creating it. Use the `list_dir` tool to inspect existing folders to match the current project's conventions.

If the folder you need doesn't exist, create it.

## Core Organizing Philosophy

There are two primary ways to organize a Godot project. Analyze the project first using `list_dir` to see which philosophy they are using. If this is a new project, default to **Type-based Organization for small projects**, and **Feature-based Organization for large projects**.

### 1. Feature-Based Organization (Preferred for Scalability)
Group all related assets, scripts, and scenes for a specific feature together.
```
res://
├── player/
│   ├── player.tscn
│   ├── player.gd
│   ├── player_sprite.png
│   └── player_stats.tres
├── enemies/
│   ├── goblin/
│   │   ├── goblin.tscn
│   │   ├── goblin_ai.gd
│   │   └── animations/
├── ui/
│   ├── main_menu/
│   ├── inventory/
│   └── hud/
```

### 2. Type-Based Organization (Alternative)
Group files by their technical asset type. 
```
res://
├── scenes/
│   ├── characters/
│   │   └── player.tscn
│   └── levels/
├── scripts/
│   ├── player.gd
│   └── utils.gd
├── assets/
│   ├── graphics/
│   └── audio/
```

## Folder Naming Conventions (CRITICAL)

- **Always use `snake_case`** for folder and file names (e.g., `health_component.gd`, `main_menu.tscn`).
- **Never use spaces** in file or folder names.
- **Never use uppercase letters** in file or folder names (e.g., avoid `UI/`, use `ui/`).

## Mandatory Standard Directories

If you do not find a strong existing structure, use the following standard directories. Create them if they do not exist.

*   `res://entities/` or `res://characters/`: For active agents in the game (Player, Enemies, NPCs).
*   `res://components/`: For reusable logic nodes (HealthComponent, VelocityComponent, Hitbox, Hurtbox).
*   `res://ui/`: For User Interface scenes (Menus, HUDs, Popups).
*   `res://levels/` or `res://maps/`: For game maps and level scenes.
*   `res://systems/` or `res://autoloads/`: For singletons, global event buses, and managers.
*   `res://resources/` or `res://data/`: For custom Resource types (`.gd` that inherit `Resource`) and their instantiated data (`.tres`).
*   `res://assets/`: For raw art, audio, and models (usually handled by the user, but respect the folder).
*   `res://utils/` or `res://helpers/`: For static helper functions or generic utilities.

## Refactoring and File Placement Rules

1. **Before Creating a New Script or Scene:**
   - Stop and ask: "What does this file do?"
   - Use `list_dir("res://")` to check if a relevant folder already exists.
   - For example, if creating a "Health Bar", check for a `res://ui/` folder. If it exists, place it in `res://ui/health_bar.tscn`. 
   
2. **When Creating Components (Composition):**
   - Godot 4 strongly encourages Composition. Reusable behaviors like "Movement", "Health", or "Damage" should be standalone Node scripts.
   - ALWAYS put these in a `components` folder, e.g., `res://components/health_component.gd`. Never nest them exclusively under the player if enemies also need them.

3. **When Creating Global Systems:**
   - If you create a Singleton/Autoload, put it in `res://systems/` or `res://autoloads/`.

4. **NEVER dump files in the root:**
   - The only files that belong in `res://` are core configs like `project.godot`, `export_presets.cfg`, or occasionally a `main.tscn` root scene. Everything else MUST be in a subfolder.

## Tool Usage Example 

**BAD Process:**
User: "Make a pause menu"
AI: Uses `create_scene("res://pause_menu.tscn", "Control", "PauseMenu")`

**GOOD Process:**
User: "Make a pause menu"
AI: Uses `list_dir("res://")`
AI: Notices `res://ui/` exists.
AI: Uses `create_scene("res://ui/pause_menu.tscn", "Control", "PauseMenu")`
