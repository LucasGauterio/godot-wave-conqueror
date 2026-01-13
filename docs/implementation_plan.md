# Game Development Implementation Plan: 2D Wave Defender

This plan outlines the design and development steps for a 2D wave defender game in Godot. The game features a knight defending a base against waves of enemies, with RPG elements like loot, shops, and base upgrades.

## User Review Required

> [!IMPORTANT] > **Lane-Based Vertical Movement**: Based on the requirement for "adjacent cell" attacks and "vertical movement" for enemies, I have designed the game as a lane-based system where enemies advance vertically and the player moves horizontally across the base of these lanes.
> **Territory Expansion**: After defeating a boss, the battlefield shifts forward (Conquest). Losing a conquered zone triggers a **Retreat** to the previous zone; Game Over only occurs if the initial zone is lost.
> **Defensive Placement**: Archers and Ballistae are stationed on top of walls. Traps are placed in the cells immediately in front of the walls.

## Proposed Changes

### Core Systems & Architecture

- **Wave Manager**: A singleton/resource to handle enemy spawning logic, difficulty scaling, and wave rewards.
- **Item System**: A resource-based system for Weapons, Armor, and Magic items with rarity levels (Common to Legendary).
- **State Machine**: A robust state machine for both Player and Enemies to handle complex animations (Walk, Attack, Knockback, etc.).
- **Hitbox & Scaling System**: Implementation of 30x60 capsules and tier-based scaling (+10%).

---

### Component Breakdown

#### [COMPLETED] [Player](file:///g:/Documents/MBA/games/scenes/player/player.tscn)

- Knight scene with `CharacterBody2D`. [IN PROGRESS: Hitbox refinement]
- Horizontal & Vertical movement logic. [COMPLETED]
- State Machine (IDLE, WALK, ATTACK). [COMPLETED]
- Auto-attack logic based on strike zones (Area2D). [IN PROGRESS: Circular weapon range]

- Base class for all enemy types. [IN PROGRESS: Scaling refinement]
- Vertical movement logic and lane stopping (No-Pushing). [COMPLETED]
- Stats: Health, Damage, Speed. [COMPLETED]
- Animations: Walk, Attack, Idle, Die. [COMPLETED]
- Target Priority (Knight > Wall > Ally). [COMPLETED]

#### [IN PROGRESS] [Base Defenses](file:///g:/Documents/MBA/scenes/defenses/wall.tscn)

- **Wall**: Health-based defensive structure. [COMPLETED]
- **Wall UI**: Health bar and destruction signal. [COMPLETED]
- **Archers/Ballistae**: Automated attack units (Not started).
- **Traps**: Environmental damage (Not started).

#### [IN PROGRESS] [Management / UI](file:///g:/Documents/MBA/scenes/ui/menu.tscn)

- **Main Menu**: Start/Quit functionality. [COMPLETED]
- **Defeat Screen**: Triggered on Wall/Player death. [COMPLETED]
- **Loot Manager**: Reward chest logic (In Discovery).
- **Inventory/Shop UI**: Item management (Not started).

---

## Verification Plan

### Automated Tests

- **Wave Spawning**: Unit test to verify the correct number and type of enemies spawn for Wave X.
- **Loot Table**: Script to run 1000 loot rolls and verify rarity distribution matches requirements.
- **Damage Logic**: Verify that weapon damage is correctly applied to enemies and wall health decreases when attacked.

### Manual Verification

- **Movement**: Verify player moves horizontally and enemies move vertically towards the wall.
- **Mount Scaling**: Buy a horse and level it up; verify the movement speed increases as expected.
- **Shop Test**: Buy an item, sell it back, and check gold balance. store items in chest and retrieve them.
- **Wall Destruction**: Let enemies destroy the wall and verify the "Game Over" state triggers.
