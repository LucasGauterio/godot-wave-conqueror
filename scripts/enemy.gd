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

func _ready():
	current_health = max_health

func _physics_process(delta):
	if current_state == State.DIE:
		return

	if time_since_last_attack > 0:
		time_since_last_attack -= delta

	match current_state:
		State.WALK:
			move_forward(delta)
		State.ATTACK:
			velocity = Vector2.ZERO # Stop moving while attacking
			if time_since_last_attack <= 0:
				perform_attack()
		State.KNOCKBACK:
			pass

	move_and_slide()
	
	# Check for collisions after moving
	if current_state == State.WALK:
		check_collisions()
	
	update_animations()

func update_animations():
	# Simple state-to-animation mapping
	var anim_name = "walk"
	
	match current_state:
		State.WALK:
			anim_name = "walk"
		State.ATTACK:
			anim_name = "attack"
		State.DIE:
			anim_name = "die"
	
	if animated_sprite.sprite_frames.has_animation(anim_name):
		# Only change if different to avoid restarting loop unless needed
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)

func move_forward(delta):
	# Enemies move vertically down (positive Y)
	velocity.y = speed
	velocity.x = 0

func check_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if we hit the Player or the Wall
		if collider and (collider.name == "Knight" or collider.is_in_group("wall")):
			current_state = State.ATTACK
			break

func perform_attack():
	# Deal damage to the target in front
	# Since we are in ATTACK state, we assume we are touching the target
	# We can re-verify collision or use a raycast suitable for grid logic
	# For now, simple verification:
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
			time_since_last_attack = attack_cooldown
			# Optional: Play attack animation here
			return
	
	# If no valid target found (e.g. player moved away), return to walk
	current_state = State.WALK

func take_damage(amount: int, knockback_force: float = 0.0):
	current_health -= amount
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
