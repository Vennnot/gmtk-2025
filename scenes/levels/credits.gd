extends Control

@onready var player: Player = $Player
@onready var player_spawn_pos: Marker2D = %PlayerSpawnPos
@onready var credits_button: Button = %CreditsButton



func _ready() -> void:
	player_passes()
	credits_button.pressed.connect(func():SceneChanger.change_scene(SceneChanger.MAIN_MENU))


func player_passes():
	await get_tree().create_timer(3).timeout
	player.visible = true
	player.global_position = player_spawn_pos.global_position
	player.velocity.y = 0
	player.velocity.x = 800
