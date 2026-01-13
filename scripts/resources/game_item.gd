extends Resource
class_name GameItem

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
enum ItemType { WEAPON, ARMOR, MAGIC, CONSUMABLE, QUEST, GOLD }

@export var id: String
@export var name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: Rarity = Rarity.COMMON
@export var type: ItemType

func get_base_price() -> int:
	# "any common item gold price is 1 gold"
	# "Legendary items... can be sold for 1000 times the price"
	var price_multiplier = 1
	match rarity:
		Rarity.COMMON: price_multiplier = 1
		Rarity.UNCOMMON: price_multiplier = 5
		Rarity.RARE: price_multiplier = 20
		Rarity.EPIC: price_multiplier = 100
		Rarity.LEGENDARY: price_multiplier = 1000
	
	return 1 * price_multiplier
