extends "res://scripts/test_runner.gd".TestBase

const GameItem = preload("res://scripts/resources/game_item.gd")
const WeaponItem = preload("res://scripts/resources/weapon_item.gd")

func run():
	test_item_rarity_price()
	test_weapon_damage_scaling()

func test_item_rarity_price():
	var item = GameItem.new()
	
	item.rarity = 0 # GameItem.Rarity.COMMON
	assert_eq(item.get_base_price(), 1, "Common item price should be 1")
	
	item.rarity = 4 # GameItem.Rarity.LEGENDARY
	assert_eq(item.get_base_price(), 1000, "Legendary item price should be 1000")
	
	# Clean up logic not needed for resources as they are RefCounted usually, 
	# but GameItem inherits Resource so it's RefCounted properly.

func test_weapon_damage_scaling():
	var sword = WeaponItem.new()
	sword.damage = 10
	
	sword.rarity = 0 # GameItem.Rarity.COMMON
	assert_eq(sword.get_damage(), 10, "Common weapon should have base damage")
	
	sword.rarity = 2 # GameItem.Rarity.RARE
	assert_eq(sword.get_damage(), 20, "Rare weapon should be 2x damage") # 10 * 2.0
	
	sword.rarity = 4 # GameItem.Rarity.LEGENDARY
	assert_eq(sword.get_damage(), 50, "Legendary weapon should be 5x damage") # 10 * 5.0
