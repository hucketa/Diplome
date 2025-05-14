extends Node2D
class_name SimplifiedInventory

@onready var markers = [
	$Marker1,
	$Marker2,
	$Marker3,
	$Marker4
]

@export var slots_count: int = 5
var slots: Array = []
var current_slot: int = 0
var player_node = null

func _ready():
	_initialize_slots()
	_find_inventory_markers()

func _find_inventory_markers():
	for i in range(slots_count-1):
		if i < markers.size():
			print("Найден маркер для слота", i)
		else:
			print("Ошибка: маркер для слота", i, "не найден!")

func _initialize_slots():
	for i in range(slots_count):
		var slot = {}
		slot.weapon = null
		slots.append(slot)


func synchronize_weapon_orientation(is_facing_left: bool):
	for slot in slots:
		if slot.weapon != null:
			slot.weapon.set_flip(is_facing_left)

func remove_weapon(slot_index: int):
	if slot_index < 0 or slot_index >= slots_count:
		return
	if slots[slot_index].weapon:
		slots[slot_index].weapon.queue_free()
		slots[slot_index].weapon = null
	slots[slot_index].weapon_data = null


func select_slot(slot_index: int):
	if slot_index < 0 or slot_index >= slots_count:
		return
	current_slot = slot_index

func add_weapon(weapon_scene: PackedScene, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= slots_count:
		return false
	var new_weapon = weapon_scene.instantiate()
	if player_node and "set_player" in new_weapon:
		new_weapon.set_player(player_node)
	markers[slot_index].add_child(new_weapon)
	slots[slot_index].weapon = new_weapon
	return true


func add_weapon_from_data(data: WeaponData, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= slots_count-1:
		return false
	var new_weapon = data.weapon_scene.instantiate()
	if player_node and "set_player" in new_weapon:
		new_weapon.set_player(player_node)
	if "set_data" in new_weapon:
		new_weapon.set_data(data)
	markers[slot_index].add_child(new_weapon)
	slots[slot_index].weapon = new_weapon
	slots[slot_index].weapon_data = data
	return true


func _process(delta: float):
	for i in range(slots_count):
		var current_weapon = slots[i].weapon
		if current_weapon != null:
			if current_weapon.has_method("attack"):
				current_weapon.attack()

func get_inventory_data() -> Array:
	var inventory_data = []
	for i in range(min(slots.size(), 4)):
		var slot = slots[i]
		if slot.has("weapon_data") and slot.weapon_data:
			inventory_data.append({
				"name": slot.weapon_data.weapon_name,
				"tier": slot.weapon_data.tier,
				"damage": slot.weapon_data.damage
			})
		else:
			inventory_data.append(null)
	return inventory_data



func load_inventory_data(data: Array) -> void:
	for i in range(min(data.size(), 4)):
		remove_weapon(i)
		var entry = data[i]
		if entry != null:
			var base_data = WeaponDB.get_by_name(entry.name)
			if base_data:
				var weapon = base_data.duplicate()
				weapon.tier = entry.tier
				weapon.damage = entry.damage
				add_weapon_from_data(weapon, i)
