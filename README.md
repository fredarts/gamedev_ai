# Gamedev AI

**Agentic AI Assistant for Godot Engine 4.6+**

Integrate AI models directly into your Godot workflow. Gamedev AI is an agent assistant that doesn't just provide suggestions — it interacts directly with your project. From constructing scene hierarchies to refactoring code, it helps you build your game both visually and logically.

---

## 🚀 Features

- **🤖 Multi-Provider Support**: Works with **Google Gemini** and **OpenAI / OpenRouter** APIs. Switch between providers and presets at any time.
- **🛠️ Agentic Tools**: The AI can `add_node`, `set_property`, `instance_scene`, `edit_script`, `patch_script`, `create_scene`, `connect_signal`, `grep_search`, and more — directly in the live editor.
- **👁️ Context Awareness**: Automatically gathers context from your **Active Scene**, **Open Scripts**, **Project Structure**, and even takes **Viewport Screenshots** for visual guidance.
- **🖼️ Multimodal Input**: Paste images directly into the chat (Ctrl+V) for visual context.
- **⚡ Quick Actions**:
    - **Refactor**: Improve code structure instantly.
    - **Fix**: Resolve logic or syntax errors in a selection.
    - **Explain**: Get detailed breakdowns of complex functions.
    - **Fix Console**: Reads the current session's Godot logs to diagnose and fix active errors.
- **🐞 Watch Mode**: Automatically monitors console logs for errors and triggers AI auto-fix when new errors appear.
- **↩️ Built-in Undo**: A robust, session-aware undo system that reverts multiple AI actions (node creations, property changes, and script edits) in a single batch.
- **⚠️ Destructive Action Confirmation**: File deletions and node removals now require user confirmation before proceeding.
- **⏱️ API Timeout & Retry**: Automatic 120-second timeout with exponential backoff retry for transient API errors (429, 5xx).
- **📊 Token Usage Display**: Real-time display of prompt, completion, and total token usage after each response.
- **💬 Chat History**: Save and load previous conversations with session management and presets.

---

## 📦 Installation

1. Copy the `addons/gamedev_ai` folder into your Godot project's `res://addons/` directory.
2. Go to **Project Settings > Plugins** and enable **Gamedev AI**.
3. A new tab named **Gamedev AI** will appear in your editor docks (usually on the right).

---

## ⚙️ Configuration

1. Obtain an API key from [Google AI Studio](https://aistudio.google.com/) or your preferred OpenAI-compatible provider.
2. In the Godot Editor, look for the **API Key** field in the Gamedev AI dock.
3. Paste your key. It will be saved securely in your local Editor Settings.
4. Use the **Presets** system to configure multiple providers and switch between them.

---

## 🗺️ Project Structure

- **`gamedev_ai.gd`**: Main plugin entry point. Manages provider initialization, dock setup, and preset coordination.
- **`ai_provider.gd`**: Base class for AI providers. Handles timeout, retry logic, session management, and lifecycle signals.
- **`gemini_provider.gd`**: Google Gemini API provider implementation.
- **`openai_provider.gd`**: OpenAI / OpenRouter API provider implementation.
- **`tool_executor.gd`**: The "hands" of the assistant. Executes scene and file manipulations using Godot's `EditorInterface` with full undo/redo support.
- **`context_manager.gd`**: The "eyes" of the assistant. Collects scene tree data, script content, project structure, and viewport screenshots with caching.
- **`system_prompt.gd`**: Defines the AI's system instructions and behavioral guidelines.
- **`gdscript_codex.gd`**: Comprehensive GDScript 4.6.1 best practices reference injected into the system prompt.
- **`logger.gd`**: Simple log relay for UI display.
- **`dock/dock.gd`**: The main User Interface and event coordinator.

---

## 🛠️ Roadmap

- **UI Migration**: Migrate dock UI from code-generated to `.tscn` scene file.
- **Diff Preview**: Show visual diff before applying script edits.
- **Streaming Responses**: Token-by-token response display.
- **Custom System Prompts**: User-editable AI personas.
- **Drag & Drop**: Drag files from the FileSystem dock into the chat.

---

## ⚖️ License

Distributed under the MIT License. See `LICENSE` for more information.
