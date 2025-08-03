class_name Player
extends CharacterBody2D


@export_category("Powerups")
@export var jump_boost : float = 500
@export var speed_boost : float = 500

@onready var main = get_node("/root/").get_child(6)
@export_category("Movement Values")
@export var maximum_velocity := 600.0
var current_maximum_velocity := 300.0
@export var acceleration := 350.0
@export var deceleration := 1050.0
@export var deceleration_point := 600.0
@export var jump_force := 30000.0
@export var gravity_force := 2500.0
var current_gravity_force := 2500.0

@onready var jump_timer := %"Jump Timer"
var jumping := false
var can_jump := false
@onready var coyote_timer := $"Coyote Timer"
@export var coyote_time := 0.1

var can_switch_tape = true
@onready var tape_switch_timer = %TapeActionTimer
@export var tape_switch_cooldown : float = 1.0

var no_control_target : float

@onready var tape_particple := %TapeParticles

@onready var collision_check = $CollisionCheck

var player_movement_direction := 0.0
var player_facing_direction := 1.0

@onready var anim_tree := %AnimationTree
@onready var anim_player := %AnimationPlayer
@onready var player_anim_sprite := $AnimatedSprite2D

@onready var regular_collision := $"Regular Collision"
@onready var croutch_collision := $"Croutch Collision"
@onready var railing_area: Area2D = %RailingArea

var dead : bool =false
var railing : Railing : 
	set(value):
		railing = value
		if railing:
			AudioManager.is_on_rail = true
		else:
			AudioManager.is_on_rail = false
var railing_progress := 0.0
var railing_momentum := 0.0
var railing_direction := 1.0

func _ready() -> void:
	railing_area.area_entered.connect(_on_area_entered)
	coyote_timer.wait_time = coyote_time
	tape_switch_timer.wait_time = tape_switch_cooldown
	reset_max_velocity()
	


func use_jump_powerup():
	velocity.y = -jump_boost


func use_speed_powerup():
	velocity.x += speed_boost*player_facing_direction

func reset_gravity():
	current_gravity_force = gravity_force

func reset_max_velocity():
	current_maximum_velocity = maximum_velocity

func _physics_process(delta: float) -> void:
	if !Global.player_upside_down:
		handle_animations()
	else: handle_upsidedown_animations()

	
	if dead:
		return
	if !Global.player_controllable:
		global_position.x = move_toward(global_position.x, no_control_target, 500 * delta)
		return
	
	if !Global.player_upside_down:
		control_movement(delta)
		#print("B")
	if Global.player_upside_down: 
		upsidedown_control_movement(delta) 
		#print("C")

	move_and_slide()

func control_movement(_delta):
	#print("Dir: " + str(player_movement_direction) + " Velocity: " + str(velocity)) # Collect Player dir and velocity data
	
	player_movement_direction = Input.get_axis("left", "right")
	
	
	#Handle x movement
	velocity.x += player_movement_direction * acceleration * _delta
	if velocity.x < 0 and player_movement_direction > 0:
		velocity.x += player_movement_direction * deceleration * _delta
	if velocity.x > 0 and player_movement_direction < 0:
		velocity.x += player_movement_direction * deceleration * _delta
	
	#Clamp maximum player x velocity
	if abs(velocity.x) > current_maximum_velocity:
		velocity.x = move_toward(velocity.x, player_facing_direction * current_maximum_velocity, deceleration * _delta)
	
	
	#Handle Jump
	handle_jumping()
	
	if is_colliding_with_rails():
		move_along_railing(_delta)
		return
	
	# Natural Friction
	# Friction if facing opposite way of velocity
	if abs(velocity.x) <= deceleration_point and player_movement_direction == 0:
		velocity.x = move_toward(velocity.x, 0, _delta * deceleration)
	if (player_facing_direction < 0.0 and velocity.x > 0.0) or (player_facing_direction > 0.0 and velocity.x < 0.0):
		velocity.x = move_toward(velocity.x, 0, _delta * deceleration/2)
	
	if can_jump or !coyote_timer.is_stopped():
		if jumping:
			velocity.y = -jump_force * _delta
	
	# Handle Gravity
	velocity.y += current_gravity_force * _delta
	
	
	#Handle Player Collisions
	handle_collisions()
	
	#Handle Railing
	handle_railing()


