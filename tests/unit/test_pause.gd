extends "res://scripts/test_runner.gd".TestBase

func run():
	test_pause_menu_navigation()

func test_pause_menu_navigation():
	var pause_menu = load("res://scenes/ui/pause_menu.tscn").instantiate()
	# SceneTree (the runner) has a 'root' property
	runner.root.add_child(pause_menu)
	
	assert_true(pause_menu.has_method("toggle_pause"), "Pause menu should have toggle method")
	
	var menu_button = pause_menu.get_node("VBoxContainer/MenuButton")
	assert_eq(menu_button.text, "Return to Menu", "Menu button should have correct text")
	
	pause_menu.toggle_pause()
	assert_true(pause_menu.visible, "Menu should be visible when toggled")
	
	pause_menu.toggle_pause()
	assert_true(not pause_menu.visible, "Menu should be hidden when toggled again")
	
	pause_menu.free()
