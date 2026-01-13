extends CharacterBody2D

enum State { IDLE, WALK, RUN, ATTACK, KNOCKBACK, DIE }

@export var speed: float = 350.0
@export var run_speed_multiplier: float = 1.6
@export var mounted_speed_multiplier: float = 1.0 # Will be updated by horse level

var current_state: State = State.IDLE
var is_mounted: bool = false
var last_direction: float = 1.0
@export var show_debug_hitbox: bool = true

enum WeaponType { SWORD, AXE, MACE, BOW, WAND, STAFF }
enum OffHandType { NONE, SHIELD, GRIMOIRE }

@export var weapon_type: WeaponType = WeaponType.SWORD
@export var off_hand: OffHandType = OffHandType.NONE

# Drawing Variables
var walk_timer: float = 0.0
var attack_anim_timer: float = 0.0
var face_direction: Vector2 = Vector2.DOWN
var last_attack_direction: Vector2 = Vector2.DOWN

@onready var collision_shape = $CollisionShape2D
@onready var attack_area = $AttackArea

signal health_changed(current, max)
signal gold_changed(amount)
signal died

# Stats
@export var max_health: int = 100
var current_health: int
var gold: int = 0

var base_damage: int = 2
var knockback: float = 200.0

# Reach Parameters
@export var arm_length: float = 15.0
@export var weapon_length: float = 60.0 # base_reach (30) + extra_reach (30)

func _ready():
	current_health = max_health
	# Initialize AttackArea radius based on reach
	update_weapon_reach()
	
	# Defer signal emission to ensure UI is ready if connected
	call_deferred("emit_health_changed")
	call_deferred("emit_signal", "gold_changed", gold)

func add_gold(amount: int):
	gold += amount
	gold_changed.emit(gold)

func emit_health_changed():
	health_changed.emit(current_health, max_health)

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func die():
	current_state = State.DIE
	died.emit()

@export var attack_cooldown: float = 0.5
var time_since_last_attack: float = 0.0

func _physics_process(delta):
	if current_state == State.DIE or current_state == State.KNOCKBACK:
		return

	if time_since_last_attack > 0:
		time_since_last_attack -= delta

	handle_input()
	
	# Auto-attack detection
	check_auto_attack()
	
	# If attacking, don't move (prevents pushing)
	if current_state == State.ATTACK:
		velocity = Vector2.ZERO
		
	move_and_slide()
	
	# Drawing Logic Update
	if velocity.length() > 0.1:
		walk_timer += delta * 12
		face_direction = velocity.normalized()
	else:
		walk_timer = 0.0
		
	if current_state == State.ATTACK:
		attack_anim_timer = min(1.0, attack_anim_timer + delta * 5)
	else:
		attack_anim_timer = 0.0
		
	queue_redraw()

