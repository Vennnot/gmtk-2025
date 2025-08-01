class_name InfinityLoop
extends Line2D

const BEAT_SPRITE := preload("res://scenes/UI/track_visuals/beat_sprite.tscn")


@onready var center_area: Area2D = %CenterArea
@onready var timer: Timer = %Timer

@export var bpm: float = 111
@export var number_of_beats: float = 4

var beat_sprite: Sprite2D
var sprite_in_middle : bool = false

var progress: float = 0.0
var segment_lengths: Array[float] = []
var total_length: float = 0.0

func _ready():
	center_area.area_entered.connect(_on_area_entered)
	center_area.area_exited.connect(_on_area_exited)
	
	calculate_lengths()
	timer.wait_time = (60/bpm) * number_of_beats
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	spawn_beat_sprite()


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

func _on_timer_timeout():
	spawn_beat_sprite()


func spawn_beat_sprite():
	var sprite = BEAT_SPRITE.instantiate()
	add_child(sprite)

	var travel_time = (60.0 / bpm) * number_of_beats

	# Movement
	var tween := create_tween()
	tween.tween_method(
		func(t): sprite.position = get_point_on_line(t),
		0.0, 1.0, travel_time
	).set_trans(Tween.TRANS_LINEAR)

	tween.tween_callback(Callable(sprite, "queue_free"))

	# Scaling
	sprite.scale = Vector2.ZERO
	animate_sprite_scale(sprite, travel_time, 0.3)  # adjust peak scale here


func animate_sprite_scale(sprite: Node2D, travel_time: float, peak_scale: float = 1.5):
	var scale_tween := create_tween()
	
	scale_tween.tween_method(
		func(t):
			if t <= 0.2:
				var s = (t / 0.2) * peak_scale
				sprite.scale = Vector2(s, s)  # 0 → peak
			elif t <= 0.5:
				var interp = lerp(peak_scale, peak_scale * 1.5, (t - 0.2) / 0.3)
				sprite.scale = Vector2(interp, interp)
			elif t <= 0.8:
				var interp = lerp(peak_scale * 1.5, peak_scale, (t - 0.5) / 0.3)
				sprite.scale = Vector2(interp, interp)
			else:
				var s = lerp(peak_scale, 0.0, (t - 0.8) / 0.2)
				sprite.scale = Vector2(s, s)
	,
	0.0, 1.0, travel_time).set_trans(Tween.TRANS_LINEAR)
