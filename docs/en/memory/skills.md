# The 25 Built-in Skills (Complete Catalog)

Gamedev AI is not a generic AI that relies purely on internet-trained memory. It features **25 expertise modules** written specifically for Godot 4.6, which are automatically consulted during conversations to ensure the generated code follows industry best practices.

Below, each of the 25 Skills is detailed with its purpose and examples of when the AI uses them.

---

## 📜 GDScript & Language

### 1. `gdscript_style_guide`
**GDScript Style Guide.** Naming conventions (snake_case, PascalCase), file organization, static typing, declaration order, and formatting best practices following the official Godot standard.

### 2. `gdscript_modern_features`
**Modern GDScript Features.** Lambdas, expanded static typing, `await`, `super()`, typed enums, advanced `match` patterns, and all new features of GDScript 2.0+ that replaced legacy syntax.

### 3. `gdscript_deprecated`
**Deprecated GDScript Functions.** Comprehensive list of functions, methods, and patterns removed or replaced between Godot 3 and Godot 4. The AI consults this skill to never suggest obsolete code.

### 4. `gdscript_recipes_and_patterns`
**GDScript Recipes and Patterns.** Ready-made solutions to common problems: singleton pattern, object pooling, dependency injection, observer pattern, and idiomatic implementations in GDScript.

### 5. `gdscript_signals_and_tweens`
**Signals and Tweens.** In-depth guide on the Godot 4 signal system, `SceneTreeTween`, procedural animation creation, tween chaining, and best decoupling practices with signals.

---

## 🏗️ Architecture & Structure

### 6. `common_architectures`
**Common Game Architectures.** Architectural patterns like Entity-Component, MVC for games, Service Locator, Event Bus, and how to structure medium/large scale Godot projects.

### 7. `project_structure_guidelines`
**Project Structure Guidelines.** Ideal folder organization (`src/`, `assets/`, `ui/`, `autoloads/`), file naming conventions, autoloads vs. dependency injection, and when to use each approach.

### 8. `state_machine_implementation`
**State Machine Implementation.** State machine pattern with child nodes, clean transitions, hierarchical states, and integration with AnimationTree for complex characters.

---

## 🎮 Game Systems

### 9. `inventory_and_item_systems`
**Inventory and Item Systems.** Resource-based inventory architecture, slots, stacking, item drag & drop, serialization for save games, and responsive inventory UI.

### 10. `quest_and_dialogue_systems`
**Quest and Dialogue Systems.** Dialogue tree implementation, quest system with states (active/complete/failed), NPCs, progress conditions, and UI integration.

### 11. `save_system_and_persistence`
**Save System and Persistence.** Full game state serialization into JSON/binary, auto-save, multiple slots, save versioning, and migration between versions.

### 12. `data_management_and_crafting`
**Data Management and Crafting.** Crafting systems with Resource-based recipes, item databases, loot tables, and game economy balancing.

---

## 🕹️ Mechanics & Physics

### 13. `physics_and_collision_handling`
**Physics and Collision.** Layer/mask setup, CharacterBody2D/3D, RigidBody, raycasting, detection areas, and troubleshooting common physics issues.

### 14. `input_handling_and_remapping`
**Input and Remapping.** InputMap, custom actions, gamepad/keyboard/touch support, runtime remapping, input buffering, and dead zones.

### 15. `ai_and_pathfinding`
**AI and Pathfinding.** NavigationServer2D/3D, NavigationAgent, avoidance, simplified behavior trees, chasing, patrolling, and state-based enemy AI.

---

## 🎨 Visuals & Audio

### 16. `shaders_and_vfx`
**Shaders and VFX.** Godot Shading Language shaders, dissolve effects, outline, distortion, GPU particles, trails, and VFX techniques for 2D and 3D games.

### 17. `post_processing_and_environment`
**Post-Processing and Environment.** WorldEnvironment, glow, fog, SSAO, SSR, tonemap, color correction, and cinematic environment setup.

### 18. `animation_and_cutscenes`
**Animation and Cutscenes.** AnimationPlayer, AnimationTree, blend spaces, animation state machines, AnimationPlayer cutscenes, and smooth transitions.

### 19. `audio_management_best_practices`
**Audio Management.** AudioBus, AudioStreamPlayer2D/3D, sound effect pooling, adaptive music, crossfade, mixing, and audio system organization.

---

## 🖥️ Interface & Platform

### 20. `ui_ux_patterns`
**UI/UX Patterns.** Responsive menus, HUD, global themes, gamepad focus navigation, screen transitions, pop-ups, and UI best practices in Godot.

### 21. `mobile_and_resolution_scaling`
**Mobile and Resolution Scaling.** Stretch mode config, aspect ratio, touch input, virtual joystick, mobile optimizations, and multi-resolution testing.

### 22. `localization_and_i18n`
**Localization and i18n.** Translation system with `.csv`/`.po`, TranslationServer, runtime language switching, number/date formatting, and RTL support.

---

## 🌐 Multiplayer & Performance

### 23. `multiplayer_and_networking_api`
**Multiplayer and Networking.** ENet, WebSocket, MultiplayerSpawner/Synchronizer, RPCs, authority, client-server architecture, lobby systems, and state synchronization.

### 24. `performance_optimization`
**Performance Optimization.** Profiling, object pooling, LOD, culling, batch rendering, GDScript optimization, draw call reduction, and techniques for 60fps games.

### 25. `level_generation_and_pcg`
**Level Generation and PCG.** Procedural dungeon generation, wave function collapse, noise-based terrain, automatic TileMap, and reproducible ranom seeds.

---

## 🛠️ Creating Your Own Skills

The Skills system is **extensible**! You can create your own `.md` files in the `addons/gamedev_ai/skills/` folder to teach the AI the specific rules of your project.

**Example:** Create a file named `my_art_style.md` with:
```markdown
# Our Studio's Art Rules

- All sprites must be 16x16 or 32x32 resolution
- Use a limited color palette (max 32 colors)
- Character animations must have at least 4 frames
- Name sprites like: type_name_action_frame.png
```

The AI will follow these rules whenever it creates or modifies visual assets in your project.
