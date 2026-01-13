extends Node2D

@onready var knight = $Knight
@onready var hud = $UI/HUD

func _ready():
	# Connect Player Signals to HUD
	if knight and hud:
		knight.health_changed.connect(hud.update_health)
		knight.gold_changed.connect(hud.update_gold)
		
		# Initialize HUD with current values
		hud.update_health(knight.current_health, knight.max_health)
		hud.update_gold(knight.gold)