func _draw():
	var armor_color = Color(0.7, 0.7, 0.7) # Silver
	var cape_color = Color(0.8, 0, 0) # Red
	var eye_color = Color(0.1, 0.1, 0.1) # Dark Visor
	var wood_color = Color(0.4, 0.2, 0.1) # Brown
	var metal_color = Color(0.5, 0.5, 0.5) # Grey
	
	var bob_offset = sin(walk_timer) * 2.0 if walk_timer > 0 else 0.0
	var body_pos = Vector2.ZERO # Stay centered on hitbox
	
	# 1. Draw Horse if mounted (Base Animal Shape)
	if is_mounted:
		var horse_color = Color(0.4, 0.2, 0.1)
		# Body
		draw_circle(Vector2(0, 15), 18, horse_color)
		# Head/Neck
		var h_dir = 1 if last_direction > 0 else -1
		draw_line(Vector2(0, 5), Vector2(15 * h_dir, -5), horse_color, 8)
		draw_circle(Vector2(15 * h_dir, -5), 6, horse_color)

	# 2. Draw Cape (Behind Body)
	if face_direction.y >= 0:
		var cape_poly = [
			Vector2(-8, -5), Vector2(8, -5), # Narrower top
			Vector2(10, 20), Vector2(-10, 20) # Shorter bottom (above feet)
		]
		draw_colored_polygon(cape_poly, cape_color)

	# 3. Draw Humanoid Knight
	var head_pos = Vector2(0, -20 + bob_offset)
	var torso_pos = Vector2(0, -5 + bob_offset)
	
	# Legs (Humanoid) - Simple length bobbing
	var leg_ext = abs(sin(walk_timer * 0.5)) * 10.0 if walk_timer > 0 else 0.0
	draw_line(Vector2(-6, 5), Vector2(-6, 15 + leg_ext), armor_color, 4) # Left
	draw_line(Vector2(6, 5), Vector2(6, 25 - leg_ext), armor_color, 4)  # Right
	
	# Torso (Reduced width by 20%: 20 -> 16)
	draw_rect(Rect2(-8, -10 + bob_offset, 16, 18), armor_color)
	
	# Head/Helm
	draw_circle(head_pos, 10, armor_color)
	
	# 4. Calculate Weapon/Arm Direction
	var weapon_reach_factor = sin(attack_anim_timer * PI)
	var weapon_dir = face_direction
	if current_state == State.ATTACK:
		weapon_dir = last_attack_direction
	
	if weapon_dir.length() < 0.1: 
		weapon_dir = Vector2.RIGHT if last_direction > 0 else Vector2.LEFT
	else:
		weapon_dir = weapon_dir.normalized()

	# Hand Positions
	var r_shoulder = Vector2(8, -5 + bob_offset)
	var l_shoulder = Vector2(-8, -5 + bob_offset)
	var r_hand = Vector2(12, 5 + bob_offset)
	var l_hand = Vector2(-12, 5 + bob_offset)
	
	if current_state == State.ATTACK or attack_anim_timer > 0:
		# The weapon arm extends towards the strike
		r_hand = weapon_dir * 15 + Vector2(0, bob_offset)
	
	# Draw Arms
	draw_line(l_shoulder, l_hand, armor_color, 4) # Left Arm
	draw_line(r_shoulder, r_hand, armor_color, 4) # Right Arm (Holding Weapon)

	# 5. Draw Helm Visor
	var visor_y = head_pos.y - 2
	if face_direction.y > 0.5: # Down
		draw_rect(Rect2(-6, visor_y, 12, 2), eye_color)
	elif face_direction.y < -0.5: # Up
		pass 
	else: # Side
		var side = 1 if face_direction.x > 0 else -1
		draw_rect(Rect2(2 * side if side > 0 else -10, visor_y, 8, 2), eye_color)

	# 6. Draw Off-hand (Attached to Left Hand)
	if off_hand != OffHandType.NONE:
		if off_hand == OffHandType.SHIELD:
			draw_rect(Rect2(l_hand.x - 7, l_hand.y - 10, 14, 20), Color(0.2, 0.4, 0.7))
		else:
			draw_rect(Rect2(l_hand.x - 5, l_hand.y - 5, 10, 10), Color(0.3, 0.1, 0.5))

	# 7. Draw Weapon (Attached to Right Hand)
	var base_reach = 30.0
	var extra_reach = 30.0 * weapon_reach_factor
	
	match weapon_type:
		WeaponType.SWORD:
			# Draw 3 After-images (Ghost trails)
			for i in range(3, 0, -1):
				var ghost_timer = max(0, attack_anim_timer - i * 0.05)
				if ghost_timer > 0:
					var g_reach = 30.0 + 30.0 * sin(ghost_timer * PI)
					var g_angle = (ghost_timer - 0.5) * 1.5
					var g_dir = weapon_dir.rotated(g_angle)
					var g_tip = r_hand + g_dir * g_reach
					draw_line(r_hand, g_tip, Color(0.8, 0.8, 0.9, 0.15 * (4-i)), 3)
			
			# Current Blade
			var angle_offset = (attack_anim_timer - 0.5) * 1.5
			var slash_dir = weapon_dir.rotated(angle_offset)
			var weapon_tip = r_hand + slash_dir * (base_reach + extra_reach)
			draw_line(r_hand, weapon_tip, metal_color, 4)
		WeaponType.AXE:
			# Draw 2 After-images
			for i in range(2, 0, -1):
				var ghost_timer = max(0, attack_anim_timer - i * 0.08)
				if ghost_timer > 0:
					var g_reach = 30.0 + 30.0 * sin(ghost_timer * PI)
					var g_angle = (ghost_timer - 0.5) * 2.0
					var g_dir = weapon_dir.rotated(g_angle)
					var g_tip = r_hand + g_dir * g_reach
					draw_line(r_hand, g_tip, Color(0.4, 0.2, 0.1, 0.2 * (3-i)), 3)
					draw_rect(Rect2(g_tip.x - 6, g_tip.y - 6, 12, 12), Color(0.5, 0.5, 0.5, 0.2 * (3-i)))

			# Current Axe
			var angle_offset = (attack_anim_timer - 0.5) * 2.0
			var slash_dir = weapon_dir.rotated(angle_offset)
			var weapon_tip = r_hand + slash_dir * (base_reach + extra_reach)
			draw_line(r_hand, weapon_tip, wood_color, 4)
			draw_rect(Rect2(weapon_tip.x - 8, weapon_tip.y - 8, 16, 16), metal_color)
		WeaponType.BOW:
			# Draw Ghost Arrow Trail
			for i in range(2, 0, -1):
				var ghost_timer = max(0, attack_anim_timer - i * 0.05)
				if ghost_timer > 0:
					var g_reach = 15 + 40 * sin(ghost_timer * PI)
					draw_line(r_hand, r_hand + weapon_dir * g_reach, Color(1, 1, 1, 0.1 * (3-i)), 2)
			
			draw_arc(r_hand + weapon_dir * 5, 12, weapon_dir.angle() - 1, weapon_dir.angle() + 1, 12, wood_color, 3.0)
			if attack_anim_timer > 0:
				draw_line(r_hand, r_hand + weapon_dir * (15 + 40 * weapon_reach_factor), Color.WHITE, 2)
		_: # STAFF/MACE
			# Draw 2 Ghost trails (Thrust)
			for i in range(2, 0, -1):
				var ghost_timer = max(0, attack_anim_timer - i * 0.06)
				if ghost_timer > 0:
					var g_reach = 30.0 + 30.0 * sin(ghost_timer * PI)
					var g_tip = r_hand + weapon_dir * g_reach
					var g_color = Color(0.2, 0.8, 1.0, 0.2 * (3-i))
					draw_line(r_hand, g_tip, Color(0.4, 0.2, 0.1, 0.2 * (3-i)), 3)
					draw_circle(g_tip, 5, g_color)
					
			var weapon_tip = r_hand + weapon_dir * (base_reach + extra_reach)
			draw_line(r_hand, weapon_tip, wood_color, 4)
			draw_circle(weapon_tip, 6, Color(0.2, 0.8, 1.0, 0.8))

	# 7. Debug Hitbox
	if show_debug_hitbox:
		var outline_color = Color(1, 0, 0, 0.5)
		draw_arc(Vector2(0, -15), 15, 0, TAU, 16, outline_color, 1.0)
		draw_arc(Vector2(0, 15), 15, 0, TAU, 16, outline_color, 1.0)
		draw_line(Vector2(-15, -15), Vector2(-15, 15), outline_color, 1.0)
		draw_line(Vector2(15, -15), Vector2(15, 15), outline_color, 1.0)
		
		# Draw weapon range (Circle)
		if attack_area and attack_area.has_node("CollisionShape2D"):
			var shape = attack_area.get_node("CollisionShape2D").shape
			if shape is CircleShape2D:
				draw_arc(Vector2.ZERO, shape.radius, 0, TAU, 32, Color(1, 0.2, 0.2, 0.2), 2.0)

