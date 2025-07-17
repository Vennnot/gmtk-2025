extends CheckButton

@export var property:String = ""

func _ready():
	toggled.connect(_on_game_settings_toggle)
	button_pressed = UserSettings.get_value(property)

func _on_game_settings_toggle(toggled_on:bool):
	UserSettings.set_value(property, toggled_on)
