extends Node2D

var timer = 0.0;
@export var time_until_destroy = 0.25;

func _process(delta):
	timer += delta;
	if timer >= time_until_destroy:
		queue_free();
