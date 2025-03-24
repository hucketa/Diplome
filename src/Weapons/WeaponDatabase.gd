extends Node
class_name WeaponDatabase

var weapons: Array[WeaponData] = []

func _ready():
	weapons = load_all_weapon_data("res://src/Weapons/Data")
	print("WeaponDatabase загружено оружий: ", weapons.size())

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

func get_random(count: int = 1) -> Array:
	var copy = weapons.duplicate()
	copy.shuffle()
	return copy.slice(0, count)

func get_by_rarity(rarity: String) -> Array:
	return weapons.filter(func(w): return w.rarity == rarity)

func get_by_type(weapon_type: String) -> Array:
	return weapons.filter(func(w): return w.weapon_type == weapon_type)
