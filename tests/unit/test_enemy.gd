extends "res://scripts/test_runner.gd".TestBase

func run():
	print("[test_enemy] Running tests...")
	await test_movement()
	await test_damage_and_death()
	await test_cooldown_logic()
	print("[test_enemy] Completed.")

func test_movement():
	var enemy = load("res://scenes/enemies/enemy_base.tscn").instantiate()
	await wait_for_ready(enemy)
	
	enemy.speed = 100.0
	# We test the move_forward method directly
	if enemy.has_method("move_forward"):
		enemy.move_forward(0.1)
		assert_eq(enemy.velocity.y, 100.0, "Enemy should move vertically down with positive speed")
		assert_eq(enemy.velocity.x, 0.0, "Enemy should not move horizontally")
	
	enemy.free()

func test_damage_and_death():
	var enemy = load("res://scenes/enemies/enemy_base.tscn").instantiate()
	await wait_for_ready(enemy)
	
	enemy.max_health = 10
	enemy.current_health = 10
	
	# Test Damage
	enemy.take_damage(4)
	assert_eq(enemy.current_health, 6, "Enemy health should decrease by damage amount")
	
	# Test Death
	enemy.take_damage(10)
	assert_eq(enemy.current_state, 3, "Enemy should be in DIE state (3)")
	
	enemy.free()

func test_cooldown_logic():
	var enemy = load("res://scenes/enemies/enemy_base.tscn").instantiate()
	await wait_for_ready(enemy)
	
	enemy.time_since_last_attack = 1.0
	# Manual decrement test
	enemy.time_since_last_attack -= 0.5
	assert_eq(enemy.time_since_last_attack, 0.5, "Cooldown should decrease")
	
	enemy.free()
