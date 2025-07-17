extends Node

signal on_value_change(key, value)

const SECTION = "user"
const SETTINGS_FILE = "user://settings.cfg"

const MASTER_ENABLED = "master_bus_enabled"
const MUSIC_ENABLED = "music_bus_enabled"
const SFX_ENABLED = "sfx_bus_enabled"
const AMBIENCE_ENABLED = "ambience_bus_enabled"
const MASTER_VOLUME = "master_volume"
const MUSIC_VOLUME = "music_volume"
const SFX_VOLUME = "sfx_volume"
const AMBIENCE_VOLUME = "ambience_volume"
const GAME_LANGUAGE = "game_locale"

const AUDIO_BUS_MASTER = "Master"
const AUDIO_BUS_SFX = "sfx"
const AUDIO_BUS_MUSIC = "music"
const AUDIO_BUS_AMBIENCE = "ambience"
	
var USER_SETTING_DEFAULTS = {
	MASTER_ENABLED:true,
	MUSIC_ENABLED:true,
	SFX_ENABLED:true,
	AMBIENCE_ENABLED:true,
	MASTER_VOLUME:100,
	MUSIC_VOLUME:70,
	SFX_VOLUME:100,
	AMBIENCE_VOLUME:100,
	GAME_LANGUAGE:"en"
}

var config:ConfigFile

func _ready():
	config = ConfigFile.new()
	config.load(SETTINGS_FILE)
	_configure_audio()
	_configure_language()
	
func set_value(key, value):
	config.set_value(SECTION, key, value)
	config.save(SETTINGS_FILE)
	if key == MASTER_VOLUME:
		_update_volume(MASTER_VOLUME, AUDIO_BUS_MASTER)
	if key == SFX_VOLUME:
		_update_volume(SFX_VOLUME, AUDIO_BUS_SFX)
	if key == MUSIC_VOLUME:
		_update_volume(MUSIC_VOLUME, AUDIO_BUS_MUSIC)
	if key == AMBIENCE_VOLUME:
		_update_volume(AMBIENCE_VOLUME, AUDIO_BUS_AMBIENCE)
	if key == MASTER_ENABLED:
		_mute_bus(MASTER_ENABLED, AUDIO_BUS_MASTER)
	if key == MUSIC_ENABLED:
		_mute_bus(MUSIC_ENABLED, AUDIO_BUS_MUSIC)
	if key == SFX_ENABLED:
		_mute_bus(SFX_ENABLED, AUDIO_BUS_SFX)
	if key == AMBIENCE_ENABLED:
		_mute_bus(AMBIENCE_ENABLED, AUDIO_BUS_AMBIENCE)
	if key == GAME_LANGUAGE:
		TranslationServer.set_locale(value)
	emit_signal("on_value_change", key, value)

func get_value(key):
	return config.get_value(SECTION, key, _get_default(key))
	
func get_value_with_default(key, default):
	return config.get_value(SECTION, key, default)

func _get_default(key):
	if USER_SETTING_DEFAULTS.has(key):
		return USER_SETTING_DEFAULTS[key]
	return null

func _configure_audio():
	_update_volume(MASTER_VOLUME, AUDIO_BUS_MASTER)
	_update_volume(MUSIC_VOLUME, AUDIO_BUS_MUSIC)
	_update_volume(SFX_VOLUME, AUDIO_BUS_SFX)
	_update_volume(AMBIENCE_VOLUME, AUDIO_BUS_AMBIENCE)
	_mute_bus(MASTER_ENABLED, AUDIO_BUS_MASTER)
	_mute_bus(MUSIC_ENABLED, AUDIO_BUS_MUSIC)
	_mute_bus(SFX_ENABLED, AUDIO_BUS_SFX)
	_mute_bus(AMBIENCE_ENABLED, AUDIO_BUS_AMBIENCE)
	
func _update_volume(property, bus):
	var current = (get_value_with_default(property, USER_SETTING_DEFAULTS[property]) -100) / 2
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), current)

func _mute_bus(property, bus):
	var enabled = get_value_with_default(property, USER_SETTING_DEFAULTS[property])
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), not enabled)

func _configure_language():
	TranslationServer.set_locale(get_value_with_default(GAME_LANGUAGE, USER_SETTING_DEFAULTS[GAME_LANGUAGE])) 
