extends Node

var __xp_scale: float 
var __gold_scale: float
var __hp_scale: float
var music_position: float = 0.0
var sfx_volume: float = 0.0
const CONFIG_PATH = "user://settings.cfg"

func _ready() -> void:
	__load_from_config()

func __load_from_config() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		if config.get_value("Settings", "hp_scale", false):
			__hp_scale = 0.5
		else:
			__hp_scale = 1
		if config.get_value("Settings", "gold_scale", false):
			__gold_scale = 0.5
		else:
			__gold_scale = 1
		if config.get_value("Settings", "reduced_experience", false):
			__xp_scale = 0.5
		else:
			__xp_scale = 1

func set_xp_scale(a: float):
	__xp_scale = a

func set_gold_scale(a: float):
	__gold_scale = a

func set_hp_scale(a: float):
	__hp_scale = a

func save_game(slot: int, stats: PlayerStats, inventory: SimplifiedInventory, Spawner: Spawner_logic) -> void:
	var wave = Spawner.get_current_wave()
	var save_data = {
		"wave": wave,
		"player_stats": stats.to_dict(),
		"inventory": inventory.get_inventory_data()
	}
	var file = FileAccess.open("user://save_slot_%d.json" % slot, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Игра сохранена в слот", slot, "на волне", wave)

func load_game(slot: int) -> Dictionary:
	var path = "user://save_slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		push_warning("Файл сейва не найден!")
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	print("Игра загружена из слота", slot, "волна:", data.get("wave", "?"))
	return data

func delete_save(slot: int) -> void:
	var path = "user://save_slot_%d.json" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Сейв слот %d удалён" % slot)
