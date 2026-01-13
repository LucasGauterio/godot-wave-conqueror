# Project Directives & Guidelines

This document summarizes all user requests, constraints, and established patterns for the "Wave Conqueror" project. It serves as a source of truth for all future development tasks.

## 1. Core Development Principles

- **Platform Target**: PC, Console, and Mobile.
  - **UI**: Must be adaptive to different aspect ratios (Ultrawide to Vertical Mobile) and respect safe areas.
  - **Input**: Must support Keyboard/Mouse, Gamepad, and Touch (Virtual Joypad) simultaneously.
- **Universal Navigation**:
  - **Requirement**: Every screen must have a clear path to return to the Main Menu (Esc key, Start button, or UI back button).
- **Testing Mainstream**:
  - **Requirement**: Every new feature _must_ include unit tests and test scenarios.
  - **Automation**: Tests must be runnable via the headless test runner (`./run_tests.ps1`).
- **Documentation**:
  - Manage plans and tracking in `docs/`.
  - Update `README.md` with any new high-level assumptions or requirement changes immediately.
  - Maintain `questions_and_assumptions.md` for clarity on undefined behaviors.
- **Continuous Improvement**:
  - **Requirement**: After resolving complex issues, summarize the root cause and update these Directives with new standards to prevent recurrence.

## 2. Gameplay Mechanics & Rules

- **Movement System**:
  - **Player**: Moves horizontally only.
  - **Enemies**: Move vertically in "lanes".
  - **Combat**: Player attacks enemies in _adjacent_ cells.
- **Progression**:
  - **Mounts**: Permanent speed/stat upgrade. No dismount mechanic.
  - **Territory**:
    - **Conquest**: Defeating a boss advances the battlefield forward. New walls needed.
    - **Retreat**: Losing a conquered zone triggers a tactical RETURN to the previous zone (not a Defeat).
    - **Defeat**: Losing the FIRST zone results in Game Over.
- **Economy**:
  - **Loot**: All rewards (Items + Gold) are distributed via a **Reward Chest** at the end of the wave.
  - **No Drops**: Enemies do _not_ drop gold or items on death.
- **Defenses**:
  - **Wall Placement**: Archers and Ballistae are stationed _on_ the walls.
  - **Trap Placement**: Placed in cells immediately _in front_ of walls.
- **Magic**: Uses a **Mana** system with cooldowns.

## 3. Tech Stack & Environment

- **Engine**: Godot 4.x (currently 4.5.1).
- **Renderer**: `gl_compatibility` (for maximum mobile/web/older hardware support).
- **Project Structure**:
  - `scenes/`: Organized by component (`player`, `enemies`, `ui`, etc.).
  - `scripts/`: Shared logic.
  - `tests/`: `unit` and `integration` folders.

## 4. Workflow Check

Before marking a task as "Done":

1. [ ] Is the code compatible with Mobile/Console?
2. [ ] Is there a Unit Test verifying the logic?
3. [ ] Does it adhere to the "Lane-based" and "Chest-only loot" rules?
4. [ ] Is the documentation updated?
5. [ ] Have you updated directives with any new technical learnings?

## 5. Technical Standards (Anti-Patterns to Avoid)

### Testing

- **Tree Dependency**: Unit tests running in headless mode often lack a default `SceneTree`.
  - _Rule_: If a test needs `get_tree()`, you **MUST** add the node to `runner.root` (e.g., `runner.root.add_child(node)`).
- **Class Loading**: `class_name` global registration can be flaky in headless script references.
  - _Rule_: Use `preload("res://path/to/script.gd")` in test files instead of relying on global class names.

### Environment

- **Pathing**: Never hardcode system paths (e.g., `C:\Program Files\...`).
  - _Rule_: Use environment variables (e.g., `$env:GODOT_PATH`) or project-relative paths.

### Logic Verification

- **Physics in Tests**: `Area2D` and `CollisionShape2D` updates generally require a physics frame.
  - _Rule_: For collision tests, trust the signal/logic flow or use `await get_tree().physics_frame` (requires async test runner support), otherwise mock the interaction.
