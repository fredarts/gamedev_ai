# Complete UI Guide (All Controls & Tabs)

This page describes **every button, selector, control, and tab** present in the **Gamedev AI** interface inside the Godot editor.

![Overview of Gamedev AI main interface in Godot](../../images/main_interface.png)

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

![Compact TTS Player with playback controls](../../images/tts_player.png)

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
