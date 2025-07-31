extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.current_maximum_velocity = 800.0
		body.velocity.x = body.current_maximum_velocity * body.player_facing_direction
		await get_tree().create_timer(3.0).timeout
		body.reset_max_velocity()
