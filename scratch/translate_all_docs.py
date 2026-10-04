import os

DOCS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs")

# Load English and Portuguese templates as bases
with open(os.path.join(DOCS_DIR, "en", "advanced", "mcp-server.md"), "r", encoding="utf-8") as f:
    en_mcp = f.read()

with open(os.path.join(DOCS_DIR, "en", "advanced", "tools-reference.md"), "r", encoding="utf-8") as f:
    en_tools = f.read()

with open(os.path.join(DOCS_DIR, "advanced", "ui-guide.md"), "r", encoding="utf-8") as f:
    pt_ui = f.read()

with open(os.path.join(DOCS_DIR, "core-features", "agentes-inteligencia.md"), "r", encoding="utf-8") as f:
    pt_agents = f.read()

# Generate English UI Guide and Agent Intelligence if needed
en_ui = """# Complete UI Guide (All Controls & Tabs)

This page describes **every button, selector, control, and tab** present in the **Gamedev AI** interface inside the Godot editor.

![Overview of Gamedev AI main interface in Godot](../images/main_interface.png)

---

## 🗂️ Main Tabs & Panels

The plugin organizes its capabilities across **5 integrated tabs & panels**:
- **💬 Chat** — Main conversational panel, tool executions, multi-agent pipeline state, and quick actions.
- **⚙️ Settings** — Provider management (Gemini, OpenAI/OpenRouter, Ollama, NIM), API keys, custom system prompts, and vector indexing.
- **🐙 Git** — Version control integrated with GitHub, featuring AI-generated commit messages.
- **🎨 Shader Studio** — Visual shader synthesizer and editor with live interactive 2D/3D viewport previews.
- **🔊 SFX Studio** — Procedural sound effect synthesizer with instant playback and one-click scene node insertion.

---

## 💬 1. Chat Tab

### Top Bar
| Button | Function |
|---|---|
| **Preset Selector** | Dropdown to switch between active provider/model configurations (e.g. "Gemini 3.1 Pro", "Claude 3.7 Sonnet", "Ollama DeepSeek"). |
| **A- / A+** | Decreases or increases chat font size. |
| **+ New Chat** | Clears the current conversation and restarts session context. |
| **⊙ History** | Dropdown containing past saved conversations to restore full context at any time. |
| **💾 Summarize to Memory** | Instructs AI to synthesize key architectural decisions and persist them to project memory. |

### Multi-Agent Pipeline (Visual Chips)
When complex tasks are executed, colorful chips indicate the active orchestrator stage in real time:
* 🟦 `Architect` — Contract definition and architecture planning.
* 🟨 `Scene Builder` — Node creation and `.tscn` scene hierarchies.
* 🟩 `Coder` — Modern typed GDScript and signal wiring.
* 🟪 `QA Tester` — Assertion testing and Auto-Healing loops.

### TTS Player (Text-to-Speech)

![Compact TTS Player with playback controls](../images/tts_player.png)

| Control | Function |
|---|---|
| **▶ Read Aloud** | Synthesizes the latest AI response to audio. |
| **⏹ Stop** | Stops audio playback. |
| **Seek Slider** | Scrubs forward or backward in the audio track. |
| **Speed (1.0x - 2.0x)** | Controls speech playback rate. |

### Quick Action Buttons
| Button | Action |
|---|---|
| **✧ Refactor** | Sends selected code in the editor for structural refactoring. |
| **◆ Fix** | Sends selected code for immediate bug fixing. |
| **💡 Explain** | Sends selected code for step-by-step educational explanations. |
| **↺ Undo** | Reverts the last AI action using Godot's native Undo/Redo history. |
| **🖥 Fix Console** | Reads red error lines from Godot's Output console and prompts AI for an immediate fix. |

### Input Area & Prompt Settings (⚙️)
| Element | Function |
|---|---|
| **Include Context** | Automatically attaches the active script in the Script Editor. |
| **Send Screenshot** | Captures the Godot editor viewport and attaches it to the prompt (multimodal AI vision). |
| **Plan First** | Forces the AI to return a Markdown plan before writing code. |
| **Watch Mode** | Monitors the Output console and suggests auto-fixes if game crashes during play. |

---

## 🎨 2. Shader Studio Tab

The built-in **Shader Studio** lets you create, customize, and preview GLSL shaders (`.gdshader`) in real time.

| Control | Function |
|---|---|
| **Category Selector** | Filters presets by type (`2D Effects`, `3D Materials`, `Post-Processing`, `UI`). |
| **Preset Selector** | Chooses from ready-to-use shaders: *Hit Flash, Dissolve, Hologram, Outline, Water, Pixelate, Glitch, Glow, Fire, Shield, etc.* |
| **2D / 3D Mode** | Toggles the SubViewport preview between Sprite2D and MeshInstance3D with directional lighting. |
| **Dynamic Uniforms Panel** | Automatically generates sliders, color pickers, and toggles for each shader `uniform`. |
| **Live Code Editor** | Edit `.gdshader` code and click **Recompile** for instant visual feedback. |
| **🎲 Randomize** | Generates instant aesthetic variations by randomizing uniform parameters. |
| **✨ Apply to Selection** | Creates `ShaderMaterial` and attaches it to the selected node in the Scene Tree. |
| **💾 Save Shader** | Saves the shader file (`.gdshader`) and material (`.tres`) to `res://shaders/`. |

---

## 🔊 3. SFX Studio Tab (Procedural Synthesizer)

Generates retro and procedural sound effects using pure GDScript PCM synthesis:

| Control | Function |
|---|---|
| **Sound Presets** | Jump, Laser, Explosion, Coin, Power-up, Hit, UI Click. |
| **▶ Preview** | Plays synthesized audio through the built-in `AudioStreamPlayer`. |
| **🎲 Mutate** | Applies controlled procedural mutations to pitch and frequency envelope. |
| **💾 Save WAV** | Writes 16-bit uncompressed `.wav` files to `res://audio/sfx/`. |
| **➕ Insert to Scene** | Creates an `AudioStreamPlayer` node preconfigured with the stream under the selected node. |

---

## ⚙️ 4. Settings Tab

* **Supported Providers:** Google Gemini, OpenAI, OpenRouter, Ollama (Local), NVIDIA NIM.
* **Custom System Prompt:** Permanent engineering guidelines for the AI assistant.
* **✨ Enhance Instructions with AI:** Optimizes system instructions with Godot 4.7+ best practices.
* **Vector Database (RAG):** Scans changes and builds semantic embeddings for codebase indexing.

---

## 🐙 5. Git Tab & Version Control

* **Repo Setup & Remotes:** Configure GitHub remote repository URLs and initialize repos.
* **✨ Generate Commit Message:** AI analyzes `git diff` and generates Conventional Commit messages.
* **Branch Management:** Create, switch, and inspect branches visually.
* **Emergency Actions:** Discard local changes, Force Pull, and Force Push with confirmation dialogs.
"""

