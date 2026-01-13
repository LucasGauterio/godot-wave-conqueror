extends "res://scripts/test_runner.gd".TestBase

func run():
	test_menu_components()

func test_menu_components():
	var menu = load("res://scenes/ui/menu.tscn").instantiate()
	
	var title = menu.get_node("VBoxContainer/Title")
	assert_eq(title.text, "Wave Conqueror", "Menu title should be correct")
	
	var start_button = menu.get_node("VBoxContainer/StartButton")
	assert_true(start_button is Button, "Start Button should exist")
	
	var quit_button = menu.get_node("VBoxContainer/QuitButton")
	assert_true(quit_button is Button, "Quit Button should exist")
	
	menu.free()
