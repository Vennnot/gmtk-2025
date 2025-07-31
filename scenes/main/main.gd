class_name Main
extends Node


@export var base_game_time : float = 60

@onready var game_settings: GameSettingsUI = %GameSettings
@onready var game_timer: Timer = %GameTimer
@onready var time_label: Label = %TimeLabel
@onready var player: Player = %Player
@onready var debug_label: Label = %DebugLabel
@onready var infinity_loop: InfinityLoop = %InfinityLoop
@onready var power_label: Label = %PowerLabel

var player_starting_pos := Vector2.ZERO



func _ready() -> void:
	game_settings.exit_pressed.connect(toggle_pause)
	game_timer.timeout.connect(_on_game_timer_timeout)
	Global.tape_changed.connect(_on_tape_changed)
	EventBus.collectable_collected.connect(_on_collectable)
	
	_on_tape_changed()
	restart_game()


func restart_game():
	EventBus.game_restarted.emit()
	game_timer.wait_time = base_game_time
	game_timer.start()


func _on_game_timer_timeout():
	player.position = player_starting_pos
	restart_game()


func _on_collectable(type:String):
	match type:
		"time":
			game_timer.wait_time = game_timer.time_left
			game_timer.wait_time += 5
			game_timer.start()


func _process(_delta: float) -> void:
	time_label.text = format_time()


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
	if Input.is_action_just_pressed(&"switch_tape"):
		if infinity_loop.sprite_in_middle:
			infinity_loop.sprite_in_middle = false
			Global.next_tape()


func _on_tape_changed():
	debug_label.text = "Cassette Tape: %s" % Global.get_tape_string() + ", Next Tape: %s" % Global.get_tape_string(Global.get_next_tape())
	_apply_tape_power()


func _apply_tape_power():
	_reset_values()
	var powerup_text := ""
	match Global.current_tape_index:
		Global.TAPE.BLUE:
			_increase_gravity()
			powerup_text = "increased gravity"
		Global.TAPE.RED:
			_slow_time()
			powerup_text = "time slowed"
		Global.TAPE.PURPLE:
			_decrease_gravity()
			powerup_text = "decreased gravity"
		#3:
			#_increase_speed()
	power_label.text = "current power: %s" % powerup_text


func _slow_time():
	Engine.time_scale = 0.7

func _increase_speed():
	player.current_maximum_velocity *= 2

func _decrease_gravity():
	player.current_gravity_force /= 2

func _increase_gravity():
	player.current_gravity_force *= 2

func _reset_values():
	Engine.time_scale = 1
	player.reset_gravity()
	player.reset_max_velocity()
