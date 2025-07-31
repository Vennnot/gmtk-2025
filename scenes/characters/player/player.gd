class_name Player
extends CharacterBody2D

@export var maximum_velocity := 600.0
var current_maximum_velocity := 600.0
@export var acceleration := 350.0
@export var deceleration := 1050.0
@export var deceleration_point := 200.0
@export var jump_force := 30000.0
@export var gravity_force := 2500.0
var current_gravity_force := 2500.0

@onready var jump_timer := %"Jump Timer"
var jumping := false
var can_jump := false
@onready var coyote_timer := $"Coyote Timer"
@export var coyote_time := 0.1

@onready var collision_check = $CollisionCheck

var player_movement_direction := 0.0
var player_facing_direction := 1.0

@onready var anim_tree := %AnimationTree
@onready var player_anim_sprite := %AnimatedSprite2D

@onready var regular_collision := $"Regular Collision"
@onready var croutch_collision := $"Croutch Collision"

func _ready() -> void:
	coyote_timer.wait_time = coyote_time

func reset_gravity():
	current_gravity_force = gravity_force

func reset_max_velocity():
	current_maximum_velocity = maximum_velocity

func _physics_process(delta: float) -> void:
	control_movement(delta)
	handle_animations()

func control_movement(_delta):
	#print("Dir: " + str(player_movement_direction) + " Velocity: " + str(velocity)) # Collect Player dir and velocity data
	
	player_movement_direction = Input.get_axis("left", "right")
	
	# Handle Gravity
	velocity.y += current_gravity_force * _delta
	
	#Handle x movement
	velocity.x += player_movement_direction * acceleration * _delta
	if velocity.x < 0 and player_movement_direction > 0:
		velocity.x += player_movement_direction * deceleration * _delta
	if velocity.x > 0 and player_movement_direction < 0:
		velocity.x += player_movement_direction * deceleration * _delta
	
	#Clamp maximum player x velocity
	if abs(velocity.x) > current_maximum_velocity:
		velocity.x = move_toward(velocity.x, player_facing_direction * current_maximum_velocity, deceleration * _delta)
	
	#If player is slow, stop them
	if abs(velocity.x) <= deceleration_point and player_movement_direction == 0:
		velocity.x = move_toward(velocity.x, 0, _delta * deceleration)
	
	#Handle Jump
	handle_jumping()
	if can_jump or !coyote_timer.is_stopped():
		if jumping:
			velocity.y = -jump_force * _delta
	
	#Handle Player Collisions
	handle_collisions()
	
	#Handle Railing
	handle_railing()
	
	move_and_slide()

func _on_jump_timer_timeout() -> void:
	jumping = false

func handle_jumping():
	var was_on_floor = is_on_floor()
	if was_on_floor and !is_on_floor():
		coyote_timer.start()
	if is_on_floor():
		can_jump = true
	if Input.is_action_just_pressed("jump") and can_jump:
		jump_timer.start()
		jumping = true
	if Input.is_action_just_released("jump"):
		jumping = false
		can_jump = false
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
	if velocity.x != 0.0:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/running"] = true
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
