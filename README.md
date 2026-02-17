# Gamedev AI

**Agentic AI Assistant for Godot Engine**

Integrate Google's Gemini Models directly into your Godot workflow. Gamedev AI is an agent assistant that doesn't just provide suggestions — it interacts directly with your project. From constructing scene hierarchies to refactoring code, it helps you build your game both visually and logically.

---

## 🚀 Features

- **🛠️ Agentic Tools**: Gemini can `add_node`, `set_property`, `instance_scene`, and `edit_script` directly in the live editor.
- **👁️ Context Awareness**: The assistant automatically gathers context from your **Active Scene**, **Open Scripts**, and even takes **Viewport Screenshots** for visual guidance.
- **⚡ Quick Actions**:
    - **Refactor**: Improve code structure instantly.
    - **Fix**: Resolve logic or syntax errors in a selection.
    - **Explain**: Get detailed breakdowns of complex functions.
- **🐞 Fix Console**: A dedicated button that reads the current session's Godot logs to diagnose and propose fixes for active errors.
- **↩️ Built-in Undo**: A robust, session-aware undo system that reverts multiple AI actions (node creations, property changes, and script edits) in a single batch.

---

## 📦 Installation

1. Copy the `addons/gamedev_ai` folder into your Godot project's `res://addons/` directory.
2. Go to **Project Settings > Plugins** and enable **Gamedev AI**.
3. A new tab named **Gamedev AI** will appear in your editor docks (usually on the right).

---

## ⚙️ Configuration

1. Obtain a **Gemini API Key** from the [Google AI Studio](https://aistudio.google.com/).
2. In the Godot Editor, look for the **API Key** field in the Gamedev AI dock.
3. Paste your key. It will be saved securely in your Local Editor Settings.

---

## 🗺️ Project Structure

- **`gemini_client.gd`**: Manages API communication, history, and tool call coordination.
- **`tool_executor.gd`**: The "hands" of the assistant. Executes scene and file manipulations using Godot's `EditorInterface`.
- **`context_manager.gd`**: The "eyes" of the assistant. Collects scene tree data, script content, and viewport images.
- **`dock.gd`**: The main User Interface and event coordinator.

---

## 🛠️ Roadmap for Future Updates

- **Project Indexing**: Smarter awareness of all files and classes in your `res://` folder.
- **Documentation Access**: Integration with Godot's built-in Documentation for more accurate property usage.
- **LSP Integration**: More surgical code editing using Language Server Protocol patterns.

---

## ⚖️ License

Distributed under the MIT License. See `LICENSE` for more information.
