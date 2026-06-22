# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4.6 game ("Sk1") using the Forward+ renderer, Jolt Physics, and the D3D12 driver on Windows. Main scene is `levels/main.tscn`. There is no test suite or build pipeline — work is driven through the Godot editor.

Common operations:
- Open the project: `godot --editor` (or open `project.godot` from the editor launcher).
- Run the main scene from CLI: `godot` (uses `run/main_scene` from `project.godot`).
- Import/refresh assets headlessly after editing files outside the editor: `godot --headless --import`.

The `.godot/` cache and `/android/` are gitignored; do not commit them.

## Architecture

### Entity + Ability composition (`entities/`)

The gameplay-relevant nodes (currently just `Player`) follow a small composition pattern instead of inheritance trees:

- `Entity` (`entities/base/entity.gd`) is the base `CharacterBody3D`. It owns an exported `Array[Ability]` and, in `_ready`, **duplicates each ability resource** before calling `init(self)`. Duplication matters: `Ability` is a `Resource`, so without it every instance would share state. `_physics_process` ticks `update(delta)` on each ability and then calls `move_and_slide()`.
- `Ability` (`entities/base/ability.gd`) is a `Resource` with `init(entity)` / `update(delta)` hooks. New abilities should subclass it and be added via the inspector to an Entity's `abilities` array — they are not nodes.
- `Player` (`entities/player/player.gd`) extends `Entity`, caches its abilities with `get_ability(Type)`, applies gravity, reads camera-relative input via `MovementAbility.get_input_direction(camera)`, and routes `Input.is_action_*` for `jump`, `dash`, `attack` to the corresponding ability. It then calls `super(delta)` so the Entity loop still runs.
- Concrete abilities (`entities/player/abilities/`):
  - `MovementAbility` — speed + camera-relative direction; exposes `speed_multiplier` used by `DashAbility`.
  - `JumpAbility` — jump with coyote time.
  - `DashAbility` — toggles `_entity.set_speed_multiplier(...)` between `dash_keep` and 1.0 with `move_toward`.
  - `AttackAbility` — toggles an `Area3D` (`$Area3D` on the Player) for `attack_duration` seconds and prints hits via `body_entered`. The Player passes the Area3D in via `attack._area = areaAttack; attack.setup_area()` because the ability is a Resource and cannot reach scene nodes itself.

When adding a new ability: subclass `Ability`, give it a `class_name`, expose tunables with `@export`, store the entity reference in `init`, and add it to the Player scene's `abilities` array. If it needs scene nodes (areas, meshes, timers), pass them in from `Player._ready` the way `AttackAbility` does.

### Camera (`global/camera/camera.gd`)

A `Camera3D` script that orbits its `target` using the right stick (`JOY_AXIS_RIGHT_X`). It writes `current_angle_deg` every physics frame; `MovementAbility.get_input_direction` reads this to rotate raw `move_*` input into world-space movement, so the player always moves relative to the camera. If you replace or wrap the camera, preserve the `current_angle_deg` field or update `MovementAbility` accordingly.

### Dungeon / rooms (`levels/dungeon/`, `levels/rooms/`)

In-progress procedural dungeon. `Room` (`levels/rooms/room_1.gd`) owns 4 doors keyed by `Vector2i` (`NORTH/SOUTH/EAST/WEST`) under `$Doors/Door{N,S,E,W}`. Each door is expected to contain a `Blocker` (`CSGBox3D`), an `Area3D` with a `CollisionShape3D`, and an `Entry` node marking the spawn point. `set_open_doors([dirs])` toggles blocker visibility/collision and the Area3D monitoring; `get_entry_point(dir)` returns the spawn position; `player_entered_door(dir)` fires when a node in the `player` group enters. `DungeonManager` (`levels/dungeon/dungeon_manager.gd`) currently just declares the direction constants and `start_coord` — it's where the grid/loading logic is meant to live.

### Globals and conventions

- Autoload: `GameManager` (`manager/game_manager.gd`) — holds shared `player_data` (`health`, `coins`, `items`). Use it instead of singletons baked into scripts.
- Global group: `player` — the Player scene is tagged with this; room/door logic checks `body.is_in_group("player")`.
- Physics layers: `1 = player`, `2 = ground`, `3 = enemy`. Player has `collision_mask = 6` (ground + enemy); the attack Area3D uses `collision_mask = 4` (enemy only).
- Input actions: `move_up/down/left/right`, `jump`, `dash`, `attack` (keyboard + gamepad bindings are in `project.godot`).
- Folder color coding (set in `project.godot`): `entities/` green, `global/` purple, `levels/` orange, `manager/` red, `scene3D/` yellow.
- Comments and signal docstrings are written in Spanish — match the existing style when editing those files.
