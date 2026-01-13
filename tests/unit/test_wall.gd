extends "res://scripts/test_runner.gd".TestBase

func run():
	test_wall_health()
	test_wall_destruction()

func test_wall_health():
	var wall = load("res://scenes/defenses/wall.tscn").instantiate()
	runner.root.add_child(wall)
	
	wall.max_health = 100
	wall._ready()
	
	wall.take_damage(30)
	assert_eq(wall.current_health, 70, "Wall health should decrease")
	
	wall.free()

func test_wall_destruction():
	var wall = load("res://scenes/defenses/wall.tscn").instantiate()
	runner.root.add_child(wall)
	
	var signal_emitted = [false]
	wall.destroyed.connect(func(): signal_emitted[0] = true)
	
	wall.take_damage(wall.max_health + 10)
	assert_true(signal_emitted[0], "Wall should emit destroyed signal on 0 health")
	assert_eq(wall.current_health, 0, "Wall health should not be negative")
	
	wall.free()
