extends CharacterBody2D
class_name EnemyBase

enum State { WALK, ATTACK, KNOCKBACK, DIE }
enum Tier { COMMON, ELITE, BOSS, COMMANDER_BOSS, FINAL_BOSS }

@export var speed: float = 50.0
@export var max_health: int = 10
@export var damage: int = 1
@export var score_value: int = 10
@export var tier: Tier = Tier.COMMON
@export var show_debug_hitbox: bool = true

var current_health: int
var current_state: State = State.WALK
var lane_index: int = 0 # To track which vertical lane they are in

signal died(enemy)

@onready var collision_shape = $CollisionShape2D

@export var attack_cooldown: float = 1.0
var time_since_last_attack: float = 0.0

@onready var health_bar = $HealthBar

# Programmatic Drawing Variables
var walk_timer: float = 0.0
var attack_anim_timer: float = 0.0
var face_direction: Vector2 = Vector2.DOWN
var last_face_direction: Vector2 = Vector2.DOWN

func _ready():
	current_health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	
	apply_tier_scaling()
	queue_redraw()

func apply_tier_scaling():
	# Scaling: +10% cumulatively
	var scaling_factor = 1.0 + (tier * 0.1)
	self.scale = Vector2(scaling_factor, scaling_factor)
	
	# Adjust stats based on tier
	max_health = int(max_health * scaling_factor)
	current_health = max_health
	damage = int(damage * scaling_factor)
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

var is_blocked: bool = false

func _physics_process(delta):
	if current_state == State.DIE:
		return

	if time_since_last_attack > 0:
		time_since_last_attack -= delta

	# Reset blocked status each frame
	is_blocked = false
	
	# Always check collisions to update state
	check_collisions()
	
	match current_state:
		State.WALK:
			if is_blocked:
				velocity = Vector2.ZERO
			else:
				move_forward(delta)
		State.ATTACK:
			velocity = Vector2.ZERO # Stop moving while attacking
			if time_since_last_attack <= 0:
				perform_attack()
		State.KNOCKBACK:
			pass

	move_and_slide()
	
	# Drawing Logic
	if velocity.length() > 0.1:
		walk_timer += delta * 10
		face_direction = velocity.normalized()
		last_face_direction = face_direction
	else:
		walk_timer = 0.0
		
	if current_state == State.ATTACK:
		attack_anim_timer = min(1.0, attack_anim_timer + delta * 5)
	else:
		attack_anim_timer = 0.0
		
	queue_redraw()

func _draw():
	# Scaling is already applied to the node, so we draw at 30x60 base dimensions
	var body_color = Color(0.2, 0.6, 0.2) # Goblin Green
	var detail_color = Color(0.4, 0.2, 0.1) # Brown
	
	var bob_offset = sin(walk_timer) * 2.0 if walk_timer > 0 else 0.0
	
	# 1. Draw Body (Capsule 30x60 centered)
	draw_circle(Vector2(0, -15 + bob_offset), 15, body_color) # Bob the head
	draw_circle(Vector2(0, 15), 15, body_color) # Feet stay grounded
	draw_rect(Rect2(-15, -15, 30, 30), body_color)
	
	# 2. Draw Eyes (Black dots) based on direction
	var eye_pos = Vector2(0, -20 + bob_offset)
	if last_face_direction.y > 0.5: # Down
		draw_circle(eye_pos + Vector2(-5, 0), 2, Color.BLACK)
		draw_circle(eye_pos + Vector2(5, 0), 2, Color.BLACK)
	elif last_face_direction.y < -0.5: # Up
		pass
	else: # Sides
		var side = 1 if last_face_direction.x > 0 else -1
		draw_circle(eye_pos + Vector2(5 * side, 0), 2, Color.BLACK)
	
	# 3. Draw Weapon (Club) during attack
	if current_state == State.ATTACK or attack_anim_timer > 0:
		var weapon_reach = 15.0 * sin(attack_anim_timer * PI)
		var weapon_pos = last_face_direction * (20 + weapon_reach)
		draw_line(Vector2.ZERO, weapon_pos, detail_color, 4)
		draw_circle(weapon_pos, 6, detail_color)

	# 4. Optional: Draw Debug Hitbox Outline
	if show_debug_hitbox:
		var outline_color = Color(0, 1, 0, 0.5)
		draw_arc(Vector2(0, -15), 15, 0, TAU, 16, outline_color, 1.0)
		draw_arc(Vector2(0, 15), 15, 0, TAU, 16, outline_color, 1.0)
		draw_line(Vector2(-15, -15), Vector2(-15, 15), outline_color, 1.0)
		draw_line(Vector2(15, -15), Vector2(15, 15), outline_color, 1.0)

