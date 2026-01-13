extends StaticBody2D
class_name KingdomWall

signal health_changed(current, max)
signal destroyed

@export var max_health: int = 100
var current_health: int

func _ready():
	current_health = max_health
	add_to_group("wall")

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func die():
	destroyed.emit()
	# For now, just a print. In future, change visual to "broken"
	print("Wall destroyed!")
	# We don't queue_free immediately because it's the kingdom's last line
	# This usually triggers Game Over
