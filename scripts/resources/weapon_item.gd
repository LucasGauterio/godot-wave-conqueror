extends "res://scripts/resources/game_item.gd"
class_name WeaponItem

enum WeaponType { 
	SWORD, SWORD_SHIELD, CLAYMORE, RAPIER, # Slash/Pierce
	BATTLE_AXE, GREAT_AXE, CLUB, MACE, MORNING_STAR, # Blunt/Slash
	BOW, CROSSBOW, # Ranged
	MAGIC_STAFF, MAGIC_WAND, GRIMOIRE # Magic
}

@export var weapon_type: WeaponType
@export var damage: int = 1
@export var attack_speed_multiplier: float = 1.0
@export var knockback_force: float = 0.0
@export var range_cells: int = 1 # 1 = adjacent

func _init():
	type = ItemType.WEAPON

func get_damage() -> int:
	# Damage influenced by rarity
	var multiplier = 1.0
	match rarity:
		Rarity.COMMON: multiplier = 1.0
		Rarity.UNCOMMON: multiplier = 1.5
		Rarity.RARE: multiplier = 2.0
		Rarity.EPIC: multiplier = 3.0
		Rarity.LEGENDARY: multiplier = 5.0
	
	return int(damage * multiplier)
