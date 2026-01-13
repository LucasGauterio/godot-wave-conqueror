extends Node

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal enemy_spawned(enemy_type, lane_index)
signal counts_updated(killed_count, total_count)

@export var initial_spawn_count: int = 5
@export var spawn_interval: float = 2.0
@export var wave_number: int = 1

var enemies_remaining_to_spawn: int = 0
var active_enemies: int = 0
var enemies_killed_this_wave: int = 0
var total_enemies_this_wave: int = 0
var is_wave_active: bool = false
var spawn_timer: Timer

func _ready():
	if not spawn_timer:
		spawn_timer = Timer.new()
		spawn_timer.wait_time = spawn_interval
		spawn_timer.one_shot = false
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		add_child(spawn_timer)

func start_wave():
	if is_wave_active: return
	
	# Ensure timer is ready if start_wave call precedes _ready (unlikely but possible in tests)
	if not spawn_timer: _ready()
	
	is_wave_active = true
	enemies_remaining_to_spawn = calculate_enemy_count(wave_number)
	active_enemies = enemies_remaining_to_spawn
	total_enemies_this_wave = enemies_remaining_to_spawn
	enemies_killed_this_wave = 0
	
	wave_started.emit(wave_number)
	counts_updated.emit(enemies_killed_this_wave, total_enemies_this_wave)
	
	if spawn_timer: spawn_timer.start()

func calculate_enemy_count(wave: int) -> int:
	return initial_spawn_count + (wave - 1) * 2

func _on_spawn_timer_timeout():
	if enemies_remaining_to_spawn > 0:
		spawn_enemy()
		enemies_remaining_to_spawn -= 1
	else:
		spawn_timer.stop()

func spawn_enemy():
	# In a real scenario, we'd pick a random lane and enemy type
	var lane = randi() % 5 # Assuming 5 lanes
	enemy_spawned.emit("basic_goblin", lane)

func on_enemy_defeated():
	if not is_wave_active: return
	
	active_enemies -= 1
	enemies_killed_this_wave += 1
	counts_updated.emit(enemies_killed_this_wave, total_enemies_this_wave)
	
	if active_enemies <= 0 and enemies_remaining_to_spawn <= 0:
		complete_wave()

func complete_wave():
	is_wave_active = false
	wave_completed.emit(wave_number)
	wave_number += 1
