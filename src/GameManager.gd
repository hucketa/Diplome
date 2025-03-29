extends Node

var __xp_scale: float 
var __gold_scale: float
var __hp_scale: float
var music_position: float = 0.0
var sfx_volume: float = 0.0
const CONFIG_PATH = "user://settings.cfg"

func _ready() -> void:
	__load_from_config()

func __load_from_config()->void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		if(config.get_value("Settings", "hp_scale", false)):
			__hp_scale = 0.5
		else:
			__hp_scale = 1
		if(config.get_value("Settings", "gold_scale", false)):
			__gold_scale = 0.5
		else:
			__gold_scale = 1
		if(config.get_value("Settings", "reduced_experience", false)):
			__xp_scale = 0.5
		else:
			__xp_scale = 1

func set_xp_scale(a: float):
	__xp_scale = a
	print(__xp_scale)

func set_gold_scale(a: float):
	__gold_scale = a
	print(__gold_scale)

func set_hp_scale(a: float):
	__hp_scale = a
	print(__hp_scale)
