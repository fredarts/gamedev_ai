# Godot 4.x Animation and Cutscenes Guide

This skill defines the standard architecture for handling complex character animations and sequenced cutscenes in Godot 4.

## 1. AnimationPlayer vs AnimationTree
- `AnimationPlayer`: Use this for simple, linear animations (UI popping up, a chest opening, a simple attack).
- `AnimationTree`: **MUST** be used for character movement (Idle, Walk, Run, Jump). It allows blending multiple animations smoothly.

## 2. Setting Up an AnimationTree
To give a character fluid 8-directional or 4-directional movement:
1. Create an `AnimationPlayer` and add your basic looping animations (e.g., `idle_down`, `walk_right`).
2. Add an `AnimationTree` node.
3. Assign the `AnimationPlayer` to the `anim_player` property of the `AnimationTree`.
4. Set the `tree_root` to an `AnimationNodeStateMachine`.
5. Check `active = true`.

## 3. The BlendSpace2D
Inside the `AnimationTree`'s StateMachine panel:
1. Right-click and add a **BlendSpace2D**. Name it `Idle` or `Walk`.
2. Edit the BlendSpace2D.
3. Click the pencil tool to add animation points around the origin (0,0).
   - Place `walk_up` at (0, 1).
   - Place `walk_down` at (0, -1).
   - Place `walk_right` at (1, 0).
   - Place `walk_left` at (-1, 0).
4. Godot will now automatically blend between these animations based on a Vector2 input.

## 4. Driving the AnimationTree via Code
Do not call `play()` on the `AnimationPlayer` if the `AnimationTree` is active. Instead, set the BlendSpace parameters and use the StateMachine's `travel()` function.

```gdscript
@onready var anim_tree: AnimationTree = $AnimationTree
# Get the playback object to switch between major states (e.g., from Idle to Walk)
@onready var state_machine: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

func update_animation(input_vector: Vector2) -> void:
    if input_vector != Vector2.ZERO:
        # 1. Update the direction we are facing in the BlendSpaces
        anim_tree.set("parameters/Idle/blend_position", input_vector)
        anim_tree.set("parameters/Walk/blend_position", input_vector)
        
        # 2. Tell the StateMachine to transition to the Walk state
        state_machine.travel("Walk")
    else:
        # Transition back to Idle
        state_machine.travel("Idle")
```

## 5. Cutscenes and Timelines
For creating non-interactive cutscenes, do not use timers and hardcoded `await` sequences in scripts if it involves many moving parts.
Instead, use the `AnimationPlayer` as a Director:
1. Create an `AnimationPlayer` named `CutsceneDirector`.
2. Add a new animation (e.g., "intro_sequence").
3. Use **Call Method Tracks** to trigger dialogue functions at specific timestamps.
4. Use **Property Tracks** to move cameras or characters across the screen.
5. This gives you a visual timeline editor to perfectly sync music, movement, and dialogue without writing spaghetti code.
