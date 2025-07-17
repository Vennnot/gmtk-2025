class_name GameSettingsUI
extends HBoxContainer

signal exit_pressed

@onready var exit_button: Button = %ExitButton
@onready var main_menu_button: Button = %MainMenuButton

@export var in_game : bool = false

func _ready() -> void:
	exit_button.pressed.connect(func():exit_pressed.emit())
	main_menu_button.pressed.connect(func():SceneChanger.change_scene(SceneChanger.MAIN_MENU))
	main_menu_button.visible = in_game

#disable sliders when not editable?
#func _on_master_volume_toggle_toggled(button_pressed: bool) -> void:
	#master_volume_slider.editable = button_pressed
	#music_volume_slider.editable = music_volume_toggle.button_pressed and button_pressed
	#sound_volume_slider.editable = sound_volume_toggle.button_pressed and button_pressed
	#UserSettings.set_value("mastervolume_enabled", button_pressed)
