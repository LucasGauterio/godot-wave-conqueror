extends "res://scripts/test_runner.gd".TestBase

func run():
	print("[test_player] Running tests...")
	await test_initial_state()
	await test_movement_speed()
	await test_state_machine()
	await test_health_logic()
	print("[test_player] Completed.")

func test_initial_state():
	var player = load("res://scenes/player/knight.tscn").instantiate()
	await wait_for_ready(player)
	assert_eq(player.current_state, player.State.IDLE, "Player should start in IDLE state")
	assert_eq(player.is_mounted, false, "Player should not be mounted initially")
	player.free()

func test_movement_speed():
	var player = load("res://scenes/player/knight.tscn").instantiate()
	await wait_for_ready(player)
	player.speed = 100.0
	player.run_speed_multiplier = 2.0
	
	# Test Walking Speed
	assert_eq(player.get_actual_speed(), 100.0, "Walking speed should be base speed")
	
	# Test Mounted Speed
	player.is_mounted = true
	player.mounted_speed_multiplier = 1.5
	assert_eq(player.get_actual_speed(), 150.0, "Mounted speed should apply multiplier")
	
	player.free()

func test_state_machine():
	var player = load("res://scenes/player/knight.tscn").instantiate()
	await wait_for_ready(player)
	
	player.enter_state(player.State.WALK)
	assert_eq(player.current_state, player.State.WALK, "Player should switch to WALK state")
	
	player.enter_state(player.State.ATTACK)
	assert_eq(player.current_state, player.State.ATTACK, "Player should switch to ATTACK state")
	
	player.free()

func test_health_logic():
	var player = load("res://scenes/player/knight.tscn").instantiate()
	await wait_for_ready(player)
	
	player.max_health = 100
	player.current_health = 100
	
	player.take_damage(10)
	assert_eq(player.current_health, 90, "Health should decrease by damage amount")
	
	var signal_results = []
	player.health_changed.connect(func(c, m): signal_results.append([c, m]))
	
	player.take_damage(10)
	assert_eq(player.current_health, 80, "Health should decrease again")
	assert_gt(signal_results.size(), 0, "Health changed signal should be emitted")
	assert_eq(signal_results[0][0], 80, "Signal should carry correct current health")
	
	player.free()
