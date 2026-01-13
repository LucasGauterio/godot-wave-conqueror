extends Node2D

@onready var knight = $Knight
@onready var hud = $UI/HUD
@onready var wave_manager = $WaveManager
@onready var spawn_points = $SpawnPoints
@onready var enemies_container = $Enemies

var enemy_scene = preload("res://scenes/enemies/enemy_base.tscn")

func _ready():
	# Connect Player Signals to HUD
	if knight and hud:
		knight.health_changed.connect(hud.update_health)
		knight.gold_changed.connect(hud.update_gold)
		
		# Initialize HUD with current values
		hud.update_health(knight.current_health, knight.max_health)
		hud.update_gold(knight.gold)

	if wave_manager:
		wave_manager.enemy_spawned.connect(spawn_enemy)
		# Start the first wave
		wave_manager.start_wave()

func spawn_enemy(type: String, lane_index: int):
	var enemy = enemy_scene.instantiate()
	
	# Determine spawn position based on lane index (clamped to available markers)
	var markers = spawn_points.get_children()
	if markers.size() > 0:
		lane_index = lane_index % markers.size()
		enemy.position = markers[lane_index].position
	
	enemies_container.add_child(enemy)
	
	# Connect enemy signals if needed (e.g. for score/wave tracking)
	enemy.died.connect(func(e): wave_manager.on_enemy_defeated())
