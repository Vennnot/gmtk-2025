@tool
class_name Block
extends StaticBody2D

@export var tape: Global.TAPE :
	set(value):
		tape = value
		update_visuals()

func _ready() -> void:
	Global.tape_changed.connect(_on_tape_changed)
	_on_tape_changed()
	update_visuals()

func _on_tape_changed():
	if Global.current_tape_index == tape:
		mesh_instance.self_modulate.a = 0.1
		collision_shape.disabled = true
	else:
		mesh_instance.self_modulate.a = 1
		collision_shape.disabled = false


@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var mesh_instance: MeshInstance2D = %MeshInstance2D

func update_visuals() -> void:
	modulate = Global.get_tape_color(tape)