func upsidedown_control_movement(_delta):
	#print("Dir: " + str(player_movement_direction) + " Velocity: " + str(velocity)) # Collect Player dir and velocity data
	
	player_movement_direction = Input.get_axis("left", "right")
	
	
	#Handle x movement
	velocity.x += player_movement_direction * acceleration * _delta
	if velocity.x < 0 and player_movement_direction > 0:
		velocity.x += player_movement_direction * deceleration * _delta
	if velocity.x > 0 and player_movement_direction < 0:
		velocity.x += player_movement_direction * deceleration * _delta
	
	#Clamp maximum player x velocity
	if abs(velocity.x) > current_maximum_velocity:
		velocity.x = move_toward(velocity.x, player_facing_direction * current_maximum_velocity, deceleration * _delta)
	
	
	#Handle Jump
	handle_upsidedown_jumping()
	
	if is_colliding_with_rails():
		move_along_railing(_delta)
		return
	
	# If player is slow stop them
	if abs(velocity.x) <= deceleration_point and player_movement_direction == 0:
		velocity.x = move_toward(velocity.x, 0, _delta * deceleration)
	if (player_facing_direction < 0.0 and velocity.x > 0.0) or (player_facing_direction > 0.0 and velocity.x < 0.0):
		velocity.x = move_toward(velocity.x, 0, _delta * deceleration/2)
	
	if can_jump or !coyote_timer.is_stopped():
		if jumping:
			velocity.y = jump_force * _delta
	
	# Handle Gravity
	velocity.y -= current_gravity_force * _delta
	
	
	#Handle Player Collisions
	handle_collisions()
	
	#Handle Railing
	handle_railing()
	
	move_and_slide()

func move_along_railing(delta):
	if not is_colliding_with_rails() or not railing:
		return
	
	# If this is the first frame on the railing, calculate starting position and momentum
	if railing_progress == 0.0:
		railing_progress = calculate_starting_progress()
		# Store the momentum and direction from when we landed on the railing
		railing_momentum = abs(velocity.x) if abs(velocity.x) > 50.0 else 100.0
		# Determine initial direction based on velocity or default to right
		railing_direction = 1.0 if velocity.x >= 0 else -1.0
	
	var current_speed: float
	var movement_dir: float

	# Use player input to modify momentum and direction, or maintain current momentum
	if player_movement_direction != 0:
		# Check if player is trying to reverse direction - if so, fall off
		if player_movement_direction != railing_direction and railing_direction != 0:
			reset_railing()
			return
		
		# Player is actively moving - use their input speed and direction
		current_speed = max(abs(velocity.x), 50.0)
		movement_dir = player_movement_direction
		railing_direction = player_movement_direction  # Update stored direction
	else:
		railing_momentum = max(railing_momentum, 50.0)  # Minimum sliding speed
		current_speed = railing_momentum
		movement_dir = railing_direction  # Use stored direction
	
	# Calculate progress increment
	var progress_increment = (current_speed / get_total_length(railing)) * delta * movement_dir
	railing_progress += progress_increment
	
	# Check bounds and reset if needed
	if railing_progress >= 0.99 or railing_progress <= 0.05:
		reset_railing()
		return
	
	var pos := get_point_on_line(railing, railing_progress, movement_dir)
	var next_progress = railing_progress + 0.01 * movement_dir
	next_progress = clamp(next_progress, 0.0, 1.0)  # Ensure next_progress is within bounds
	var next_pos := get_point_on_line(railing, next_progress, movement_dir)
	
	global_position = railing.to_global(pos)
	
	# Calculate rotation based on movement direction
	var direction_vector = railing.to_global(next_pos) - railing.to_global(pos)
	if movement_dir < 0:
		# When moving left, flip the direction vector
		direction_vector = -direction_vector
	rotation = direction_vector.angle()

