# Wave Conqueror - Game Concept & Mechanics

## Core Concept

A 2D wave defender game where the player controls a knight (on foot or mounted) defending a base against vertical waves of diverse enemies.

## Progression

- **Waves**: Difficulty scales with wave number (more enemies, elites, damage).
- **Bosses**: Appear at the end of waves. Defeating them conquers territory.
- **Territory**:
  - **Conquest**: Victory against a boss moves the battlefield forward.
  - **Retreat**: Losing a forward zone retreats to the previous one.
  - **Defeat**: Losing the base (first zone) is Game Over.
- **Upgrades**:
  - **Knight**: Level up stats.
  - **Horse**: Buy/Upgrade for permanent speed and stat boosts.
  - **Walls**: Upgrade from Wood -> Stone -> Reinforced.

## Gameplay Mechanics

- **Movement**:
  - **Player**: Horizontal (Left/Right) across the base of lanes.
  - **Enemies**: Vertical (Top-Down) in lanes.
- **Combat**:
  - **Player Attack**: Hits enemies in adjacent cells (Front/Left/Right).
  - **Enemy Attack**: Damages player if they reach the player's cell.
  - **Wall Damage**: Enemies at the bottom damage the wall.
- **Economy (Gold)**:
  - **Source**: **Reward Chest** at end of wave (Enemies drop nothing).
  - **Spend**: Shop (Items), Wall Repairs, Hiring Archers/Ballistae/Traps.

## Entities

- **Enemies**: Basic (Goblin, Skeleton), Elite (Hobgoblin, Ghoul), Bosses (Kings, Lords).
- **Defenses**:
  - **Archers/Ballistae**: stationed _ON_ the wall.
  - **Traps**: placed _IN FRONT_ of the wall.

## Items & Equipment

- **Rarity**: Common (1g) -> Legendary (1000g).
- **Weapons**: Swords, Axes, Bows, Magic Staffs.
- **Magic**: Spells (Fireball, Heal) use Mana.
- **Legendary**: Unique skills.
