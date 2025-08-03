class_name Main
extends Node

@export var NEXT_SCENE : PackedScene
@export var dialogue_manager : Node
@export var end_dialog_char_1 : String
@export var end_dialog_char_1_color : Color
@export var end_dialogue_char_1_image : CompressedTexture2D
@export var end_dialogue_jeanie_image : CompressedTexture2D
@export var start_dialogue : PackedScene
@export var end_dialogue : PackedScene
@export var finish_line : Node2D
@onready var ui: CanvasLayer = $UI

@export var base_game_time : float = 60
@export var camera_distance_offset : float = 350
@export var camera_speed_offset : float = 0.1
@export var camera_max_zoom : float = 4
@export var camera_min_zoom : float = 2.5

@export var death_duration : float = 3
@export var camera_death_zoom : float = 4

@onready var game_settings: GameSettingsUI = %GameSettings
@onready var game_timer: Timer = %GameTimer
@onready var time_label: Label = %TimeLabel
@onready var player: Player = %Player
@onready var infinity_loop: InfinityLoop = %InfinityLoop
@onready var phantom_camera: PhantomCamera2D = %PhantomCamera2D
@onready var player_spawn_position: Marker2D = %PlayerSpawnPosition
@onready var glitch_effect: ColorRect = %GlitchEffect
@onready var ui_animator: AnimationPlayer = %UIAnimator
@onready var black_color: ColorRect = %BlackColor
@onready var jump_icon: Sprite2D = %JumpIcon
@onready var speed_icon: Sprite2D = %SpeedIcon



func _ready() -> void:
	jump_icon.modulate = Color("d622ff")
	speed_icon.modulate = Color("72f1b9")
	Global.reset_tape()
	Global.next_tape()
	black_color.show()
	game_settings.exit_pressed.connect(toggle_pause)
	game_timer.timeout.connect(_on_game_timer_timeout)
	Global.tape_changed.connect(_on_tape_changed)
	EventBus.collectable_collected.connect(_on_collectable)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.reached_level_finish.connect(_reached_finish_line)
	EventBus.player_died.connect(game_over)
	player.global_position = player_spawn_position.global_position
	if dialogue_manager:
		Engine.time_scale = 0
		var start_d := start_dialogue.instantiate()
		start_d.name = "start_dialogue"
		dialogue_manager.add_child(start_d)
		
		var end_d := end_dialogue.instantiate()
		end_d.name = "end_dialogue"
		dialogue_manager.add_child(end_d)
		
		dialogue_manager.start("start_dialogue")
	else:
		await fade_black(true)
		restart_game()
	

func _on_dialogue_ended():
	if finish_line:
		Engine.time_scale = 1
		await fade_black(true)
		restart_game()
	else:
		next_scene()


func fade_black(from:bool):
	var alpha : float = 0 if from else 1
	var tween := create_tween()
	tween.tween_property(black_color,^"self_modulate",Color(0,0,0,alpha),2)
	await tween.finished


func restart_game():
	Engine.time_scale = 1
	player.dead = false
	game_timer.wait_time = base_game_time
	game_timer.start()


func game_over():
	if glitch_effect.visible:
		return
	
	AudioManager.play(AudioManager.death)
	AudioManager.play(AudioManager.glitch)
	glitch_effect.show()
	game_timer.stop()
	player.dead = true
	var tween := create_tween()
	tween.tween_property(player,^"global_position",player_spawn_position.global_position,death_duration)
	await tween.finished
	player.velocity = Vector2.ZERO
	player.dead = false
	game_timer.start()
	glitch_effect.hide()


func _on_game_timer_timeout():
	game_over()


func _on_collectable(type:String):
	match type:
		"time":
			#game_timer.wait_time = game_timer.time_left if game_timer.time_left > 0.0 else 1.0
			#game_timer.wait_time += 5
			#game_timer.start()
			pass

func _physics_process(delta: float) -> void:
	if player.dead:
		_set_camera_dead_offset()
		return
	time_label.text = format_time()
	_set_camera_offset()

func _reached_finish_line():
	if finish_line:
		level_cleared()
		finish_line = null

func _set_camera_dead_offset():
	var target_zoom : Vector2= lerp(phantom_camera.zoom, Vector2(camera_death_zoom, camera_death_zoom), 1)
	phantom_camera.zoom = phantom_camera.zoom.lerp(target_zoom, get_process_delta_time() * camera_speed_offset*5)

func _set_camera_offset():
	var direction : float= sign(player.velocity.x)
	var velocity_x := player.velocity.x
	var ratio :float= clamp(abs(velocity_x) / player.current_maximum_velocity, 0.0, 1.0)
	
	var target_zoom : Vector2= lerp(Vector2(camera_max_zoom, camera_max_zoom), Vector2(camera_min_zoom, camera_min_zoom), ratio)
	phantom_camera.zoom = phantom_camera.zoom.lerp(target_zoom, get_process_delta_time() * camera_speed_offset)
	
	var target_offset := Vector2(direction * ratio * camera_distance_offset, 0)
	phantom_camera.follow_offset = phantom_camera.follow_offset.lerp(target_offset, get_physics_process_delta_time() * camera_speed_offset)

func format_time() -> String:
	@warning_ignore("integer_division")
	var minutes := int(game_timer.time_left) / 60
	var secs := int(game_timer.time_left) % 60
	return "%02d:%02d" % [minutes, secs]

func _unhandled_input(event):
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		toggle_pause()


func toggle_pause():
	if game_settings.visible:
		game_settings.hide()
		get_tree().paused =false
	else:
		game_settings.show()
		get_tree().paused =true


func _input(_event: InputEvent) -> void:
	if player.dead:
		return
	
	if Input.is_action_just_pressed(&"switch_tape") and player.can_switch_tape:
		#if infinity_loop.sprite_in_middle:
		player.tape_switch_timer.start()
		player.can_switch_tape = false
		AudioManager.play(AudioManager.tape)
		ui_animator.play(&"ripple")
		#slow_down_and_restore()
		infinity_loop.sprite_in_middle = false
		Global.next_tape()


func slow_down_and_restore(duration: float = 0.25):
	var tween := create_tween()
	var half := duration / 2.0
	tween.tween_property(Engine, "time_scale", 0.1, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(Engine, "time_scale", 1.0, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)



func _on_tape_changed():
	_apply_tape_power()


func _apply_tape_power():
	match Global.current_tape_index:
		#Global.TAPE.NEON_PINK:
			#player.global_position.x += 100*player.player_facing_direction
			#powerup_text = "dash"
		#Global.TAPE.CYAN:
			#player.velocity.y += 5000
			#powerup_text = "fall instantly"
		Global.TAPE.PINK:
			player.use_jump_powerup()
			$UI/MarginContainer/VBoxContainer/SpeedIcon.visible = true
			$UI/MarginContainer/VBoxContainer/JumpIcon.visible = false
		Global.TAPE.TEAL:
			player.use_speed_powerup()
			$UI/MarginContainer/VBoxContainer/SpeedIcon.visible = false
			$UI/MarginContainer/VBoxContainer/JumpIcon.visible = true

func level_cleared():
	AudioManager.fade_out_all_tracks()
	await fade_black(false)
	Engine.time_scale = 0
	dialogue_manager.name_ = end_dialog_char_1
	dialogue_manager.name_color_ = end_dialog_char_1_color
	dialogue_manager.avatar_ = end_dialogue_char_1_image
	dialogue_manager.avatar__ = end_dialogue_jeanie_image
	dialogue_manager.start("end_dialogue")


func next_scene():
	SceneChanger.change_scene(NEXT_SCENE)
