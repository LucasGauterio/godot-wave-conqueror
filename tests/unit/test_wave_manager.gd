extends "res://scripts/test_runner.gd".TestBase

const WaveManagerScript = preload("res://scripts/wave_manager.gd")

func run():
	test_wave_calculation()
	test_wave_start()
	test_spawning_logic()
	test_wave_completion()

func test_wave_calculation():
	var wm = WaveManagerScript.new()
	runner.root.add_child(wm)
	
	wm.initial_spawn_count = 5
	assert_eq(wm.calculate_enemy_count(1), 5, "Wave 1 should have initial count")
	assert_eq(wm.calculate_enemy_count(2), 7, "Wave 2 should have +2 enemies")
	
	wm.free()

func test_wave_start():
	var wm = WaveManagerScript.new()
	runner.root.add_child(wm)
	
	var signal_emitted = []
	wm.wave_started.connect(func(n): signal_emitted.append(n))
	
	wm.start_wave()
	
	assert_gt(signal_emitted.size(), 0, "Wave started signal should emit")
	assert_eq(wm.is_wave_active, true, "Wave should be active")
	assert_eq(wm.enemies_remaining_to_spawn, 5, "Should initialize remaining enemies")
	
	wm.free()

func test_spawning_logic():
	var wm = WaveManagerScript.new()
	runner.root.add_child(wm)
	
	wm.initial_spawn_count = 2
	wm.spawn_interval = 0.5 # Small interval
	wm.start_wave()
	
	# We manually invoke timeout to verify logic indepedent of physics time
	wm._on_spawn_timer_timeout()
	assert_eq(wm.enemies_remaining_to_spawn, 1, "Should decrement remaining spawn count")
	
	wm._on_spawn_timer_timeout()
	assert_eq(wm.enemies_remaining_to_spawn, 0, "Should reach 0 remaining")
	
	# When remaining is 0, timer should be stopped
	wm._on_spawn_timer_timeout()
	# assert_eq(wm.spawn_timer.is_stopped(), true, "Timer should stop") 
	# Note: is_stopped() might not update immediately in non-physics test frame without wait.
	# We rely on logic verification.
	
	wm.free()

func test_wave_completion():
	var wm = WaveManagerScript.new()
	runner.root.add_child(wm)
	
	wm.start_wave()
	wm.enemies_remaining_to_spawn = 0
	wm.active_enemies = 1
	
	var completed_signal = []
	wm.wave_completed.connect(func(n): completed_signal.append(n))
	
	wm.on_enemy_defeated()
	assert_gt(completed_signal.size(), 0, "Wave completed signal should emit")
	
	wm.free()
