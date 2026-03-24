# Persistent Memory (The AI as Architect)

If Indexing (Codebase) teaches the AI **"Where"** every source code Godot has ever processed is located, Persistent Memory teaches **"Why"** things were programmed that way.

Solo developers and small studios suffer after weeks without opening a project. *Why does the Save Game class save in binary and not JSON? Why did I use CharacterBody2D and change my mind later?*

## The "Summarize to Memory" Button

In the upper center tab of the Chat panel `(next to the History button)`, rests the shiny **💾 Summarize to Memory** button.

Whenever you have a long, arduous, and complex session with the AI (e.g., Refactoring the entire Car Physics system), follow this step:
1. At the end of the day, click **Summarize to Memory**.
2. The AI will do a deep read of everything you debated.
3. It will create permanent *Memory Log* format files in the invisible `.gamedev_ai` folder of your project.
4. When you open the project 3 weeks later to fix a bug in the car physics, the AI will magically pull from its bowels the reason why you didn't use Godot's native "Friction" without you having to open 40 old chat windows to remember why.

*The Godot Plugin effectively becomes your studio's Documenter and Software Engineer.*
