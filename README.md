<h1 align="center">Gamedev AI</h1>

<p align="center">
  <b>Agentic AI Assistant for Godot Engine 4.6+</b>
</p>

<p align="center">
  Integrate AI models directly into your Godot workflow. Gamedev AI is an autonomous assistant that doesn't just provide suggestions — it interacts directly with your project. From constructing scene hierarchies to refactoring code, reading PDFs aloud, and managing your Git history, it helps you build your game both visually and logically.
</p>

---

## 🚀 Features

### 🧠 Core Agentic Capabilities
- **🛠️ Agentic Tools**: The AI can autonomously `add_node`, `set_property`, `instance_scene`, `patch_script`, `create_scene`, `connect_signal`, `search_in_files`, `move_files_batch`, and more — directly in the live editor.
- **👁️ Context Awareness**: Automatically gathers context from your **Active Scene**, **Open Scripts**, **Project Structure**, and takes **Viewport Screenshots** for visual guidance.
- **💾 Persistent Project Memory**: The AI remembers architectural decisions, naming conventions, and project facts across different sessions. It learns your game as you build it!
- **📋 Plan First Mode**: For complex tasks, ask the AI to generate a step-by-step numbered plan before executing any changes. Review the plan, then click **Run Plan** to watch it work. The toggle automatically disables after execution to prevent accidental re-planning loops.

### 📚 Built-in Skills Library
The AI is powered by a comprehensive set of **GDScript skill documents** that are injected into its knowledge base, ensuring high-quality, idiomatic code generation:

| Skill | Description |
|---|---|
| `gdscript_style_guide` | Naming conventions, formatting rules, and code organization standards |
| `gdscript_modern_features` | GDScript 4.x features: typed arrays, lambdas, match statements |
| `gdscript_signals_and_tweens` | Signal patterns, Tweens, AnimationPlayers, and coroutines |
| `gdscript_recipes_and_patterns` | Common gameplay recipes: state machines, object pooling, singletons |
| `common_architectures` | Component-based, ECS, and feature-folder project architectures |
| `ui_ux_patterns` | Container layouts, themes, responsive UI, accessibility patterns |
| `shaders_and_vfx` | Shader language reference, visual effects, particles, post-processing |
| `performance_optimization` | Profiling, draw call reduction, GDScript optimization tips |
| `gdscript_deprecated` | Deprecated APIs and their modern replacements |
| `project_structure_guidelines` | AI-enforced folder organization rules and naming conventions |

### 🔊 Text-to-Speech (Read Aloud)
- **AI-Powered TTS**: Click the **▶ Read Aloud** button to hear the AI's last response spoken naturally using Google's Gemini TTS model.
- **Full Audio Player**: Play/Pause toggle, Stop button, draggable seek slider, and playback speed control (1.0x, 1.25x, 1.5x, 2.0x).
- **Smart Caching**: Once audio is generated, it's cached in memory. Pressing Play again is instant — no API call needed.
- **Background Processing**: Audio decoding runs on a separate thread so the editor never freezes.

### 📎 Universal File Attachments
- **Beyond Images**: Attach **PDFs, text files (.txt, .md, .csv, .gd, .json), audio (.mp3, .wav, .ogg),** and images directly to your prompts.
- **Smart Processing**: Text files are extracted and injected into the AI context. Binary files (PDFs, audio) are Base64-encoded and sent via `inlineData` for native Gemini Pro multimodal processing.
- **Drag & Drop**: Drag files from your OS or the Godot FileSystem dock directly into the chat.
- **Clipboard Paste**: Paste images from your clipboard with `Ctrl+V`.

### ⚡ Workflow Accelerators
- **💡 Quick Suggestions**: At the end of every response, the AI provides clickable "Smart Actions" to instantly trigger the logical next steps in your workflow.
- **🔍 Code Search Tool**: The AI can use Regex to search across your entire codebase (`search_in_files`) to find where variables, functions, or specific logic are used.
- **🐞 Watch Mode & Error Auto-Fix**: Automatically monitors your console logs. When a new error appears, the AI will intercept it, read the relevant context, and propose a fix.
- **🔄 File Watcher / Auto-Refresh**: Dropped a file into the chat for context? If you modify it externally, the plugin automatically stays in sync.
- **📂 AI Project Organizer**: The AI can analyze your entire project structure and propose a reorganization plan. It moves files, updates all path references in scripts and scenes, handles `.import` files, and supports full Undo/Redo.