func calculate_starting_progress() -> float:
	if not railing:
		return 0.0
	
	var global_points := []
	for p in railing.points:
		global_points.append(railing.to_global(p))
	
	var player_pos := global_position
	var closest_progress := 0.0
	var min_distance := INF
	var total_length := 0.0
	var current_length := 0.0
	var segment_lengths := []
	
	# Calculate segment lengths
	for i in range(global_points.size() - 1):
		var seg_len = global_points[i].distance_to(global_points[i + 1])
		segment_lengths.append(seg_len)
		total_length += seg_len
	
	# Find closest point on the line
	for i in range(global_points.size() - 1):
		var a = global_points[i]
		var b = global_points[i + 1]
		var segment = b - a
		var seg_len = segment_lengths[i]
		
		if seg_len == 0:
			continue
			
		var t = clamp((player_pos - a).dot(segment) / segment.length_squared(), 0.0, 1.0)
		var projected = a + segment * t
		var dist = projected.distance_to(player_pos)
		
		if dist < min_distance:
			min_distance = dist
			closest_progress = current_length + seg_len * t
		
		current_length += seg_len
	
	if total_length == 0:
		return 0.0
	
	return closest_progress / total_length

func get_total_length(line: Line2D) -> float:
	var length := 0.0
	for i in range(line.points.size() - 1):
		length += line.points[i].distance_to(line.points[i + 1])
	return length

func get_point_on_line(line: Line2D, t: float, movement_direction: float) -> Vector2:
	var points = line.points
	if points.size() < 2:
		return Vector2.ZERO
	
	var segment_lengths = []
	var total_length := 0.0
	for i in range(points.size() - 1):
		var length := points[i].distance_to(points[i + 1])
		segment_lengths.append(length)
		total_length += length
	
	if total_length == 0:
		return points[0]
	
	var clamped_t = clamp(t, 0.0, 1.0)
	var target_distance = clamped_t * total_length
	var current_distance := 0.0
	
	# Always traverse in the natural order of points
	for i in range(segment_lengths.size()):
		var seg_len = segment_lengths[i]
		if current_distance + seg_len >= target_distance:
			var local_t = (target_distance - current_distance) / seg_len
			return points[i].lerp(points[i + 1], local_t)
		current_distance += seg_len
	
	return points[-1]

func reset_railing():
	rotation = 0
	railing = null
	railing_progress = 0
	railing_momentum = 0.0
	railing_direction = 1.0
	velocity.y = 0

func _on_jump_timer_timeout() -> void:
	jumping = false

func handle_jumping():
	var was_on_floor = is_on_floor()
	if was_on_floor and !is_on_floor():
		coyote_timer.start()
	if is_on_floor() or is_colliding_with_rails():
		if not can_jump:
			AudioManager.play(AudioManager.land)
			can_jump = true
	if Input.is_action_just_pressed("jump") and can_jump:
		if is_colliding_with_rails():
			reset_railing()
		jump_timer.start()
		AudioManager.play(AudioManager.jump)
		jumping = true
	if Input.is_action_just_released("jump"):
		jumping = false
		can_jump = false

func handle_upsidedown_jumping():
	var was_on_floor = is_on_ceiling()
	if was_on_floor and !is_on_ceiling():
		coyote_timer.start()
	if is_on_ceiling() or is_colliding_with_rails():
		if not can_jump:
			AudioManager.play(AudioManager.land)
			can_jump = true
	if Input.is_action_just_pressed("jump") and can_jump:
		if is_colliding_with_rails():
			reset_railing()
		jump_timer.start()
		jumping = true
		AudioManager.play(AudioManager.jump)
	if Input.is_action_just_released("jump"):
		jumping = false
		can_jump = false

