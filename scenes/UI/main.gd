class_name Main
extends Node


@export var base_game_time : float = 60
@export var camera_distance_offset : float = 350
@export var camera_speed_offset : float = 0.1
@export var camera_max_zoom : float = 4
@export var camera_min_zoom : float = 2.5

@export var death_duration : float = 3
@export var camera_death_zoom : float = 6


@onready var game_settings: GameSettingsUI = %GameSettings
@onready var game_timer: Timer = %GameTimer
@onready var time_label: Label = %TimeLabel
@onready var player: Player = %Player
@onready var debug_label: Label = %DebugLabel
@onready var infinity_loop: InfinityLoop = %InfinityLoop
@onready var power_label: Label = %PowerLabel
@onready var phantom_camera: PhantomCamera2D = %PhantomCamera2D
@onready var player_spawn_position: Marker2D = %PlayerSpawnPosition
@onready var glitch_effect: ColorRect = %GlitchEffect
@onready var ui_animator: AnimationPlayer = %UIAnimator



func _ready() -> void:
	game_settings.exit_pressed.connect(toggle_pause)
	game_timer.timeout.connect(_on_game_timer_timeout)
	Global.tape_changed.connect(_on_tape_changed)
	EventBus.collectable_collected.connect(_on_collectable)
	
	#_on_tape_changed() <-- Tapes are more active ability so we won't need this.
	restart_game()


func restart_game():
	Engine.time_scale = 1
	player.global_position = player_spawn_position.global_position
	player.dead = false
	game_timer.wait_time = base_game_time
	game_timer.start()
	EventBus.game_restarted.emit()


func game_over():
	AudioManager.play(AudioManager.glitch)
	glitch_effect.show()
	game_timer.stop()
	AudioManager.fade_out_all_tracks()
	player.dead = true
	var tween := create_tween()
	tween.tween_property(player,^"global_position",player_spawn_position.global_position,death_duration)
	await tween.finished
	get_tree().reload_current_scene()


func _on_game_timer_timeout():
	game_over()


func _on_collectable(type:String):
	match type:
		"time":
			game_timer.wait_time = game_timer.time_left
			game_timer.wait_time += 5
			game_timer.start()


func _physics_process(delta: float) -> void:
	if player.dead:
		_set_camera_dead_offset()
		return
	time_label.text = format_time()
	_set_camera_offset()


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
	
	if Input.is_action_just_pressed(&"switch_tape"):
		if infinity_loop.sprite_in_middle:
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
	debug_label.text = "Cassette Tape: %s" % Global.get_tape_string() + ", Next Tape: %s" % Global.get_tape_string(Global.get_next_tape())
	#Removed this delay, it felt weird to have to wait for an ability to fire.
	#await get_tree().create_timer(0.2).timeout
	_apply_tape_power()


func _apply_tape_power():
	var powerup_text := ""
	match Global.current_tape_index:
		#Global.TAPE.NEON_PINK:
			#player.global_position.x += 100*player.player_facing_direction
			#powerup_text = "dash"
		#Global.TAPE.CYAN:
			#player.velocity.y += 5000
			#powerup_text = "fall instantly"
		Global.TAPE.YELLOW:
			player.velocity.y -= 1000
			powerup_text = "air jump"
			$UI/MarginContainer/VBoxContainer/SpeedIcon.visible = true;
			$UI/MarginContainer/VBoxContainer/JumpIcon.visible = false;
		Global.TAPE.GREEN:
			player.velocity.x += 500*player.player_facing_direction
			powerup_text = "speed boost"
			$UI/MarginContainer/VBoxContainer/SpeedIcon.visible = false;
			$UI/MarginContainer/VBoxContainer/JumpIcon.visible = true;
	power_label.text = "current power: %s" % powerup_text
