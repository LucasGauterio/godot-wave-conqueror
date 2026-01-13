extends CanvasLayer

signal next_wave_requested

func _on_next_wave_pressed():
	# Resume the game logic here won't automatically start the next wave unless we signal it
	# The main scene should handle this signal, unpause, and tell WaveManager to start next
	next_wave_requested.emit()
	queue_free()
