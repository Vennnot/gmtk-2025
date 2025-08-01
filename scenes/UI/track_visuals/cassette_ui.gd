class_name CassetteUI
extends Node2D

@onready var visuals: Node2D = %Visuals
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var cassette_white: Sprite2D = %CassetteWhite

func _ready() -> void:
	Global.tape_changed.connect(_on_tape_changed)


func _on_tape_changed():
	animation_player.play("change_tape")
	cassette_white.self_modulate = Global.get_tape_color()
