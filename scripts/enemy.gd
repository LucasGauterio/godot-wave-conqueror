extends CharacterBody2D
class_name EnemyBase

enum State { WALK, ATTACK, KNOCKBACK, DIE }

@export var speed: float = 50.0
@export var max_health: int = 10
@export var damage: int = 1
@export var score_value: int = 10

var current_health: int
var current_state: State = State.WALK
var lane_index: int = 0 # To track which vertical lane they are in

signal died(enemy)

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

@export var attack_cooldown: float = 1.0
var time_since_last_attack: float = 0.0

@onready var health_bar = $HealthBar

func _ready():
	current_health = max_health
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
	update_animations()

func update_animations():
	# Simple state-to-animation mapping
	var anim_name = "walk"
	
	match current_state:
		State.WALK:
			if is_blocked:
				anim_name = "idle"
			else:
				anim_name = "walk"
		State.ATTACK:
			anim_name = "attack"
		State.DIE:
			anim_name = "die"
	
	if animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)

func move_forward(delta):
	velocity.y = speed
	velocity.x = 0

@onready var attack_detection = $AttackDetection
@onready var ray_cast = $RayCast2D

var target_to_attack: Node2D = null

func check_collisions():
	# If we have a target, check if it's still alive and valid
	if is_instance_valid(target_to_attack):
		# If the target is the player or wall, we stay in attack mode
		# We'll rely on perform_attack's range check to drop it if they get away
		current_state = State.ATTACK
		return

	var potential_blocked = false
	var overlapping = attack_detection.get_overlapping_bodies()
	
	# Pass 1: Look for Player or Wall (High Priority)
	for body in overlapping:
		if body == self: continue
		if body.name == "Knight" or body.is_in_group("wall") or body.get_collision_layer_value(3):
			target_to_attack = body
			current_state = State.ATTACK
			return
		
		if body.is_in_group("enemies"):
			potential_blocked = true

	# Pass 2: Check Raycast for line-of-sight targets
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if is_instance_valid(collider) and collider != self:
			if collider.name == "Knight" or collider.is_in_group("wall") or collider.get_collision_layer_value(3):
				target_to_attack = collider
				current_state = State.ATTACK
				return
			if collider.is_in_group("enemies"):
				potential_blocked = true

	# If no target found but we are blocked by an ally
	if potential_blocked:
		is_blocked = true
		return

	# If nothing detected, make sure we are walking
	if current_state == State.ATTACK:
		current_state = State.WALK

func perform_attack():
	# If target is gone or dead, look for a new one or walk
	if not is_instance_valid(target_to_attack):
		target_to_attack = null
		current_state = State.WALK
		return

	# Check if target is still in range (use a slightly larger buffer)
	var in_range = false
	for body in attack_detection.get_overlapping_bodies():
		if body == target_to_attack:
			in_range = true
			break
	
	if not in_range:
		# Check raycast as fallback for range
		if ray_cast.is_colliding() and ray_cast.get_collider() == target_to_attack:
			in_range = true
			
	# Deal damage
	if target_to_attack.has_method("take_damage"):
		target_to_attack.take_damage(damage)
		time_since_last_attack = attack_cooldown
		
		# Check if target is killed immediately
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
	
	if animated_sprite.sprite_frames.has_animation("die"):
		animated_sprite.play("die")
		await animated_sprite.animation_finished
	
	queue_free()
