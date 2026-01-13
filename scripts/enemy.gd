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

func _ready():
	current_health = max_health

func _physics_process(delta):
	if current_state == State.DIE:
		return

	match current_state:
		State.WALK:
			move_forward(delta)
		State.ATTACK:
			# Attack logic will be triggered by collision/area
			pass
		State.KNOCKBACK:
			# Knockback physics
			pass

	move_and_slide()

func move_forward(delta):
	# Enemies move vertically down (positive Y)
	velocity.y = speed
	velocity.x = 0

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
	# Reset state after short duration (would normally use a Timer or Tween)
	await get_tree().create_timer(0.2).timeout
	if current_state != State.DIE:
		current_state = State.WALK

func die():
	current_state = State.DIE
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	emit_signal("died", self)
	# Play animation then free
	# await animated_sprite.animation_finished
	queue_free()