func update_animations():
	# Using programmatic drawing
	pass

func move_forward(delta):
	velocity.y = speed
	velocity.x = 0

@onready var attack_detection = $AttackDetection
@onready var ray_cast = $RayCast2D

var target_to_attack: Node2D = null

func check_collisions():
	# If we have a target, check if we should switch priority
	if is_instance_valid(target_to_attack):
		# If we are attacking the wall (or anything else), but the Knight is close, SWITCH!
		if target_to_attack.name != "Knight":
			var overlapping = attack_detection.get_overlapping_bodies()
			for body in overlapping:
				if body.name == "Knight":
					# print("[Enemy %s] SWITCHING TARGET: Wall -> Knight at %s" % [name, position])
					target_to_attack = body
					current_state = State.ATTACK
					return

		# Verify current target is still valid/in range (handled in perform_attack mostly, but good to check state)
		current_state = State.ATTACK
		return

	var potential_blocked = false
	var overlapping = attack_detection.get_overlapping_bodies()
	
	# Pass 1: Look for Player or Wall (High Priority)
	for body in overlapping:
		if body == self: continue
		
		# Prioritize Knight
		if body.name == "Knight":
			# print("[Enemy %s] TARGET FOUND: Knight at %s" % [name, position])
			target_to_attack = body
			current_state = State.ATTACK
			return
			
		# Then Wall
		if body.is_in_group("wall") or body.get_collision_layer_value(3):
			# Don't return yet, keep looking for Knight in this same list? 
			# Actually, if we found a wall, we can set it, but if Knight is also there, Knight wins.
			# Let's just set target and keep iterating? No, simple is best. 
			# We already prioritized Knight above. If we are here, body is NOT Knight.
			# But is Knight further down the list?
			# Let's verify if Knight is in the list before settling for Wall.
			var knight_in_list = false
			for b in overlapping:
				if b.name == "Knight": 
					knight_in_list = true
					target_to_attack = b
					break
			
			if knight_in_list:
				# print("[Enemy %s] TARGET FOUND: Knight (overrode Wall) at %s" % [name, position])
				current_state = State.ATTACK
				return
			else:
				# print("[Enemy %s] TARGET FOUND: Wall at %s" % [name, position])
				target_to_attack = body
				current_state = State.ATTACK
				return
		
		if body.is_in_group("enemies"):
			potential_blocked = true

	# Pass 2: Check Raycast
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if is_instance_valid(collider) and collider != self:
			if collider.is_in_group("enemies"):
				potential_blocked = true

	# If no target found but we are blocked by an ally
	if potential_blocked:
		is_blocked = true
		return

	# If nothing detected
	if current_state == State.ATTACK:
		# print("[Enemy %s] No target, resuming WALK at %s" % [name, position])
		current_state = State.WALK

func perform_attack():
	if not is_instance_valid(target_to_attack):
		target_to_attack = null
		current_state = State.WALK
		return

	# Check range
	var in_range = false
	for body in attack_detection.get_overlapping_bodies():
		if body == target_to_attack:
			in_range = true
			break
	
	if not in_range:
		if ray_cast.is_colliding() and ray_cast.get_collider() == target_to_attack:
			in_range = true
			
	if not in_range:
		print("[Enemy %s] Target %s out of range, stopping attack." % [name, target_to_attack.name])
		target_to_attack = null
		current_state = State.WALK
		return

	# Deal damage
	# Deal damage
	if target_to_attack.has_method("take_damage"):
		# print("[Enemy %s] Attacking %s at %s" % [name, target_to_attack.name, position])
		target_to_attack.take_damage(damage)
		time_since_last_attack = attack_cooldown
		
		if not is_instance_valid(target_to_attack) or (target_to_attack.has_method("get") and target_to_attack.get("current_health") <= 0):
			# print("[Enemy %s] Target %s defeated!" % [name, target_to_attack.name])
			target_to_attack = null
			current_state = State.WALK

func take_damage(amount: int, knockback_force: float = 0.0):
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
	
	if current_health <= 0:
		die()
	else:
		if knockback_force > 0:
			apply_knockback(knockback_force)

func apply_knockback(force: float):
	current_state = State.KNOCKBACK
	velocity.y = -force # Push back up
	
	# Reset state after short duration
	# Ensure tree exists before creating timer
	if get_tree():
		await get_tree().create_timer(0.2).timeout
		if current_state != State.DIE:
			current_state = State.WALK

func die():
	current_state = State.DIE
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	died.emit(self)
	queue_free()
