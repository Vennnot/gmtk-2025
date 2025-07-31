class_name Main
extends Node


@export var base_game_time : float = 60

@onready var game_settings: GameSettingsUI = %GameSettings
@onready var game_timer: Timer = %GameTimer
@onready var time_label: Label = %TimeLabel
@onready var player: CharacterBody2D = %Player
@onready var debug_label: Label = %DebugLabel

var player_starting_pos := Vector2.ZERO



func _ready() -> void:
	game_settings.exit_pressed.connect(toggle_pause)
	game_timer.timeout.connect(_on_game_timer_timeout)
	Global.tape_changed.connect(_on_tape_changed)
	_on_tape_changed()
	restart_game()


func restart_game():
	EventBus.game_restarted.emit()
	game_timer.wait_time = base_game_time
	game_timer.start()


func _on_game_timer_timeout():
	player.position = player_starting_pos
	restart_game()



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
		Global.next_tape()


func _on_tape_changed():
	debug_label.text = "Cassette Tape: %s" % Global.get_tape_string() 
