extends CharacterBody2D

enum State { IDLE, WALK, RUN, ATTACK, KNOCKBACK, DIE }

@export var speed: float = 200.0
@export var run_speed_multiplier: float = 1.6
@export var mounted_speed_multiplier: float = 1.0 # Will be updated by horse level

var current_state: State = State.IDLE
var is_mounted: bool = false
var last_direction: float = 1.0

@onready var animated_sprite = $AnimatedSprite2D
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

func _ready():
	current_health = max_health
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

func _physics_process(delta):
	if current_state == State.DIE or current_state == State.KNOCKBACK:
		return

	handle_input()
	move_and_slide()
	update_animations()
	
	# Update Attack Area direction
	if last_direction != 0:
		attack_area.scale.x = 1 if last_direction > 0 else -1

func handle_input():
	var direction = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("attack"):
		enter_state(State.ATTACK)
		perform_attack()
		return

	if direction != 0:
		velocity.x = direction * get_actual_speed()
		last_direction = direction
		enter_state(State.WALK)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		enter_state(State.IDLE)

func perform_attack():
	# Simple melee attack: hit all enemies in range immediately
	# In a polished game, this would be timed with the animation frame
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(base_damage, knockback)

func get_actual_speed() -> float:
	var base = speed
	if Input.is_action_pressed("run"): # Assuming run action exists
		base *= run_speed_multiplier
	if is_mounted:
		base *= mounted_speed_multiplier
	return base

func enter_state(new_state: State):
	if current_state == new_state:
		return
		
	# Prevent moving during attack (unless we want move-attacks later)
	if current_state == State.ATTACK and new_state != State.IDLE:
		# Could add a cooldown or animation finish check here
		pass

	current_state = new_state
	
	if new_state == State.ATTACK:
		# Use a timer to return to IDLE for now since we don't have animation signals yet
		if get_tree():
			get_tree().create_timer(0.3).timeout.connect(func(): current_state = State.IDLE)

func update_animations():
	if last_direction != 0:
		animated_sprite.flip_h = last_direction < 0
	
	match current_state:
		State.IDLE:
			animated_sprite.play("idle" if not is_mounted else "idle_mounted")
		State.WALK:
			animated_sprite.play("walk" if not is_mounted else "walk_mounted")
		State.ATTACK:
			animated_sprite.play("attack" if not is_mounted else "attack_mounted")
