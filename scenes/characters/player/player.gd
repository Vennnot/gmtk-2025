class_name Player
extends CharacterBody2D

@export var maximum_velocity := 600.0
var current_maximum_velocity := 600.0
@export var acceleration := 350.0
@export var deceleration := 1050.0 # When player switches input direction
@export var jump_force := 30000.0
@export var gravity_force := 2500.0
var current_gravity_force := 2500.0

@onready var jump_timer = %"Jump Timer"
var jumping := false

var player_movement_direction : float = 0.0

@onready var anim_tree := %AnimationTree
@onready var player_anim_sprite := %AnimatedSprite2D


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
	velocity.x = clampf(velocity.x, -maximum_velocity, maximum_velocity)
	
	#If player is slow, stop them
	if velocity.x <= 200.0 and player_movement_direction == 0:
		if velocity.x >= -200.0:
			velocity.x = move_toward(velocity.x, 0, _delta * deceleration)
	
	#Handle Jump
	handle_jumping()
	if jumping:
			velocity.y = -jump_force * _delta
	
	move_and_slide()

func _on_jump_timer_timeout() -> void:
	jumping = false

func handle_jumping():
	if Input.is_action_just_pressed("jump"):
		jump_timer.start()
		jumping = true
	if Input.is_action_just_released("jump"):
		jumping = false

func handle_animations():
	if player_movement_direction < 0.0:
		player_anim_sprite.flip_h = true
	if player_movement_direction > 0.0:
		player_anim_sprite.flip_h = false
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
