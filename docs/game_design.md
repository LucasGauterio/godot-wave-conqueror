# Wave Conqueror - Game Design Document

## 1. Game Overview

The ideal is to create a set of games to learn the Godot engine.
The first game is a 2D wave defender game where the player controls one knight that can use medieval weapons or magic.

## 2. Core Mechanics

### Movement & Controls

- **Player**: Moves freely in 4 directions (Up/Down/Left/Right) within the current zone. Can't leave the current zone while battle is happening.
- **Enemies**: Move vertically (Top-Down) in lanes.
- **Combat**:
  - **Auto-Attack**: Both Player and Enemies automatically attack targets within their strike zones (Area2D nodes).
  - **Strike Zones**: Combat is not hex/cell based but uses proximity detection.
  - **Attack Range**:
    - **Melee**: Affects targets in front of the actor within a strike zone (approx 1 lane width).
    - **Ranged**: Planned to affect up to 5 lanes.
  - **Target Priority**: Enemies prioritize the Player or Wall over their own allies. They will switch targets if a higher priority target enters their range.
  - **No-Pushing Physics**: Actors do not physically push each other. If an actor detects an obstacle or ally in front, they stop moving (zero velocity) but remain in their current state.

### Progression

- **Waves**:
  - Difficulty scales with wave number (increasing quantity of enemies, elites, and damage).
  - Objective: Kill all enemies in the wave.
- **Bosses**:
  - A Boss enemy appears alone at the end of each wave.
  - A **Commander Boss** or **Final Boss** may appear at specific milestones.
- **Territory Expansion**:
  - After defeating the boss enemy, the player gains their territory (Conquest).
  - The battlefield moves forward to the new zone.
  - New walls need to be built and defenses hired for the new zone.
  - **Defeat & Game Over**:
  - **Wall Destruction**: If the wall's health reaches 0%, a "Defeat" screen appears.
  - **Player Death**: If the Knight's health reaches 0, a "Defeat" screen appears.
  - **Retreat**: If a conquered zone is lost, battle retreats to the previous zone.
  - **Game Over**: If the first (base) zone is lost.
- **Leveling**: After each wave, the player can level up the Knight and the Horse.

### Economy

- **Currency**: Gold.
- **Income**:
  - **Reward Chest**: Loot and Gold are distributed via a chest at the end of the wave.
  - **Wave Reward Formula**: `10 gold * wave_number`.
  - **No Drops**: Enemies do _not_ drop gold or items on death.
- **Spending**:
  - Shop: Buy/Sell items.
  - Walls: Upgrade or Repair.
  - Mercenaries: Hire Archers and Ballistae.

## 3. Entities & Content

### Enemies

Enemies need movement speed, health, and damage stats.
Animations: Walk, Attack, Knockback, Die.

**Types**:

- **Basic**: Goblin, Skeleton, Zombie, Wolf, Imp.
- **Elite**: Hobgoblin, Skeleton Man-at-Arms, Ghoul, Werewolf, Devil.
- **Boss**: Goblin Champion, Skeleton Knight, Vampire, Werewolf Captain, Demon.
- **Commander Boss**: Goblin Lord, Skeleton Lord, Vampire Lord, Werewolf Chief, Demon Lord.
- **Final Boss**: Goblin King, Skeleton King, Vampire King, Werewolf King, Demon King.

### Player & Horse

**Player Animations**: Walk, Run, Idle, Attack, Knockback, Die.
**Mounted Animations**: Walk, Run, Idle, Attack, Die.

**Mount Mechanics**:

- Horse behaves as a permanent upgrade.
- Increases movement speed based on Horse LeveL.

### Defenses

- **Walls**:
  - Block waves. If destroyed, the zone is lost (or Game Over if base zone).
  - Have a visible health bar.
  - Upgrades: Wood Fence -> Stone Wall -> Reinforced Stone Wall.
  - Can be repaired with gold.
- **Static Defenses**:
  - **Archers**: Stationed on the wall. Hired for limited time (waves amount).
  - **Ballistae**: Stationed on the wall. Long-range attack. Hired for limited time.
  - **Traps**: Built in the first cells _in front_ of the walls.

## 4. Items & Equipment

### Inventory

- **Shop**: Buy and sell all items.
- **Chest**: Store items.
- **Rarity**: Common, Uncommon, Rare, Epic, Legendary.
- **Legendary Items**: Have a unique skill and are named.

### Pricing Logic

- **Common Item**: 1 Gold.
- **Legendary Item**: Can be sold for `1000 * Common Price`.

### Weapons

Damage is based on Weapon Type + Rarity.

- **Slash**: Sword, Battle Axe.
- **Slash + Knockback**: Sword and Shield, Claymore, Great Battle Axe.
- **Pierce**: Rapier.
- **Blunt + Knockback**: Club, Mace.
- **Pierce + Blunt + Knockback**: Morning Star.
- **Ranged**: Bow, Crossbow (Arrow).
- **Magic**:
  - **Staff**: Magic damage multiplier.
  - **Wand**: Magic speed multiplier.
  - **Grimoire**: Spell list (Fireball, Magic Missile, Ice Spear, Lightning Bolt, Magic Arrow, Magic Shield, Healing Spell).

### Armor

Defense is based on Armor Type + Rarity.
