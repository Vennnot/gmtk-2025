extends CharacterBody2D

@export var speed := 100.0
@export var maximum_velocity := 500.0
@export var acceleration := 100.0
@export var deceleration := 100.0 # When player switches input direction
@export var jump_force := 2000.0
@export var gravity_force := 100.0

@onready var jump_timer = $"Jump Timer"
var jumping = false

var player_movement_direction : float = 0.0

func _physics_process(delta: float) -> void:
	control_movement(delta)
	apply_gravity(delta)
	

func apply_gravity(_delta):
	pass

func control_movement(_delta):
	player_movement_direction = Input.get_axis("left", "right")
	
	velocity.y += gravity_force * _delta
	print(velocity)
	#Handle left and right movement
	velocity.x += player_movement_direction * acceleration * _delta
	if velocity.x < 0 and player_movement_direction > 0:
		velocity.x += player_movement_direction * deceleration * _delta
	if velocity.x > 0 and player_movement_direction < 0:
		velocity.x += player_movement_direction * deceleration * _delta
	
	# Clamp maximum player velocity
	velocity.x = clampf(velocity.x, -maximum_velocity, maximum_velocity)
	
	# If player is slow, stop them
	if (velocity.x <= 5.0 or velocity.x >= -5.0) and player_movement_direction == 0:
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
