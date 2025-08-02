extends Area2D

var can_start_dialogue := false
var target_player_position : float
@onready var player := get_tree().get_first_node_in_group("Player")
@export var dialogue_manager : Node

func _ready() -> void:
	target_player_position = 100.0 + global_position.x

func _input(event: InputEvent) -> void:
	if can_start_dialogue and event.is_action_pressed("dialogue"):
		Global.player_controllable = false
		player.no_control_target = target_player_position
		dialogue_manager.start("dialogue")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_start_dialogue = true
