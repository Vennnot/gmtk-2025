extends HSlider

@export var property:String = ""

func _ready():
	value_changed.connect(_on_float_range_game_settings_option_value_changed)
	value = UserSettings.get_value(property)

func _on_float_range_game_settings_option_value_changed(val:float):
	UserSettings.set_value(property, val)
