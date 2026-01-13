The idea is to create a set of games to learn the godot engine.

The first game is a 2D wave defender game where the player controls one knight that can use medieval weapons or magic.

The game has a horse that can be bought and increases movement speed based in the level of the horse.

The game has a shop where the player can buy/sell all items.

The game has a chest where the player can store the items.

After each wave the player can level up the knight and the horse.

Waves reward with loot based in a loot table where difficulty is based in the wave number increasing chances for rare items.

Loot table must include weapons, armor, magic items (grimoires, scrolls, potions), gold and quest items.

The player can build a wall behind it to block the waves.

The player can hire archers to attack the waves that will be stationed in the wall.

The player can build ballistae to attack the waves from a distance.

The player can build traps in the first cells in front of the walls.

After each wave the terrain increases size, amount of basic enemies and elite enemies. At the end of each wave a boss enemy appears alone.

Objective of each wave is to kill all enemies in the wave.

After defeating the boss enemy the player gains his territory and that territory needs to be defended against the next set of enemies, again building walls and hiring archers.

The player moves horizontally and can't leave the current zone while the battle is happening.

Enemies move vertically.

Possible enemies:

- Basic enemy (goblin, skeleton, zombie, wolf, imp)
- Elite enemy (hobgoblin, skeleton man-at-arms, ghoul, werewolf, devil)
- Boss enemy (goblin champion, skeleton knight, vampire, werewolf captain, demon)
- Commander Boss enemy (goblin lord, skeleton lord, vampire lord, werewolf chief, demon lord)
- Final Boss enemy (goblin king, skeleton king, vampire king, werewolf king, demon king)

The enemies need a movement speed, health, damage.

Animations for the enemies:

- Walk
- Attack
- Knockback
- Die

Animations for the player:

- Walk
- Run
- Idle
- Attack
- Knockback
- Die

Animations for the player mounted on horse:

- Walk
- Run
- Idle
- Attack
- Die

List of weapons:

- Sword (slash)
- Sword and Shield (slash+knockback)
- Claymore (slash+knockback)
- Rapier (pierce)
- Battle Axe (slash)
- Great Battle Axe (slash+knockback)
- Club (blunt+knockback)
- Mace (blunt+knockback)
- Morning Star (pierce+blunt+knockback)
- Bow (arrow)
- Crossbow (arrow)
- Magic Staff (magic damage multiplier)
- Magic Wand (magic speed multiplier)
- Magic Grimoire (spell list: fireball, magic missile, ice spear, lightning bolt, magic arrow, magic shield, healing spell)

Player damage is based in the weapon used and rarity of the weapon.

Player defense is based in the armor used and rarity of the armor.

Legendary items have a unique skill.

All items have ratity (common, uncommon, rare, epic, legendary)

any common item gold price is 1 gold.

wave rewards are 10 gold times the wave number.

Legendary items are named and unique, they can be sold for 1000 times the price of a common item.

The player can attack front, left and right.

If the player has a enemy in an adjacent cell the player attacks/knockback the enemy, the enemy takes damage.

If the enemy advance to the player cell the player takes damage.

The enemies only stop if they are knocked back or die, stoping their column from advancing.

If the enemies are at the walls they damage the walls.

If the walls are destroyed the player loses.

The walls have a health percentage of 100%, taking damage decreases the health percentage damage taken is based in enemy type and wave number.

Walls can be upgrade from wood fence, to stone wall, to reinforced stone wall.

Walls can be repaired with gold.

Hiring archers and ballistae costs gold.

Archers and ballistae can be hired for a limited time (waves amount).

## Development Assumptions & Platform Requirements

### 1. Target Platforms

- PC, Consoles, and Mobile.
- Input system must support Keyboard/Mouse, Gamepads, and Touch Screen (virtual controls).
- UI must be adaptive to various aspect ratios and resolutions.

### 2. Gameplay Mechanics

- **Grid/Lane System**: The game uses a lane-based vertical grid. Enemies advance in vertical columns, and the player moves horizontally across the base of these columns.
- **Magic Resources**: A "Mana" resource is used for spells. Magic items (Staff, Wand) influence mana regeneration and costs. Spells have cooldowns.
- **Mount Mechanics**: Once a horse is purchased, the player remains mounted. The horse acts as a speed and stat progression system.
- **Territory Expansion**: After defeating a boss, the battlefield moves forward (conquered territory). New walls must be built in the new zone.
- **Retreat Mechanic**: If a conquered zone is lost, battle retreats to the previous zone (this is a Retreat, not a Defeat). If the starting zone is lost, it is Game Over.
- **Loot & Gold**: Loot (including gold) is distributed via a "Reward Chest" at the end of each wave. Enemies do not drop gold on death.
- **Defensive Placement**: Archers and Ballistae are stationed on top of the walls. Traps are placed in the cells immediately in front of the walls.

## How to Run & Develop

We have provided several PowerShell scripts in the root directory to simplify development.

### ⚙️ Environment Setup (REQUIRED)

Before running any scripts, you must set the `GODOT_PATH` environment variable to point to your Godot executable.

**PowerShell:**

```powershell
$env:GODOT_PATH = "C:\Path\To\Your\Godot_v4.5.1_win64.exe"
```

_(You can add this to your PowerShell profile to make it permanent)_

### 🎮 Play the Game

Run the game using the current Godot version:

```powershell
./play.ps1
```

### 🛠️ Open Editor

Open the project in the Godot Editor to make changes:

```powershell
./edit.ps1
```

### 🐞 Debug Mode

Run the game with **Visible Collisions** and **Navigation Debug** enabled:

```powershell
./debug.ps1
```

### 🧪 Run Tests

Execute the automated test suite (Unit Tests):

```powershell
./run_tests.ps1
```

### 📦 Build / Compile

Export the game executable to the `build/` folder (Requires "Windows Desktop" export preset):

```powershell
./build.ps1
```
