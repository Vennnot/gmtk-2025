class_name BootSplash
extends Control

@export var fade_duration:float = 1.0
@export var stay_duration:float = 1.5
@export var interuptable:bool = true

@onready var background: ColorRect = %Background
@onready var boot_splash_image: TextureRect = %BootSplashImage


func _ready():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(boot_splash_image, "modulate:a", 1.0, fade_duration)\
	.from(0.0).finished.connect(_fade_out)


func _process(_delta):
	if interuptable and Input.is_action_just_pressed(&"ui_cancel"):
		SceneChanger.change_scene(null)
	
func _fade_out():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(boot_splash_image, "modulate:a", 0.0, fade_duration)\
	.set_delay(stay_duration).finished.connect(SceneChanger.change_scene.bind(null))
