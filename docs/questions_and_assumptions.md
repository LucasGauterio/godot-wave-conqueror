# Questions and Assumptions

This document outlines missing information from the initial requirements and the assumptions made to proceed with the development plan.

## 1. Grid/Lane System

**Question:** The requirements mention "adjacent cells" and vertical/horizontal movement constraints. Is the game lane-based (like Plants vs Zombies) or free-roaming within a grid?
**Assumption:** The game uses a lane-based vertical grid. Enemies advance in vertical columns, and the player moves horizontally across the base of these columns.

## 2. Magic Resources

**Question:** How are spells cast? Is there a mana/stamina system?
**Assumption:** A "Mana" resource will be implemented. Magic items (Staff, Wand) will influence mana regeneration and spell costs. Spells will have cooldowns.

## 3. Mount Mechanics

**Question:** Does the player stay mounted continuously, or is there a mount/dismount mechanic?
**Assumption:** The player is mounted continuously once a horse is purchased, as it's primarily a speed/stat upgrade. Dismounting is not a core requirement but could be a future polish item.

## 4. Territory Expansion

**Question:** How does the terrain "increase in size" after a boss?
**Assumption:** The game world expands horizontally. After a boss is defeated, a new "zone" is added to the right, and the player must move their defensive line (walls/archers) to the new boundary.

## 5. Loot Distribution

**Question:** Do enemies drop loot on death, or is it a reward menu?
**Assumption:** Loot is primarily distributed via a "Reward Chest" at the end of each wave, using the wave-based loot table including gold. Gold is not collected from fallen enemies.

## 6. Defensive Placement

**Question:** Where exactly can archers and ballistae be placed?
**Assumption:** Archers and Ballistae are stationed on top of the walls. Traps are placed in the cells immediately in front of the walls.
