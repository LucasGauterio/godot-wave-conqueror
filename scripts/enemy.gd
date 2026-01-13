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

# Reach Parameters
@export var arm_length: float = 15.0
@export var weapon_length: float = 22.0 # ext (12) + club (10)

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
	
	# 1. Draw Humanoid Goblin
	var head_pos = Vector2(0, -18 + bob_offset)
	
	# Spindly Legs (Humanoid) - Simple length bobbing
	var leg_ext = abs(sin(walk_timer * 0.5)) * 12.0 if walk_timer > 0 else 0.0
	draw_line(Vector2(-5, 5), Vector2(-5, 15 + leg_ext), body_color, 3) # Left
	draw_line(Vector2(5, 5), Vector2(5, 27 - leg_ext), body_color, 3)  # Right
	
	# Hunched Torso
	var torso_poly = [
		Vector2(-8, -10 + bob_offset), Vector2(8, -10 + bob_offset),
		Vector2(10, 10), Vector2(-10, 10)
	]
	draw_colored_polygon(torso_poly, body_color)
	draw_rect(Rect2(-6, 2, 12, 8), detail_color) # Loincloth
	
	# Head
	draw_circle(head_pos, 9, body_color)
	
	# Pointed Ears
	var ear_y = head_pos.y - 2
	draw_colored_polygon([Vector2(-8, ear_y), Vector2(-15, ear_y - 5), Vector2(-8, ear_y + 4)], body_color)
	draw_colored_polygon([Vector2(8, ear_y), Vector2(15, ear_y - 5), Vector2(8, ear_y + 4)], body_color)
	
	# Spindly Arms/Hands
	var r_shoulder = Vector2(8, -5 + bob_offset)
	var l_shoulder = Vector2(-8, -5 + bob_offset)
	var r_hand = Vector2(12, 10 + bob_offset)
	var l_hand = Vector2(-12, 10 + bob_offset)
	
	if current_state == State.ATTACK or attack_anim_timer > 0:
		var reach = 12.0 * sin(attack_anim_timer * PI)
		r_hand = last_face_direction * (15 + reach) + Vector2(0, bob_offset)

	draw_line(l_shoulder, l_hand, body_color, 3) # Left Arm
	draw_line(r_shoulder, r_hand, body_color, 3) # Right Arm

	# 2. Draw Eyes (Black dots) based on direction
	var eye_y = head_pos.y
	if last_face_direction.y > 0.5: # Down
		draw_circle(Vector2(-4, eye_y), 1.5, Color.BLACK)
		draw_circle(Vector2(4, eye_y), 1.5, Color.BLACK)
	elif last_face_direction.y < -0.5: # Up
		pass
	else: # Sides
		var side = 1 if last_face_direction.x > 0 else -1
		draw_circle(Vector2(4 * side, eye_y), 1.5, Color.BLACK)
	
	# 3. Draw Weapon (Club) with After-images
	if current_state == State.ATTACK or attack_anim_timer > 0:
		var reach = 10.0 + 12.0 * sin(attack_anim_timer * PI)
		var angle_span = PI / 2.0 # 90 degrees
		var current_angle = last_face_direction.angle() + (attack_anim_timer - 0.5) * angle_span
		
		# Draw 1/4 circle "Pizza Slice" After-image
		if attack_anim_timer > 0:
			var trail_points = PackedVector2Array()
			trail_points.append(r_hand)
			var start_a = current_angle - angle_span * 0.5
			for j in range(9):
				var a = start_a + (angle_span * 0.5) * (j / 8.0)
				trail_points.append(r_hand + Vector2.from_angle(a) * (reach + 5))
			draw_colored_polygon(trail_points, Color(0.4, 0.2, 0.1, 0.2 * attack_anim_timer))
		
		# Current Club
		var club_dir = Vector2.from_angle(current_angle)
		var club_tip = r_hand + club_dir * reach
		draw_line(r_hand, club_tip, detail_color, 4)
		draw_circle(club_tip, 6, detail_color)

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

@onready var ray_cast = $RayCast2D

var target_to_attack: Node2D = null

func check_collisions():
	# If we have a target, check if we should switch priority
	if is_instance_valid(target_to_attack):
		# If current target is NOT the Knight, but Knight is detected by raycast, SWITCH!
		if target_to_attack.name != "Knight":
			if ray_cast.is_colliding():
				var collider = ray_cast.get_collider()
				if is_instance_valid(collider) and collider.name == "Knight":
					target_to_attack = collider
					current_state = State.ATTACK
					return
		return

	var potential_blocked = false
	
	# Primary Detection: RayCast (detects what's immediately in front)
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if is_instance_valid(collider) and collider != self:
			if collider.name == "Knight":
				target_to_attack = collider
				current_state = State.ATTACK
				return
			if collider.is_in_group("wall") or collider.get_collision_layer_value(3):
				target_to_attack = collider
				current_state = State.ATTACK
				return
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

	# Check range: either raycast or near proximity
	var in_range = false
	if ray_cast.is_colliding() and ray_cast.get_collider() == target_to_attack:
		in_range = true
	else:
		# Distance center-to-center < total reach + target radius
		var target_radius = 15.0 # standard Knight radius
		if global_position.distance_to(target_to_attack.global_position) < (arm_length + weapon_length + target_radius):
			in_range = true
			
	if not in_range:
		# print("[Enemy %s] Target %s out of range, stopping attack." % [name, target_to_attack.name])
		target_to_attack = null
		current_state = State.WALK
		return

	# Deal damage with delay to match animation peak
	time_since_last_attack = attack_cooldown # Start cooldown immediately
	
	if get_tree():
		await get_tree().create_timer(0.2).timeout
		if not is_instance_valid(self) or current_state == State.DIE: return
		if not is_instance_valid(target_to_attack): return
		
		if target_to_attack.has_method("take_damage"):
			target_to_attack.take_damage(damage)
			
			if not is_instance_valid(target_to_attack) or (target_to_attack.has_method("get") and target_to_attack.get("current_health") <= 0):
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
