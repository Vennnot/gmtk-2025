extends Node

const MAIN_SCENE := preload("res://scenes/levels/level1.tscn")
const MAIN_MENU := preload("res://scenes/UI/main_menu/main_menu.tscn")

func change_scene(next_scene:PackedScene):
	if not next_scene:
		return
	
	get_tree().change_scene_to_packed(next_scene)
	get_tree().paused = false
