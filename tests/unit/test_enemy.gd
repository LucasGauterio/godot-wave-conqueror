extends "res://scripts/test_runner.gd".TestBase

func run():
	test_movement()
	test_damage_and_death()

func test_movement():
	var enemy = load("res://scenes/enemies/enemy_base.tscn").instantiate()
	runner.root.add_child(enemy)
	
	enemy.speed = 100.0
	enemy.move_forward(0.1)
	
	assert_eq(enemy.velocity.y, 100.0, "Enemy should move vertically down with positive speed")
	assert_eq(enemy.velocity.x, 0.0, "Enemy should not move horizontally")
	
	enemy.free()

func test_damage_and_death():
	var enemy = load("res://scenes/enemies/enemy_base.tscn").instantiate()
	runner.root.add_child(enemy)
	
	enemy.max_health = 10
	enemy._ready() # Force ready to set current_health
	
	# Test Damage
	enemy.take_damage(4)
	assert_eq(enemy.current_health, 6, "Enemy health should decrease by damage amount")
	assert_eq(enemy.current_state, enemy.State.WALK, "Enemy should still be walking if not dead")
	
	# Test Death
	# We assert that the signal is emitted. In a real runner we might spy on it.
	# For now we check state.
	enemy.take_damage(10) # 6 - 10 = -4
	assert_eq(enemy.current_health, -4, "Enemy health can go negative internally")
	assert_eq(enemy.current_state, enemy.State.DIE, "Enemy should enter DIE state")
	
	enemy.free()