with open(os.path.join(DOCS_DIR, "en", "advanced", "ui-guide.md"), "w", encoding="utf-8") as f:
    f.write(en_ui.replace("../images/", "../../images/"))

en_agents = """# 🧠 Multi-Agent Orchestration & Intelligence

**Gamedev AI** is powered by an autonomous, multi-agent engineering architecture integrating specialized personas, a 4-stage sequential pipeline, shared memory, and automatic self-healing (Auto-Healing).

---

## 🚀 Multi-Agent Orchestrator (4-Stage Pipeline)

For complex tasks (such as creating inventory systems, combat engines, or procedural dungeons), Gamedev AI engages the **Agent Orchestrator**:

```mermaid
graph TD
    User([User Request]) --> Architect[1. Architect: Planning & Contracts]
    Architect --> Blackboard[(Blackboard: Shared Memory)]
    Blackboard --> SceneBuilder[2. Scene Builder: Node Trees & .tscn]
    SceneBuilder --> Coder[3. Coder: Typed GDScript & Signals]
    Coder --> QA[4. QA Tester: Tests & Assertions]
    QA -->|Assertion Failure| AutoHealing[Auto-Healing Loop]
    AutoHealing -->|Repair Instructions| Coder
    QA -->|Passed| Done([System Completed & Applied])
```

### 1. 🟦 Architect Persona
* **Role:** Analyzes requests, defines required node structures, public interfaces, exported variables, and signals.
* **Output:** Architectural specification written to the shared memory (`Blackboard`).

### 2. 🟨 Scene Builder Persona
* **Role:** Builds visual and physical scene hierarchies (`.tscn`).
* **Tools:** `create_scene`, `add_node`, `set_property`, `attach_script`, `create_resource`.

### 3. 🟩 Coder Persona
* **Role:** Implements logic in modern GDScript with strict static typing (`:=`, `-> void`).
* **Tools:** `create_script`, `patch_script`, `connect_signal`, `get_lsp_diagnostics`.

### 4. 🟪 QA Tester & Auto-Healing
* **Role:** Executes structural assertions, node audits, and unit tests.
* **Auto-Healing:** If QA detects failures, the orchestrator loops back to the `Coder` persona with exact error reports to automatically repair code (up to 2 iterations without user intervention).

---

## 🗄️ Blackboard (Pipeline Shared Memory)

The **Blackboard** is the in-memory shared state carrying:
* Created nodes, script paths, connected signals, and approved architectural contracts.
* Ensures the `Coder` and `QA Tester` have exact access to node paths established by the `Scene Builder`.

---

## 🎭 Specialist Personas (Dynamic Routing)

During standard chat sessions, the AI automatically activates specialized domain personas:
* **Godot Expert:** Architecture, Singletons, Resources, and design patterns.
* **UI/UX Designer:** Responsive `Control` layouts, Glassmorphism themes, anchors, and controller navigation.
* **Technical Artist (Shader Artist):** GLSL canvas/spatial shaders, particle systems, and VFX.
* **Multiplayer Engineer:** Godot 4 NetCode, RPCs (`@rpc("authority", "call_local")`), and state sync.
* **Audio Specialist:** Procedural sound synthesis and audio bus management.

---

## ⛩️ Socratic Gate (Stop & Ask)

For critical and complex requests:
1. **Strategic Pause:** AI pauses generation on complex system requests.
2. **Trade-off Inquiries:** Asks edge-case questions (e.g. *"Should inventory be slot-based or weight-based?", "Do you prefer binary serialization or JSON?"*).
3. **Aligned Execution:** Plans are executed only after your confirmation.

---

## ⌨️ Slash Commands (/)

* `/brainstorm` — Idea discovery and Game Design Document (GDD) exploration.
* `/plan` — Generates a structural Markdown plan.
* `/debug` — Deep-dive investigation on stack traces and runtime errors.
* `/orchestrate` — Forces the full multi-agent pipeline execution.
"""

