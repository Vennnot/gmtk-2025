@tool
extends Node

signal tape_changed

enum TAPE {GREEN, YELLOW}

const TAPE_STRINGS := ["green", "yellow"]
const TAPE_COLORS := [Color.GREEN, Color.YELLOW, ]

var player_upside_down := false
var player_controllable := true

var current_tape_index : int = 0 :
	set(value):
		current_tape_index = value
		tape_changed.emit()


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
