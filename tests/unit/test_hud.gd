extends "res://scripts/test_runner.gd".TestBase

func run():
	test_hud_updates()

func test_hud_updates():
	var hud_scene = load("res://scenes/ui/hud.tscn")
	var hud = hud_scene.instantiate()
	runner.root.add_child(hud)
	
	# Verify initial state (based on scene default text, or just existence)
	assert_true(hud.has_method("update_health"), "HUD should have update_health method")
	
	# Test Updates
	hud.update_health(80, 100)
	assert_eq(hud.health_label.text, "HP: 80/100", "Health label should update correctly")
	
	hud.update_mana(25, 50)
	assert_eq(hud.mana_label.text, "Mana: 25/50", "Mana label should update correctly")
	
	hud.update_gold(500)
	assert_eq(hud.gold_label.text, "Gold: 500", "Gold label should update correctly")
	
	hud.free()
