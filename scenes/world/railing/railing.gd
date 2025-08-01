extends Line2D
class_name Railing

const RAILING_AREA := preload("res://scenes/world/railing/railing_area.tscn")

@export var tape: Global.TAPE :
	set(value):
		tape = value
		#update_visuals()

func _ready() -> void:
	Global.tape_changed.connect(_on_tape_changed)
	_on_tape_changed()
	update_visuals()
	update_areas()

func update_areas():
	for i in points.size()-1:
		var new_area : RailingArea = RAILING_AREA.instantiate()
		add_child(new_area)
		var shape := SegmentShape2D.new()
		new_area.collision_shape.shape = shape
		shape.a = points[i]
		shape.b = points[i+1]

func get_point_on_line(t: float) -> Vector2:
	var segment_lengths := []
	var total_length := 0.0
	
	for i in range(points.size() - 1):
		var length := points[i].distance_to(points[i + 1])
		segment_lengths.append(length)
		total_length += length
	
	var target_distance := t * total_length
	var current_distance := 0.0
	
	for i in range(segment_lengths.size()):
		var seg_len :float= segment_lengths[i]
		if current_distance + seg_len >= target_distance:
			var local_t :float= (target_distance - current_distance) / seg_len
			return points[i].lerp(points[i + 1], local_t)
		current_distance += seg_len
	
	return points[-1]


func update_visuals():
	modulate = Global.get_tape_color(tape)

func _on_tape_changed():
	if Global.current_tape_index == tape:
		modulate.a = 1
		for area in get_children():
			area.monitorable = true
	else:
		modulate.a = 0.2
		for area in get_children():
			area.monitorable = false
