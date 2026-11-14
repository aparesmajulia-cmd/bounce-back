extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -100.0

# Gravity Burst settings
const DASH_SPEED = 800.0
const DASH_DURATION = 0.18
const DASH_COOLDOWN = 0.7
const AIR_BOOST = -250.0

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = 1.0
var has_air_dashed = false

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Reset air dash when touching the floor
	if is_on_floor():
		has_air_dashed = false

	# Dash cooldown
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	# Get movement direction
	var direction := Input.get_axis("left", "right")

	# Normal jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dashing:
		velocity.y = JUMP_VELOCITY

	# Double jump
	if Input.is_action_just_pressed("double jump") and not is_on_floor() and not is_dashing:
		velocity.y = JUMP_VELOCITY

	# Gravity Burst dash
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0.0:
		if is_on_floor() or not has_air_dashed:
			is_dashing = true
			dash_timer = DASH_DURATION
			dash_cooldown_timer = DASH_COOLDOWN

			# Dash toward the movement direction
			if direction != 0:
				dash_direction = direction
			else:
				# Default to right if standing still
				dash_direction = 1.0

			velocity.x = dash_direction * DASH_SPEED

			# Air dash gives an upward boost
			if not is_on_floor():
				velocity.y = AIR_BOOST
				has_air_dashed = true

	# Dash movement
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0.0

		if dash_timer <= 0.0:
			is_dashing = false

	# Normal horizontal movement
	else:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
