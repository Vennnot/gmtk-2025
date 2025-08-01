extends Node

const AUDIO_BUS_LAYOUT := preload("res://resources/audio/audio_bus_layout.tres")

@onready var default_music: AudioStreamPlayer = %DefaultMusic
@onready var digi_music: AudioStreamPlayer = %DigiMusic
@onready var funk_music: AudioStreamPlayer = %FunkMusic
@onready var grav_music: AudioStreamPlayer = %GravMusic
@onready var ambience: AudioStreamPlayer = %Ambience

@export var glitch: AudioStream
@export var tape:AudioStream

func _ready() -> void:
	Global.tape_changed.connect(_on_tape_changed)


func play(sound: AudioStream, parent:Node=self,sound_bus: String="sfx"):
	if sound_bus == "sfx":
		var audio_player := AudioStreamPlayer.new()
		parent.add_child(audio_player)
		audio_player.stream = sound
		audio_player.volume_db = -20
		audio_player.bus = sound_bus
		audio_player.play(0.0)
		audio_player.pitch_scale += randf_range(-0.05, 0.05)
		await audio_player.finished
		audio_player.queue_free()
	#elif sound_bus == "music":
		#music.stream = sound
		#fade_in()
	elif sound_bus == "ambience":
		ambience.stream = sound


func fade_in(music:AudioStreamPlayer,duration: float = 0.5):
	music.volume_db = -40
	music.play()
	var tween = create_tween()
	tween.tween_property(music, "volume_db", 0, duration)


func fade_out(music:AudioStreamPlayer,duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -40, duration)
	await tween.finished
	music.stop()


func _on_tape_changed():
	switch_to_track(Global.current_tape_index)


func switch_to_track(index: int):
	var tracks := [default_music, digi_music, funk_music, grav_music]
	for i in range(tracks.size()):
		if i == index:
			await_fade_in(i)
		else:
			fade_out(tracks[i])

func await_fade_in(index:int):
	var tracks := [default_music, digi_music, funk_music, grav_music]
	await get_tree().create_timer(0.5).timeout
	fade_in(tracks[index])
