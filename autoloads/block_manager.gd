extends Node

@onready var blue_blocks := get_tree().get_nodes_in_group("Blue Block")
@onready var red_blocks := get_tree().get_nodes_in_group("Red Block")
@onready var purple_blocks := get_tree().get_nodes_in_group("Purple Block")

var cassette := "None"
var player : CharacterBody2D = null

func _ready() -> void:
	if get_tree().get_first_node_in_group("Player") != null:
		player = get_tree().get_first_node_in_group("Player")
		player.connect("cassette_changed", change_colors)

func change_colors():
	match cassette:
		"blue":
			for i in red_blocks:
				i.get_child(1).disabled = true
				i.get_child(0).modulate = Color(Color.RED, 10)
			for i in purple_blocks:
				i.get_child(1).disabled = true
				i.get_child(0).modulate = Color(Color.PURPLE, 10)
			for i in blue_blocks:
				i.get_child(1).disabled = false
				i.get_child(0).modulate = Color(Color.BLUE, 255)
		"red":
			for i in red_blocks:
				i.get_child(1).disabled = false
				i.get_child(0).modulate = Color(Color.RED, 255)
			for i in purple_blocks:
				i.get_child(1).disabled = true
				i.get_child(0).modulate = Color(Color.PURPLE, 10)
			for i in blue_blocks:
				i.get_child(1).disabled = true
				i.get_child(0).modulate = Color(Color.BLUE, 10)
		"purple":
			for i in red_blocks:
				i.get_child(1).disabled = true
				i.get_child(0).modulate = Color(Color.RED, 10)
			for i in purple_blocks:
				i.get_child(1).disabled = false
				i.get_child(0).modulate = Color(Color.PURPLE, 255)
			for i in blue_blocks:
				i.get_child(1).disabled = true
				i.get_child(0).modulate = Color(Color.BLUE, 10)