with open(os.path.join(DOCS_DIR, "en", "core-features", "agent-intelligence.md"), "w", encoding="utf-8") as f:
    f.write(en_agents)

# Write Spanish (es)
es_mcp = en_mcp.replace("# 🔌 MCP Server & External IDE Integration", "# 🔌 Servidor MCP e Integración con IDEs Externas")
es_mcp = es_mcp.replace("features native support for", "cuenta con soporte nativo para")
es_mcp = es_mcp.replace("allowing external AI IDEs", "permitiendo que IDEs y agentes externos de IA")
es_mcp = es_mcp.replace("The MCP server exposes over **50 agentic tools**:", "El servidor MCP expone más de **65 herramientas agentics**:")
es_mcp = es_mcp.replace("How to Connect Your IDE", "Cómo Conectar tu IDE")

with open(os.path.join(DOCS_DIR, "es", "advanced", "mcp-server.md"), "w", encoding="utf-8") as f:
    f.write(es_mcp)

with open(os.path.join(DOCS_DIR, "es", "advanced", "tools-reference.md"), "w", encoding="utf-8") as f:
    f.write(en_tools.replace("# All AI Tools (Tool Reference)", "# Todas las Herramientas de la IA (Tools Reference)").replace("features **65 built-in tools**", "cuenta con **65 herramientas internas**"))

with open(os.path.join(DOCS_DIR, "es", "advanced", "ui-guide.md"), "w", encoding="utf-8") as f:
    f.write(en_ui.replace("# Complete UI Guide", "# Guía Completa de la Interfaz"))

with open(os.path.join(DOCS_DIR, "es", "core-features", "agent-intelligence.md"), "w", encoding="utf-8") as f:
    f.write(en_agents.replace("# 🧠 Multi-Agent Orchestration & Intelligence", "# 🧠 Orquestación Multi-Agente e Inteligencia"))

# Other locales
other_langs = ["fr", "de", "hi", "zh_CN", "ar", "ru", "bn", "id", "es"]
for lang in other_langs:
    lang_dir = os.path.join(DOCS_DIR, lang)
    adv_dir = os.path.join(lang_dir, "advanced")
    core_dir = os.path.join(lang_dir, "core-features")
    get_dir = os.path.join(lang_dir, "getting-started")
    os.makedirs(adv_dir, exist_ok=True)
    os.makedirs(core_dir, exist_ok=True)
    os.makedirs(get_dir, exist_ok=True)
    
    # Copy/write mcp-server.md
    with open(os.path.join(adv_dir, "mcp-server.md"), "w", encoding="utf-8") as f:
        f.write(en_mcp)
        
    # Write tools-reference.md
    with open(os.path.join(adv_dir, "tools-reference.md"), "w", encoding="utf-8") as f:
        f.write(en_tools)
        
    # Write ui-guide.md with corrected image paths
    sub_ui = en_ui.replace("../images/", "../../images/")
    with open(os.path.join(adv_dir, "ui-guide.md"), "w", encoding="utf-8") as f:
        f.write(sub_ui)
        
    # Write agent-intelligence.md
    with open(os.path.join(core_dir, "agent-intelligence.md"), "w", encoding="utf-8") as f:
        f.write(en_agents)
        
    # Update installation.md to 4.7+
    inst_path = os.path.join(get_dir, "installation.md")
    if os.path.exists(inst_path):
        with open(inst_path, "r", encoding="utf-8") as f:
            inst_content = f.read()
        inst_content = inst_content.replace("4.6", "4.7+")
        inst_content = inst_content.replace("\\u27A4", "➔")
        with open(inst_path, "w", encoding="utf-8") as f:
            f.write(inst_content)
            
    # Update index.md to 4.7+
    idx_path = os.path.join(lang_dir, "index.md")
    if os.path.exists(idx_path):
        with open(idx_path, "r", encoding="utf-8") as f:
            idx_content = f.read()
        idx_content = idx_content.replace("4.6", "4.7+")
        with open(idx_path, "w", encoding="utf-8") as f:
            f.write(idx_content)

print("All language documentation files updated successfully!")
