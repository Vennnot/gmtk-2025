@tool
class_name Collectable
extends Node2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var area: Area2D = %Area2D

@export var collectable_type : String = "time"
@export var tape: Global.TAPE :
	set(value):
		tape = value
		update_visuals()

func _ready() -> void:
	Global.tape_changed.connect(_on_tape_changed)
	area.body_entered.connect(_on_body_entered)
	_on_tape_changed()
	update_visuals()

func update_visuals():
	modulate = Global.get_tape_color(tape)

func _on_tape_changed():
	if Global.current_tape_index == tape:
		modulate.a = 1
		area.monitoring = true
	else:
		modulate.a = 0.1
		area.monitoring = false

func _on_body_entered(body:Node2D):
	if body is Player:
		EventBus.collectable_collected.emit(collectable_type)
		queue_free()
