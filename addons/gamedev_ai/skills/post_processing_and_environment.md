# Godot 4.x Post-Processing and Environment Guide

This skill defines the standard architecture for setting up AAA-quality 3D graphics, lighting, and post-processing in Godot 4.

## 1. The WorldEnvironment Node
Every 3D scene (and many high-quality 2D scenes) MUST have a single `WorldEnvironment` node.
This node holds an `Environment` resource, which dictates the sky, ambient light, and all post-processing effects.

## 2. Global Illumination (SDFGI vs. VoxelGI)
Godot 4 introduced SDFGI (Signed Distance Field Global Illumination), which provides real-time, fully dynamic global illumination without baking.

- **SDFGI**: Best for large, open worlds. It handles time-of-day changes beautifully.
  - *To enable*: Check `SDFGI -> Enabled` in the Environment.
  - *Tuning*: Adjust `Min Cell Size` based on how detailed your indoor areas are. Lower cell size = better shadows but restricts the total SDFGI range.

- **VoxelGI**: Best for static interior scenes. It provides higher quality, sharp light bounces but requires you to bake a `VoxelGI` node in the editor beforehand. Not dynamic for moving lights.

## 3. Volumetric Fog
Godot 4's `Volumetric Fog` is a massive upgrade over standard depth fog. It interacts with light sources.
- Check `Volumetric Fog -> Enabled`.
- **Density**: Keep this low (around `0.01` to `0.05`) for a subtle atmosphere. Too high, and the player can't see anything.
- **Albedo**: The base color of the fog. Usually a dark grey/blue.
- **Emission**: If you want the fog to glow slightly in the dark.

### Fog Volumes
If you only need fog in a specific area (like a swamp or a poison gas cloud), do NOT use global Volumetric Fog. Instead, create a `FogVolume` node and assign it a `FogMaterial`.

## 4. Post-Processing Essentials (Glow and Tonemapping)
For any 3D or 2D game trying to look modern, these two settings are mandatory in the `Environment`:

1. **Tonemap**:
   - Change from `Linear` to `ACES`.
   - ACES mimics how real cameras capture light, preventing bright lights from clipping to ugly pure-white immediately. It provides a cinematic color curve.

2. **Glow (Bloom)**:
   - Check `Glow -> Enabled`.
   - Set the `Blend Mode` to `Additive` or `Screen`.
   - Enable `Bicubic Upscale` for smoother, higher-quality glow.
   - Any material with an `Emission` value greater than `1.0` will now glow beautifully.

## 5. Performance Note
SDFGI and Volumetric Fog are heavy. They only work in the **Forward+** renderer. If you are targeting Mobile or Web, you MUST use the **Mobile** or **Compatibility** renderer, and these features will automatically be disabled or unsupported. Always provide an option in your game settings for the player to turn off SDFGI and Volumetric Fog.
