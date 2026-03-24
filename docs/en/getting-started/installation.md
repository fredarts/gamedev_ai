# Installation

Welcome to the official **Gamedev AI** documentation! This page will focus on how to quickly add the assistant to your current Godot 4.6 project.

## Requirements
* **Godot Engine:** Version 4.6 or higher (native `.gdextension` support is not required, the plugin runs pure GDScript).
* Google or OpenRouter account for API keys.

## Manual Step-by-Step (GitHub)

1. Create or open an existing project in Godot 4.6.
2. Navigate to your project's root folder (where the `project.godot` file is located).
3. Create an `addons` folder (if it doesn't already exist).
4. Inside `addons/`, download or clone the plugin repository:
```bash
git clone git@github.com:fredarts/gamedev_ai.git
```
*(Or download the `.zip` file from the Releases tab on GitHub and extract it inside `res://addons/gamedev_ai`).*

## Activating in the Editor

With the files in place:
1. Open your Godot project editor.
2. Go to the `Project` menu at the top and choose `Project Settings`.
3. Navigate to the `Plugins` tab at the top.
4. Find **Gamedev AI** in the list of installed plugins.
5. Check the `Enable` box.

That's it! When you enable it for the first time, you will see the Gamedev AI Chat panel appear in your editor's right *Dock*.

[**Next Step: Configure your API Key** \u27A4](./configuration.md)
