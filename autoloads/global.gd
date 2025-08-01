@tool
extends Node

signal tape_changed

enum TAPE {NEON_PINK, CYAN, YELLOW, GREEN}

const TAPE_STRINGS := ["neon_pink","cyan","yellow","green"]
const TAPE_COLORS := [Color.HOT_PINK,Color.CYAN,Color.YELLOW,Color.GREEN]

var current_tape_index : int = 0 :
	set(value):
		current_tape_index = value
		tape_changed.emit()


func _ready() -> void:
	EventBus.game_restarted.connect(reset_tape)


func previous_tape():
	current_tape_index = (current_tape_index - 1 + TAPE.size()) % TAPE.size()


func next_tape():
	current_tape_index = (current_tape_index + 1) % TAPE.size()


func reset_tape():
	current_tape_index = 0

@warning_ignore("int_as_enum_without_cast")
func get_tape_string(t:TAPE=current_tape_index)->String:
	return TAPE_STRINGS[t]

@warning_ignore("int_as_enum_without_cast")
func get_tape_color(t:TAPE=current_tape_index)->Color:
	return TAPE_COLORS[t]

func get_next_tape()->TAPE:
	var next_tape_to_get : int = current_tape_index
	next_tape_to_get = (next_tape_to_get + 1) % TAPE.size()
	@warning_ignore("int_as_enum_without_cast")
	return next_tape_to_get 
