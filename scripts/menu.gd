extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_button_pressed():
	print("Options pressed - UI logic to be implemented")

func _on_quit_button_pressed():
	get_tree().quit()
