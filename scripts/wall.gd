extends StaticBody2D
class_name KingdomWall

signal health_changed(current, max)
signal destroyed

@export var max_health: int = 100
var current_health: int

@onready var health_bar = $HealthBar

func _ready():
	current_health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	add_to_group("wall")

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	if health_bar:
		health_bar.value = current_health
	health_changed.emit(current_health, max_health)
	
	print("Wall hit! Health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	destroyed.emit()
	print("Wall destroyed!")
	queue_free()