### 🛡️ Safety & Control
- **👀 Diff Preview**: Before applying any code modifications, review a clean visual Diff of what the AI is about to change. Accept or Reject with a single click.
- **🛑 Stop AI**: Catch the AI doing something wrong? Instantly halt its execution stream.
- **↩️ Built-in Composite Undo**: A robust, session-aware undo system that reverts multiple AI actions (node creations, property changes, and script edits) in a single batch.
- **⚠️ Destructive Action Confirmation**: File deletions, node removals, and dangerous Git operations require user confirmation before proceeding.
- **🎮 Game State Detection**: The plugin pauses destructive agentic actions if it detects that your game is currently running to prevent file locks and data corruption.
- **💬 Tooltips Everywhere**: Every button, toggle, and slider has an English tooltip explaining exactly what it does — beginner-friendly by design.

### 🔀 Integrated Git Version Control
A full Git workflow built right into the plugin, designed for users who aren't Git experts:

| Button | What It Does |
|---|---|
| **Initialize Repository** | Creates a new local Git repo in your project folder (`git init`) |
| **GitHub URL + Save** | Connects your project to a remote GitHub repository |
| **Pull** | Downloads and merges the latest changes from GitHub |
| **Refresh Status** | Shows which files have been added, modified, or deleted |
| **✨ Auto-Generate Commit Message** | Uses AI to analyze your code changes and write a commit message |
| **Commit & Sync (Push)** | Saves your changes locally and uploads them to GitHub |
| **Create/Switch Branch** | Create a parallel "timeline" to test features safely without breaking your main game |
| **Undo Uncommitted Changes** | Discards all local edits that haven't been committed (with confirmation dialog) |
| **Force Pull Overwrite** | Replaces your entire local project with the version on GitHub (panic button, with confirmation) |

### ⚙️ Customization & Providers
- **🤖 Multi-Provider Support**: Works flawlessly with **Google Gemini** and **OpenAI / OpenRouter** APIs.
- **🎭 Custom System Prompts**: Inject your own rules and developer personas into the AI's core instructions.
- **⚙️ Presets System**: Configure multiple API providers and models, and switch between them instantly using the sleek dropdown UI.
- **🔠 Scalable UI**: Adjust the chat font size on the fly for better readability.

---

## 📦 Installation

1. Copy the `addons/gamedev_ai` folder into your Godot project's `res://addons/` directory.
2. Go to **Project Settings > Plugins** and enable **Gamedev AI**.
3. A new tab named **Gamedev AI** will appear in your editor docks (usually on the right).

---

## ⚙️ Configuration

1. Obtain an API key from [Google AI Studio](https://aistudio.google.com/) or your preferred OpenAI-compatible provider.
2. In the Godot Editor, navigate to the **Settings** tab in the Gamedev AI dock.
3. Click **Edit** to configure your API Provider, Model, and Key. It will be saved securely in your local Editor Settings.
4. You can create multiple presets and switch between them directly from the main Chat tab.

---

## 🗺️ Project Structure

```
addons/gamedev_ai/
├── gamedev_ai.gd          # Main plugin entry point
├── ai_provider.gd         # Base class for AI providers (timeout, retry, sessions)
├── gemini_provider.gd     # Google Gemini API implementation (+ TTS)
├── openai_provider.gd     # OpenAI / OpenRouter API implementation
├── tool_executor.gd       # Executes scene/file manipulations with undo/redo
├── context_manager.gd     # Collects scene tree, scripts, project structure
├── memory_manager.gd      # Long-term persistence of project decisions
├── system_prompt.gd       # AI behavioral guidelines and system instructions
├── git_manager.gd         # Git CLI wrapper (init, commit, push, branch, reset)
├── logger.gd              # Console log monitoring for Watch Mode
├── dock/
│   ├── dock.tscn          # Main UI layout
│   └── dock.gd            # UI logic and event coordination
└── skills/                # AI knowledge base documents
    ├── gdscript_style_guide.md
    ├── gdscript_modern_features.md
    ├── gdscript_signals_and_tweens.md
    ├── gdscript_recipes_and_patterns.md
    ├── common_architectures.md
    ├── ui_ux_patterns.md
    ├── shaders_and_vfx.md
    ├── performance_optimization.md
    ├── gdscript_deprecated.md
    └── project_structure_guidelines.md
```

---

## 🛠️ Roadmap (Upcoming Features)

- **Streaming Responses**: Token-by-token response display for instant feedback.
- **Context Window Management**: Smarter pruning of history to preserve core project instructions.
- **Scene Visual Preview**: Snapshots of created scenes directly inside the chat.
- **Voice Input**: Speak your prompts instead of typing.

---

## ⚖️ License

Distributed under the MIT License. See `LICENSE` for more information.
