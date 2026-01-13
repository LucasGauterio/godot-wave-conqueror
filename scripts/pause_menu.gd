extends Control

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	visible = !visible
	if get_tree():
		get_tree().paused = visible

func _on_resume_button_pressed():
	toggle_pause()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
