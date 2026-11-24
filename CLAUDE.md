# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4.7 2D game ("Billy-Bufords-Beautiful-Big-Bazooka"). Run via the Godot editor — there is no CLI build/run command. Open `project.godot` in Godot 4.7+ to launch. The main scene is `Main.tscn`.

## Architecture

**Player state machine** lives entirely in `scripts/gd/PlayerController.gd` (class `Player`, extends `CharacterBody2D`). The `STATE` enum drives both physics and animation:

- `PlayerController.gd` — owns movement physics, state transitions, and dash logic. All gameplay input is handled here.
- `scripts/gd/player_animated_sprite.gd` — attached to the `PlayerSprite` node; reads `parent.current_state` each frame and calls `play()` accordingly. No logic, just animation dispatch.
- `scripts/gd/bazooka_animated_sprite.gd` — same pattern for the `Bazooka` child node, reads `parent.bazooka_state`.

**Dash system** (`PlayerController.gd`):
- Requires `DASH_INPUTS_NEEDED` presses of the `Dash` action (spacebar) while moving.
- `_dash_time_left` counts down from `DASH_ANIMATION_LENGTH_IN_SECONDS`. Elapsed time is derived as `DASH_ANIMATION_LENGTH_IN_SECONDS - _dash_time_left`.
- Player velocity is only applied during the "empty" frames of the dash animation (frames `DASH_MOVE_START_FRAME` through `DASH_MOVE_END_FRAME`, inclusive); velocity is zeroed in the wind-up and recovery frames.
- Frame timing is computed from `DASH_FRAME_COUNT` and `DASH_ANIMATION_LENGTH_IN_SECONDS` — adjust those constants if the animation changes.

**Input actions** (defined in `project.godot`): `Left`, `Right`, `Up`, `Down` (WASD + arrow keys), `Dash` (spacebar).

**Sprite frames** are stored as `.tres` resources in `sprite_frames/`. Animation names used: `default`, `walk`, `dash`, `death` (player); `idle`, `fire` (bazooka).

## Motion mode

`CharacterBody2D.motion_mode` is set to `1` (Floating) — there is no gravity; movement is free in all four directions.
