extends Node2D

@onready var knight = $Knight
@onready var hud = $UI/HUD
@onready var wave_manager = $WaveManager
@onready var spawn_points = $SpawnPoints
@onready var enemies_container = $Enemies

@onready var kingdom_wall = $KingdomWall
var enemy_scene = preload("res://scenes/enemies/enemy_base.tscn")
var defeat_screen_scene = preload("res://scenes/ui/defeat_screen.tscn")
var victory_screen_scene = preload("res://scenes/ui/victory_screen.tscn")

func _ready():
	# Connect Player Signals to HUD
	if knight and hud:
		knight.health_changed.connect(hud.update_health)
		knight.gold_changed.connect(hud.update_gold)
		knight.died.connect(trigger_defeat) # Player death also triggers defeat
		
		# Initialize HUD with current values
		hud.update_health(knight.current_health, knight.max_health)
		hud.update_gold(knight.gold)

	if wave_manager:
		wave_manager.enemy_spawned.connect(spawn_enemy)
		if hud:
			wave_manager.wave_started.connect(hud.update_wave)
			wave_manager.counts_updated.connect(hud.update_enemies)
			
		wave_manager.wave_completed.connect(trigger_victory)
		wave_manager.start_wave()
		
	if kingdom_wall:
		kingdom_wall.destroyed.connect(trigger_defeat)

func trigger_defeat():
	var defeat_ui = defeat_screen_scene.instantiate()
	add_child(defeat_ui)
	get_tree().paused = true

func trigger_victory(wave_number: int):
	var victory_ui = victory_screen_scene.instantiate()
	add_child(victory_ui)
	victory_ui.next_wave_requested.connect(start_next_wave)
	
	# Pause game logic while looking at victory screen
	get_tree().paused = true

func start_next_wave():
	get_tree().paused = false
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
