extends Area2D

@export var next_scene : PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.player_controllable = false
		%RectAnimator.play("FadeInRect")
		await get_tree().create_timer(2.0).timeout
		SceneChanger.change_scene(next_scene)
