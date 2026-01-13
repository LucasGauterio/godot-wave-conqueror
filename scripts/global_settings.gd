extends Node

signal debug_toggled(is_on: bool)

var show_debug_hitboxes: bool = true:
	set(value):
		show_debug_hitboxes = value
		debug_toggled.emit(show_debug_hitboxes)
