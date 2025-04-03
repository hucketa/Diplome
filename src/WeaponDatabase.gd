extends Node
class_name WeaponDatabase

var weapons: Array[WeaponData] = []
var wave_config = [
	{
		"min_wave": 1,
		"max_wave": 14,
		"distribution": [
			["COMMON", 1.0]
		]
	},
	{
		"min_wave": 15,
		"max_wave": 24,
		"distribution": [
			["COMMON", 0.7],
			["RARE", 0.3]
		]
	},
	{
		"min_wave": 25,
		"max_wave": 34,
		"distribution": [
			["RARE", 0.7],
			["EPIC", 0.3]
		]
	},
	{
		"min_wave": 35,
		"max_wave": 9999,
		"distribution": [
			["EPIC", 0.7],
			["LEGENDARY", 0.3]
		]
	}
]

func _ready():
	weapons = load_all_weapon_data("res://src/Weapons/Data")
	print("WeaponDatabase загружено оружий:", weapons.size())

func load_all_weapon_data(path: String) -> Array:
	var result: Array[WeaponData] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				var res = load(path + "/" + file)
				if res is WeaponData:
					result.append(res)
				else:
					push_error("Файл не WeaponData: " + file)
			file = dir.get_next()
	else:
		push_error("Не удалось открыть папку: " + path)
	return result

func get_distribution_for_wave(wave: int) -> Array:
	for segment in wave_config:
		if wave >= segment["min_wave"] and wave <= segment["max_wave"]:
			return segment["distribution"]
	return []

func pick_rarity_for_wave(wave: int) -> String:
	var dist = get_distribution_for_wave(wave)
	if dist.size() == 0:
		return "COMMON"
	var roll = randf()
	var cumulative = 0.0
	for item in dist:
		var r = item[0]
		var chance = item[1]
		cumulative += chance
		if roll <= cumulative:
			return r
	return dist[dist.size() - 1][0]

func get_by_rarity(rarity: String) -> Array:
	return weapons.filter(func(w):
		return w.rarity == rarity
	)

func get_weapon_for_wave(wave: int) -> WeaponData:
	var chosen_rarity = pick_rarity_for_wave(wave)
	var arr = get_by_rarity(chosen_rarity)
	if arr.size() == 0:
		# fallback если вдруг нет такого оружия
		return null
	# выберем случайный
	return arr[randi() % arr.size()]
