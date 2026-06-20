# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Sk1" — a 3D action game built in **Godot 4.6** (Forward+ renderer, Jolt Physics, Direct3D 12 on Windows). GDScript only, no C#. The main scene is [levels/main.tscn](levels/main.tscn) (`uid://bww6pjak8amgy`).

> Note: `CLAUDE.md` is listed in [.gitignore](.gitignore), so it is intentionally not committed.

## Running

There are no build or test commands — this is a Godot project run from the editor.

- Open the project: launch Godot 4.6 and load this folder, or `godot --editor --path .`
- Run the game: press F5 in the editor, or `godot --path .`
- The `.godot/` directory is generated cache (gitignored); never edit it by hand.

## Architecture: Entity + Ability composition

The core pattern is **composition over inheritance via Godot Resources**. Understand these three files before touching gameplay code:

- [entities/base/entity.gd](entities/base/entity.gd) — `Entity extends CharacterBody3D`. Holds `@export var abilities: Array[Ability]`. On `_ready()` it **duplicates each ability Resource** (so instances don't share state across scenes) and calls `init(self)`. Its `_physics_process` calls `update(delta)` on every ability, then `move_and_slide()`.
- [entities/base/ability.gd](entities/base/ability.gd) — `Ability extends Resource`. Base class with empty `init(entity)` and `update(delta)` hooks. Abilities carry both tunable data (`@export` vars) and behavior.
- [entities/player/player.gd](entities/player/player.gd) — `Player extends Entity`. In `_ready()` it calls `super()` then caches concrete abilities via `get_ability(MovementAbility)` etc. Its `_physics_process` reads input and dispatches to the cached abilities, then calls `super(delta)`.

**How abilities are wired:** abilities are not added in code — they are authored as sub-resources in the scene file. See the `abilities = Array[...]` line on the `CharacterBody3D` node in [levels/main.tscn](levels/main.tscn). To give an entity a new ability, create the script extending `Ability`, then add an instance of it to the entity's `abilities` array in the scene's inspector.

**To add a new ability:**
1. Create `entities/<entity>/abilities/<name>_ability.gd` extending `Ability`.
2. Implement `init(entity)` to cache `_entity`, and override `update(delta)` and/or expose methods (e.g. `jump()`, `start_dash()`).
3. Add it to the entity's `abilities` array in the relevant `.tscn`.
4. If the player needs to drive it directly, cache it with `get_ability(...)` and call it from `Player._physics_process`.

### Player abilities (current set)
- [movement_ability.gd](entities/player/abilities/movement_ability.gd) — horizontal velocity + rotates the body toward movement. Movement is **camera-relative**: `get_input_direction(camera)` rotates input by the camera's `current_angle_deg`.
- [jump_ability.gd](entities/player/abilities/jump_ability.gd) — jump with coyote-time window.
- [dash_ability.gd](entities/player/abilities/dash_ability.gd) — applies a speed multiplier that decays back to 1.0; calls `entity.set_speed_multiplier()` which the `MovementAbility` consumes.
- [attack_ability.gd](entities/player/abilities/attack_ability.gd) — toggles an `Area3D` (`$Area3D` on the player) on for `attack_duration`; damage system is a TODO (`_on_body_entered` only prints).

### Camera
[global/camera/camera.gd](global/camera/camera.gd) (`extends Camera3D`) is a twin-stick follow camera. It orbits the `target` with the right analog stick, lerps to an offset, and publishes `current_angle_deg` — the single value that couples camera orientation to movement direction. Movement and camera are intentionally controller-first (gamepad axes/buttons), with keyboard fallbacks defined in the input map.

## Directory layout & conventions
- `entities/` (green) — gameplay actors. `base/` = shared base classes; `player/` = player scene + abilities; `objects/` = interactables (e.g. `teleport_mission.tscn`).
- `Scene3D/` (yellow) — 3D assets: `.blend` files imported by Godot plus their `.tscn` wrappers (`pared_1`, `piso_1`, `scene_test`, `room1`). Edit geometry in Blender; Godot re-imports on focus.
- `global/` (purple) — cross-cutting systems (camera).
- `levels/` (orange) — composed playable scenes (`main.tscn`, `spawnPointPlayer.tscn`).
- Naming: scripts/scenes are `snake_case`; classes use `class_name PascalCase`. The `player` global group is registered in `project.godot`.

## Input actions
Defined in `[input]` of [project.godot](project.godot), each with keyboard + gamepad bindings: `move_up/down/left/right` (WASD / left stick), `jump` (Space / A), `dash` (Ctrl / right trigger), `attack` (G / X). Reference actions by these string names.