func handle_animations():
	if player_movement_direction < 0.0:
		player_anim_sprite.flip_h = true
		player_facing_direction = -1.0
	if player_movement_direction > 0.0:
		player_anim_sprite.flip_h = false
		player_facing_direction = 1.0
	if player_movement_direction == 0.0 and velocity.x == 0.0:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/running"] = false
		anim_tree["parameters/conditions/skidding"] = false
		if Input.is_action_pressed("crouch"):
			anim_tree["parameters/conditions/crouching"] = true
			anim_tree["parameters/conditions/not crouching"] = false
		else:
			anim_tree["parameters/conditions/not crouching"] = true
			anim_tree["parameters/conditions/crouching"] = false
	if velocity.x != 0.0:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/running"] = true
		anim_tree["parameters/conditions/skidding"] = false
		if Input.is_action_pressed("crouch"):
			anim_tree["parameters/conditions/crouching"] = true
			anim_tree["parameters/conditions/not crouching"] = false
		else:
			anim_tree["parameters/conditions/not crouching"] = true
			anim_tree["parameters/conditions/crouching"] = false
	if (player_movement_direction < 0.0 and velocity.x > 0.0) or (player_movement_direction > 0.0 and velocity.x < 0.0):
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/running"] = false
		anim_tree["parameters/conditions/skidding"] = true
	if velocity.y < 0.0:
		anim_tree["parameters/conditions/jumping"] = true
		anim_tree["parameters/conditions/falling"] = false
		anim_tree["parameters/conditions/landed"] = false
	if velocity.y > 0.0:
		anim_tree["parameters/conditions/jumping"] = false
		anim_tree["parameters/conditions/falling"] = true
		anim_tree["parameters/conditions/landed"] = false
	if !jumping and is_on_floor():
		anim_tree["parameters/conditions/jumping"] = false
		anim_tree["parameters/conditions/falling"] = false
		anim_tree["parameters/conditions/landed"] = true

func handle_upsidedown_animations():
	player_anim_sprite.flip_v = true
	if player_movement_direction < 0.0:
		player_anim_sprite.flip_h = true
		player_facing_direction = -1.0
	if player_movement_direction > 0.0:
		player_anim_sprite.flip_h = false
		player_facing_direction = 1.0
	if player_movement_direction == 0.0 and velocity.x == 0.0:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/running"] = false
		anim_tree["parameters/conditions/skidding"] = false
	if velocity.x != 0.0:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/running"] = true
		anim_tree["parameters/conditions/skidding"] = false
	if (player_movement_direction < 0.0 and velocity.x > 0.0) or (player_movement_direction > 0.0 and velocity.x < 0.0):
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/running"] = false
		anim_tree["parameters/conditions/skidding"] = true
	if velocity.y > 0.0:
		anim_tree["parameters/conditions/jumping"] = true
		anim_tree["parameters/conditions/falling"] = false
		anim_tree["parameters/conditions/landed"] = false
	if velocity.y < 0.0:
		anim_tree["parameters/conditions/jumping"] = false
		anim_tree["parameters/conditions/falling"] = true
		anim_tree["parameters/conditions/landed"] = false
	if !jumping and is_on_ceiling():
		anim_tree["parameters/conditions/jumping"] = false
		anim_tree["parameters/conditions/falling"] = false
		anim_tree["parameters/conditions/landed"] = true

func handle_collisions():
	if Input.is_action_pressed("crouch"):
		regular_collision.disabled = true
		croutch_collision.disabled = false
	else:
		regular_collision.disabled = false
		croutch_collision.disabled = true

func handle_railing():
	if Input.is_action_just_pressed("down"):
		position.y += 1.0
	if collision_check.get_collider() != null:
		if collision_check.get_collider().collision_layer == 256:
			if abs(velocity.x) <= deceleration_point:
				position.y += 1.0
			else:
				pass

func _on_area_entered(area:Area2D):
	if area is not RailingArea:
		return
	
	if velocity.y < 0:
		return
	
	if not railing:
		railing_progress = calculate_starting_progress()
		railing = area.get_parent()

func is_colliding_with_rails()->bool:
	return railing != null

# and abs(velocity.x) >= maximum_velocity / 7

func _on_tape_action_timer_timeout() -> void:
	can_switch_tape = true

#func handle_walls(_delta):
	##Handle y movement
	#velocity = Vector2.ZERO
	#
	#if Input.is_action_just_pressed("jump"):
		#AudioManager.play(AudioManager.jump)
		#velocity.x += -player_facing_direction * _delta * jump_force
		#velocity.y += -jump_force * _delta
