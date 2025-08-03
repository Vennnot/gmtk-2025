class_name MainMenu
extends Control

@onready var main_buttons: HBoxContainer = %MainButtons
@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var exit_button: Button = %ExitButton
@onready var game_settings: GameSettingsUI = %GameSettings

func _ready() -> void:
	AudioManager.fade_out_all_tracks()
	Global.next_tape()
	game_settings.exit_pressed.connect(_close_settings)
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)


func _on_play_button_pressed():
	SceneChanger.change_scene(SceneChanger.MAIN_SCENE)


func _on_settings_button_pressed():
	main_buttons.hide()
	game_settings.show()



func _on_credits_button_pressed():
	SceneChanger.change_scene(CREDITS)

const CREDITS = preload("res://scenes/levels/credits.tscn")

func _on_exit_button_pressed():
	get_tree().quit()



func _close_settings()->void:
	game_settings.hide()
	main_buttons.show()
