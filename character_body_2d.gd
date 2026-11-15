
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

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

var hook_jump_speed = 700.0
var hook_visual_duration = 0.12
var hook_length = 250.0

@onready var hook_line: Line2D = $Hook
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	# Animations
	if (velocity.x >1 || velocity.x < -1):
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "forward"
		
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
	
	if Input.is_action_just_pressed("web") and is_valid_hook_target():
		hook_jump()

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
	
	var isleft = velocity.x < 0
	sprite_2d.flip_h = isleft


func hook_jump() -> void:
	var direction :=( 
		get_global_mouse_position() - global_position 
	  ).normalized()
	
	if direction == Vector2.ZERO: return
	
	hook_line.points = PackedVector2Array([ 
		Vector2.ZERO, 
		to_local(global_position+ direction * hook_length)
	])
	hook_line.show()
	
	velocity= direction * hook_jump_speed
	
	await get_tree().create_timer(hook_visual_duration).timeout
	hook_line.hide()


func is_valid_hook_target() -> bool:
	var ground: TileMapLayer = get_tree().current_scene.get_node("TileMapLayer")
	var tile_pos = ground.local_to_map(ground.to_local(get_global_mouse_position()))
	
	if ground.get_cell_source_id(tile_pos) == -1:
		return false
	
	var tile_data = ground.get_cell_tile_data(tile_pos)
	
	if tile_data == null:
		return false
	
	for i in range(ground.tile_set.get_physics_layers_count()):
		if not tile_data.get_collision_polygons_count(i) == 0:
			return true
	
	return false
