extends Node

const AUDIO_BUS_LAYOUT := preload("res://resources/audio/audio_bus_layout.tres")

@onready var music: AudioStreamPlayer = %Music
@onready var ambience: AudioStreamPlayer = %Ambience

func play(sound: AudioStream, parent:Node,sound_bus: String="sfx"):
	if sound_bus == "sfx":
		var audio_player := AudioStreamPlayer.new()
		if parent:
			parent.add_child(audio_player)
		add_child(audio_player)
		audio_player.stream = sound
		audio_player.bus = sound_bus
		audio_player.play(0.0)
		audio_player.pitch_scale += randf_range(-0.05, 0.05)
		await audio_player.finished
		audio_player.queue_free()
	elif sound_bus == "music":
		music.stream = sound
		fade_in()
	elif sound_bus == "ambience":
		music.stream = sound
		fade_in()


func fade_in(duration: float = 0.5):
	music.volume_db = -40
	music.play()
	var tween = create_tween()
	tween.tween_property(music, "volume_db", 0, duration)


func fade_out(duration: float = 3.0):
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -80, duration)
	await tween.finished
	music.stop()
