extends SceneTree

# Simple Test Runner for Godot

func _init():
	print("--- Starting Tests ---")
	run_tests()
	print("--- Tests Completed ---")
	quit()

func run_tests():
	var test_dir = "res://tests/unit/"
	scan_and_run(test_dir)

func scan_and_run(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if not file_name.begins_with(".") and not file_name.begins_with("_"):
					scan_and_run(path + file_name + "/")
			elif file_name.ends_with(".gd") and not file_name.begins_with("_"):
				print("Running test file: " + path + file_name)
				var test_script_res = load(path + file_name)
				if test_script_res:
					var test_script = test_script_res.new()
					if test_script.get("runner") != null or "runner" in test_script:
						test_script.runner = self
					
					if test_script.has_method("run"):
						test_script.run()
					
					if test_script is Node:
						test_script.queue_free()
					elif test_script is Object and not test_script is RefCounted:
						if test_script.has_method("free"):
							test_script.free()
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: " + path)

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

	func run():
		print("Executing tests...")
		# Override this method
