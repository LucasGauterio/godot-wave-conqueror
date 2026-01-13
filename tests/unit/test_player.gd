extends "res://scripts/test_runner.gd".TestBase

func run():
	test_initial_state()
	test_movement_speed()
	test_state_machine()
	test_health_logic()
	test_attack_range()

func test_initial_state():
	var player = load("res://scenes/player/knight.tscn").instantiate()
	runner.root.add_child(player)
	assert_eq(player.current_state, player.State.IDLE, "Player should start in IDLE state")
	assert_eq(player.is_mounted, false, "Player should not be mounted initially")
	player.free()

func test_movement_speed():
	var player = load("res://scenes/player/knight.tscn").instantiate()
	runner.root.add_child(player)
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
	runner.root.add_child(player)
	
	player.enter_state(player.State.WALK)
	assert_eq(player.current_state, player.State.WALK, "Player should switch to WALK state")
	
	# Test Attack Lock (assuming logic prevents moving during attack... 
	# Actually the current logic prevents enter_state if ATTACK -> IDLE, but let's test enter_state logic)
	player.enter_state(player.State.ATTACK)
	assert_eq(player.current_state, player.State.ATTACK, "Player should switch to ATTACK state")
	
	player.free()

func test_health_logic():
	var player = load("res://scenes/player/knight.tscn").instantiate()
	runner.root.add_child(player)
	
	player.max_health = 100
	player._ready()
	
	player.take_damage(10)
	assert_eq(player.current_health, 90, "Health should decrease by damage amount")
	
	# In a real test we would spy on the signal, but checking state is enough for now
	# or we can manually connect a validator
	var signal_results = []
	player.health_changed.connect(func(c, m): signal_results.append([c, m]))
	
	player.take_damage(10)
	assert_eq(player.current_health, 80, "Health should decrease again")
	assert_gt(signal_results.size(), 0, "Health changed signal should be emitted")
	assert_eq(signal_results[0][0], 80, "Signal should carry correct current health")
	
	player.free()

func test_attack_range():
	var player = load("res://scenes/player/knight.tscn").instantiate()
	runner.root.add_child(player)
	
	player.attack_range_lanes = 2.0
	player.update_attack_direction()
	assert_eq(player.attack_area.scale.x, 2.0, "Attack area scale X should match range lanes")
	
	player.attack_range_lanes = 5.0
	player.update_attack_direction()
	assert_eq(player.attack_area.scale.x, 5.0, "Attack area scale X should match ranged lanes")
	
	player.free()
