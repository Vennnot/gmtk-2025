class_name PlayerCamera
extends Camera2D

@export var player : CharacterBody2D
@export var follow_speed_x := 300.0
@export var follow_speed_y := 200.0

func _physics_process(delta: float) -> void:
	#Moving camera towards player's position
	position.x = move_toward(position.x, player.position.x, follow_speed_x * delta)
	position.y = move_toward(position.y, player.position.y, follow_speed_y * delta)
