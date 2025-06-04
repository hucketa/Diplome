extends Node

const SAVE_PATH_TEMPLATE := "user://save_slot_%d.json"

var __hp_scale: float = 1.0
var __gold_scale: float = 1.0
var __xp_scale: float = 1.0
var music_position: float = 0.0
var sfx_volume: float = 0.0
const CONFIG_PATH = "user://settings.cfg"
var __current_wave:int = 0
var save_next_wave:bool = false

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

func get_hp_scale() -> float:
	if __hp_scale == 0:
		__load_from_config()
	return __hp_scale

func save_game(slot: int, stats: PlayerStats, inventory: SimplifiedInventory, spawner: Spawner_logic) -> void:
	var wave = spawner.get_current_wave()
	if save_next_wave:
		wave += 1
	var save_data = {
		"wave": wave,
		"player_stats": stats.to_dict(),
		"inventory": inventory.get_inventory_data()
	}
	var path = SAVE_PATH_TEMPLATE % slot
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Игра сохранена в слот", slot, "на волне", save_data.wave)


func load_game(slot: int) -> Dictionary:
	var path = SAVE_PATH_TEMPLATE % slot
	if not FileAccess.file_exists(path):
		push_warning("⚠ Файл сейва не найден!")
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var result = JSON.parse_string(text)
	if typeof(result) != TYPE_DICTIONARY:
		push_warning("❌ Повреждённый сейв в слоте %d — удалён." % slot)
		DirAccess.remove_absolute(path)
		return {}
	print("Игра загружена из слота", slot, "волна:", result.get("wave", "?"))
	return result


func delete_save(slot: int) -> void:
	var path = SAVE_PATH_TEMPLATE % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Сейв слот %d удалён" % slot)

func get_save_summary(slot: int) -> Dictionary:
	var path = SAVE_PATH_TEMPLATE % slot
	if not FileAccess.file_exists(path):
		return {"exists": false}
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("❌ Повреждённый сейв в слоте %d — удалён." % slot)
		DirAccess.remove_absolute(path)
		return {"exists": false}
	return {
		"exists": true,
		"wave": data.get("wave", 0),
		"level": data.get("player_stats", {}).get("level", 1),
		"coins": data.get("player_stats", {}).get("coins", 0)
	}
