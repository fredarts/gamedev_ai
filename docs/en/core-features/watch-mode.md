# Watch Mode (The Magic of Auto-Debugging)

As a gamedev, you spend **30% of your time developing fantastic game logics** and painful **70% deciphering semantic Red Errors and Null Reference Exceptions** in Godot's `Debugger / Output` tab.

Gamedev AI's **Watch Mode** feature eliminates this terrifying second phase of manual debugging. It turns the bot into an invisible QA Engineer working in the next room.

## Why Activate It? And How to Activate It?
At the bottom of your Chat panel, activate the toggle called **[x] Watch Mode**.

What happens behind the scenes:
1. You hit `F5` (Play Scene / Debug Project) in Godot.
2. Your player bumps into an `Area2D` where you forgot clear `NodeGroup` initialization. The engine crashes and splashes lethal red text in the Output ("Attempt to call function 'die' in base 'null instance'").
3. Without you clicking or copying text. Gamedev AI _wakes up_, reads the syntax error log in the last 50 blocks of the console, gathers the indexed suspicious files, writes the hypothesis of the reference failure, and instantly returns a **Diff rewrite solution**, or explains step by step where the troubled Node is.

## "Tolerance" Limits and Cooldown

Overactive assistants burn Paid Models' accounts by sending repetitive "Orphan Warnings" from the Godot Engine (insignificant loose yellow errors that didn't actually crash anything).

To manage your wallet and the flood, Gamedev AI limits watching with **dynamic Cool-downs**:
* It triggers at most the first **three** Critical Output waves reported by the Log within a few short 30-second fractions, or sometimes, it waits lengthy in `standby`.

_Caring for the engine became almost child's play by reading autonomous advice._