func update_weapon_reach():
	if attack_area and attack_area.has_node("CollisionShape2D"):
		var shape = attack_area.get_node("CollisionShape2D").shape
		if shape is CircleShape2D:
			shape.radius = arm_length + weapon_length
	queue_redraw()

func check_auto_attack():
	if time_since_last_attack <= 0 and current_state != State.ATTACK:
		var bodies = attack_area.get_overlapping_bodies()
		# if bodies.size() > 0:
		# 	print("[DEBUG] Knight sees ", bodies.size(), " bodies in attack area")
		for body in bodies:
			if body != self and (body.is_in_group("enemies") or body.has_method("take_damage")):
				last_attack_direction = (body.global_position - global_position).normalized()
				enter_state(State.ATTACK)
				perform_attack()
				break

func update_attack_direction():
	# If we have movement, update attack area position/rotation
	if velocity != Vector2.ZERO:
		attack_area.rotation = velocity.angle()

func handle_input():
	if Input.is_action_just_pressed("attack") and time_since_last_attack <= 0:
		last_attack_direction = face_direction
		if last_attack_direction.length() < 0.1:
			last_attack_direction = Vector2.RIGHT if last_direction > 0 else Vector2.LEFT
		else:
			last_attack_direction = last_attack_direction.normalized()
			
		enter_state(State.ATTACK)
		perform_attack()
		return

	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vector != Vector2.ZERO:
		var target_speed = get_actual_speed()
		if current_state == State.ATTACK:
			velocity = Vector2.ZERO
		else:
			velocity = input_vector * target_speed
			
		if input_vector.x != 0:
			last_direction = sign(input_vector.x)
		enter_state(State.WALK)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		if current_state != State.ATTACK:
			enter_state(State.IDLE)

func perform_attack():
	# Always start cooldown
	time_since_last_attack = attack_cooldown
	
	# Delay damage to match the peak of the animation (~0.2s into the 0.3s state)
	if get_tree():
		await get_tree().create_timer(0.15).timeout
		if not is_instance_valid(self) or current_state == State.DIE: return
		
		var bodies = attack_area.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("take_damage") and body != self:
				body.take_damage(base_damage, knockback)

func get_actual_speed() -> float:
	var base = speed
	if Input.is_action_pressed("run"):
		base *= run_speed_multiplier
	if is_mounted:
		base *= mounted_speed_multiplier
	return base

func enter_state(new_state: State):
	if current_state == new_state:
		return
		
	# print("[Knight] State Change: %s -> %s at %s" % [State.keys()[current_state], State.keys()[new_state], position])
	current_state = new_state
	
	if new_state == State.ATTACK:
		if get_tree():
			get_tree().create_timer(0.3).timeout.connect(func(): 
				if current_state == State.ATTACK:
					current_state = State.IDLE
			)

func update_animations():
	# We use programmatic drawing now.
	pass
