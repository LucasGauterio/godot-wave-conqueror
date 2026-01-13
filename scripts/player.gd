extends CharacterBody2D

enum State { IDLE, WALK, RUN, ATTACK, KNOCKBACK, DIE }

@export var speed: float = 350.0
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
var attack_range_lanes: float = 1.0 # 1 lane = ~64px usually, but scaling the area

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
	update_animations()
	update_attack_direction()

func check_auto_attack():
	if time_since_last_attack <= 0 and current_state != State.ATTACK:
		var bodies = attack_area.get_overlapping_bodies()
		# if bodies.size() > 0:
		# 	print("[DEBUG] Knight sees ", bodies.size(), " bodies in attack area")
		for body in bodies:
			if body != self and (body.is_in_group("enemies") or body.has_method("take_damage")):
				# print("[DEBUG] Knight attacking: ", body.name)
				enter_state(State.ATTACK)
				perform_attack()
				break

func update_attack_direction():
	# If we have movement, update attack area position/rotation
	if velocity != Vector2.ZERO:
		attack_area.rotation = velocity.angle()
	
	attack_area.scale = Vector2(attack_range_lanes, 1.0)

func handle_input():
	if Input.is_action_just_pressed("attack") and time_since_last_attack <= 0:
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
	var bodies = attack_area.get_overlapping_bodies()
	var hit = false
	for body in bodies:
		if body.has_method("take_damage") and body != self:
			body.take_damage(base_damage, knockback)
			hit = true
	
	# Always start cooldown to prevent infinite animation loop
	time_since_last_attack = attack_cooldown

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
	var anim = "idle"
	
	if last_direction != 0:
		animated_sprite.flip_h = last_direction < 0
	
	match current_state:
		State.IDLE:
			anim = "idle"
		State.WALK:
			anim = "walk"
		State.ATTACK:
			anim = "attack"
	
	if is_mounted:
		anim += "_mounted"
		
	# Safety check
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim):
		animated_sprite.play(anim)
