class_name InfinityLoop
extends Line2D

@onready var beat_sprite: Sprite2D = %BeatSprite
@onready var center_area: Area2D = %CenterArea

@export var speed: float = 1.0

var sprite_in_middle : bool = false

var progress: float = 0.0
var segment_lengths: Array[float] = []
var total_length: float = 0.0

func _ready():
	calculate_lengths()
	center_area.area_entered.connect(_on_area_entered)
	center_area.area_exited.connect(_on_area_exited)


func _on_area_entered(area:Area2D):
	sprite_in_middle = true


func _on_area_exited(area:Area2D):
	sprite_in_middle = false


func calculate_lengths():
	segment_lengths.clear()
	total_length = 0.0
	
	for i in range(get_point_count() - 1):
		var length = points[i].distance_to(points[i + 1])
		segment_lengths.append(length)
		total_length += length

func _process(delta):
	progress += delta * speed
	if progress > 1.0:
		progress = 0.0
	
	beat_sprite.position = get_point_on_line(progress)

func get_point_on_line(t: float) -> Vector2:
	if get_point_count() < 2:
		return Vector2.ZERO
	
	var target_distance = t * total_length
	var current_distance = 0.0
	
	for i in range(segment_lengths.size()):
		if current_distance + segment_lengths[i] >= target_distance:
			var local_t = (target_distance - current_distance) / segment_lengths[i]
			return points[i].lerp(points[i + 1], local_t)
		current_distance += segment_lengths[i]
	
	return points[-1]
