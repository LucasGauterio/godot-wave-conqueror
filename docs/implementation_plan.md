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

---

### Component Breakdown

#### [NEW] [Player](file:///g:/Documents/MBA/games/scenes/player/player.tscn)

- Knight scene with `KinematicBody2D` (or `CharacterBody2D` in Godot 4).
- Horizontal movement logic.
- Mounted state (Horse) with speed multipliers.
- Attack logic based on "adjacent cell" collision or raycasting.

#### [NEW] [Enemy Base](file:///g:/Documents/MBA/games/scenes/enemies/enemy_base.tscn)

- Base class for all enemy types (Basic, Elite, Boss).
- Vertical movement logic (advancing towards walls).
- Stats: Health, Damage, Speed.
- Shared animations: Walk, Attack, Knockback, Die.

#### [NEW] [Base Defenses](file:///g:/Documents/MBA/games/scenes/defenses/wall.tscn)

- **Wall**: Health-based defensive structure. Upgradeable levels (Wood, Stone, Reinforced).
- **Archers/Ballistae**: Automated attack units stationed on the wall with limited deployment time.
- **Traps**: Single-use or cooldown-based environmental damage.

#### [NEW] [Management / UI](file:///g:/Documents/MBA/games/scenes/ui/menu.tscn)

- **Main Menu**: Initial screen with Start (enters main game), Options (placeholder for cross-platform settings), and Quit functionality.
- **Loot Manager**: Logic for rolling items and gold from tables based on rarity and wave number. Gold is part of the end-of-wave reward.
- **Inventory/Shop UI**: CanvasLayer scenes for managing items and gold.

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
