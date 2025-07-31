extends Area2D

var pull_speed := 50.0
var can_pull := false
var player : Player

func _physics_process(delta: float) -> void:
	if can_pull:
		if player != null:
			player.position = player.position.move_toward(position, pull_speed * delta)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().call_deferred("reload_current_scene") 


func _on_magnet_pull_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_pull = true
		player = body

func _on_magnet_pull_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_pull = false
