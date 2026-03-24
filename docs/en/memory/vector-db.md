# Index Codebase (The Analytical Mind)

One of the most valuable points of Gamedev AI, differentiating it drastically from conventional ChatGPT or other VSCode co-pilots, is its deep knowledge of your game project's connective mesh.

If "Open Context" is the AI's current eye, **Index Codebase** is the robot's dormant neural web.

## What is Vector Indexing (Vector DB)?

When working with immense frameworks like Godot, many custom classes like `PlayerStats`, `InventoryManager`, or `WeaponBuilder` do not belong to the classic GDScript manual the AI studied years ago at OpenAI. They are classes **you** coined.

Going there and pasting the `PlayerStats` script every time in the chat to ask about inventory devours thousands of repetitive tokens and your time. By embedding DB Indexing (Vector Search), this ends.

### Operating the Indexing (Settings Button)
1. Go to the Gamedev AI panel and click the hidden gear tab for Context options ("⚙️ Settings" in the bottom corner).
2. Scroll down the options panel to reveal the **Vector Database** window.
3. Click on **🔍 Scan Changes**. The plugin will sweep all your File Names on disk, looking for unreported deletions or edits.
4. The visual *File List* will populate in colors pointing out crucial additions and old unchanged ones. If there is a discrepancy from the previous final Indexing:
5. Finally, click **⚡ Index Database**.

This will activate the invisible indexer mode with Gemini's text-embedding API. At the end of the progress hourglass, a semantic JSON RAG network will be hidden and encrypted on disk called `.gamedev_ai/vector_db.json`.

Now, try in the chat:
* *"How do I fix the inventory bug?"*

The AI will respond: *"Oh, I noticed from your scripts in `res://src/player_inventory.gd` and the call in `Network.gd` that the classes are not persistently connected. I'll adjust that."*



[**Next Step: Understand the 25 "Skills" Files that Help RAG** \u27A4](./skills.md)
