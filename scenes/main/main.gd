class_name Main
extends Node

@onready var game_settings: GameSettingsUI = %GameSettings

func _ready() -> void:
	game_settings.exit_pressed.connect(toggle_pause)


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
