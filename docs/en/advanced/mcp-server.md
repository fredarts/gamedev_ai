# 🔌 MCP Server & External IDE Integration

**Gamedev AI** features native support for the **Model Context Protocol (MCP)**, allowing external AI IDEs and agents like **Antigravity, Cursor, Claude Desktop, and VS Code** to take full control of the Godot Engine in real-time.

---

## ⚡ What is MCP in Gamedev AI?

The **Model Context Protocol** is an open standard that connects AI assistants to local development tools in a unified way.

With Gamedev AI's embedded MCP server, you can use any external IDE or coding agent to:
* **Inspect Scene Tree:** Read active scene hierarchy and nodes (`godot://scene/active`).
* **Manipulate the Editor in Real-Time:** Add nodes, instance `.tscn` scenes, edit node properties, and connect signals.
* **Edit and Refactor Scripts:** Create `.gd` scripts, apply surgical code patches, and query Godot Language Server (LSP) diagnostics in real-time.
* **Procedural Generation & Assets:** Build TileMaps, configure autotiling bitmasks, synthesize procedural SFX, and generate visual shaders.
* **Run Tests & Audits:** Execute test suites and audit scene and script structures.

> [!TIP]
> The Gamedev AI MCP server runs **100% locally (`127.0.0.1:6543`)**, has **zero cloud cost**, and never leaks code or data outside your machine.

---

## 🚀 How to Connect Your IDE

### 1. Start Godot with Gamedev AI Enabled
When you open any Godot 4.7+ project with the **Gamedev AI** plugin enabled under `Project Settings > Plugins`, the local MCP server starts in the background on port `6543` (`http://127.0.0.1:6543`).

### 2. Configure Antigravity / Cursor / Claude Desktop

In your MCP configuration file (`mcp_config.json` or `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "godot": {
      "command": "python",
      "args": [
        "addons/gamedev_ai/mcp/godot_mcp.py"
      ]
    }
  }
}
```

> [!NOTE]
> The `addons/gamedev_ai/mcp/godot_mcp.py` script acts as a zero-dependency stdio-to-HTTP bridge between your IDE and the Godot editor.

---

## 🛠️ Available MCP Tools

The MCP server exposes over **50 agentic tools**:

| Category | Tool | Description |
|---|---|---|
| **Nodes & Scenes** | `add_node` | Adds a node to the active scene with custom type and script. |
| | `remove_node` | Removes nodes from the scene hierarchy safely. |
| | `instance_scene` | Instances a `.tscn` file as a child of any node. |
| | `set_property` | Edits properties in the inspector (positions, textures, flags). |
| | `connect_signal` | Connects signals between nodes. |
| | `create_scene` | Generates new `.tscn` scene files. |
| **Scripts** | `create_script` | Creates GDScript files with static typing and best practices. |
| | `edit_script` | Replaces and reloads scripts in memory and disk. |
| | `patch_script` | Applies surgical code patches without re-writing entire files. |
| | `get_lsp_diagnostics` | Captures LSP compile errors and warnings in real-time. |
| **Tilemaps & Procedural** | `configure_tileset_atlas` | Sets up texture atlases for TileSets. |
| | `build_tilemap_layout` | Builds 2D/3D matrix levels. |
| | `paint_terrain_cells` | Paints terrain and collisions with autotiling. |
| | `generate_procedural_dungeon` | Generates procedural dungeon layouts with rooms and corridors. |
| **Audio & VFX** | `generate_sfx` | Synthesizes retro and procedural sound effects. |
| | `generate_shader` | Generates custom spatial, canvas_item, or post-process shaders. |
| **Animations** | `create_animation` | Creates tracks and keys in `AnimationPlayer`. |
| | `create_state_machine` | Creates state machine logic in `AnimationTree`. |

---

## 📦 MCP Resources & Memory

External agents can also query registered MCP resources:
* `godot://scene/active` — Real-time hierarchy of the currently open scene.
* `godot://lsp/diagnostics` — Active Godot Language Server errors and warnings.
* `godot://memory/all` — Project persistent memories and architectural context.
