extends SceneTree

# Simple Test Runner for Godot

func _init():
	_run_deferred.call_deferred()

func _run_deferred():
	print("--- Starting Tests ---")
	await run_tests()
	print("--- Tests Completed ---")
	quit()

func run_tests():
	await run_test("res://tests/unit/test_player.gd")
	await run_test("res://tests/unit/test_enemy.gd")
	await run_test("res://tests/unit/test_wall.gd")
	await run_test("res://tests/unit/test_hud.gd")

func run_test(path: String):
	print("Running test file: " + path)
	var test_script_res = load(path)
	if test_script_res:
		var test_script = test_script_res.new()
		if test_script.get("runner") != null or "runner" in test_script:
			test_script.runner = self
		
		if test_script.has_method("run"):
			await test_script.run()
		
		if test_script is Node:
			test_script.queue_free()
		elif test_script is Object and not test_script is RefCounted:
			if test_script.has_method("free"):
				test_script.free()
	else:
		print("Failed to load test file: " + path)

class TestBase:
	var _test_count = 0
	var _fail_count = 0
	var runner: SceneTree
	
	func assert_eq(actual, expected, message=""):
		_test_count += 1
		if actual != expected:
			_fail_count += 1
			print("[FAIL] " + message + " | Expected: " + str(expected) + ", Got: " + str(actual))
		else:
			pass # print("[PASS] " + message)
			
	func assert_true(condition, message=""):
		assert_eq(condition, true, message)

	func assert_gt(actual, threshold, message=""):
		_test_count += 1
		if actual > threshold:
			pass
		else:
			_fail_count += 1
			print("[FAIL] " + message + " | Expected > " + str(threshold) + ", Got: " + str(actual))

	func wait_for_ready(node: Node):
		if not node.is_inside_tree():
			runner.root.add_child(node)
		# Wait 2 frames to ensure @onready and _ready are done
		await runner.process_frame
		await runner.process_frame

	func run():
		print("Executing tests...")
		# Override this method
