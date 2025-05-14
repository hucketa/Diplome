extends Node
class_name WeaponDatabase
var weapons: Array = []
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
	var result = []
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Не удалось открыть папку: " + path)
		return result
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path = "%s/%s" % [path, file_name]
		if dir.current_is_dir():
			result += load_all_weapon_data(full_path)
		else:
			var res: Resource = null
			if file_name.ends_with(".remap"):
				var tres_path = full_path.substr(0, full_path.length() - ".remap".length())
				res = ResourceLoader.load(tres_path)
				if not res:
					push_error("Не удалось загрузить remapped ресурс: " + tres_path)
			else:
				res = ResourceLoader.load(full_path)
			if res and res is WeaponData:
				result.append(res)
			elif res:
				push_warning("Загружен ресурс, но не WeaponData: " + full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
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
		return null
	return arr[randi() % arr.size()]	

static func get_weapon_by_name_and_tier(name: String, tier: int) -> Resource:
	for w in WeaponDB.weapons:
		if w.weapon_name == name and w.tier == tier:
			return w
	print("НЕ НАЙДЕНО: %s tier %d" % [name, tier])
	return null

static func get_by_name(name: String) -> Resource:
	for w in WeaponDB.weapons:
		if w.weapon_name == name:
			return w
	print("НЕ НАЙДЕНО: %s" % [name])
	return null
