
extends Control

signal shop_closed
signal save_progress

@onready var slot_1_buy: Button = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy"
@onready var slot_2_buy: Button = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy"

@onready var texture_rect_1: TextureRect = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/TextureRect/TextureRect"
@onready var weapon_name_1: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy/HBoxContainer/Slot 1/HBoxContainer/WeaponName"
@onready var rarity_1: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy/HBoxContainer/Slot 1/HBoxContainer/Rarity"
@onready var price_1: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy/HBoxContainer/Slot 1/HBoxContainer/Price"
@onready var description_1: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy/HBoxContainer/Slot 1/VBoxContainer/Description"

@onready var texture_rect_2: TextureRect = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/TextureRect/TextureRect"
@onready var weapon_name_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy/HBoxContainer/Slot 1/HBoxContainer/WeaponName"
@onready var rarity_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy/HBoxContainer/Slot 1/HBoxContainer/Rarity"
@onready var price_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy/HBoxContainer/Slot 1/HBoxContainer/Price"
@onready var description_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy/HBoxContainer/Slot 1/VBoxContainer/Description"

@onready var player := get_tree().current_scene.get_node("Player")
@onready var inventory := player.get_node("InventoryUi")
@onready var player_stats := player.get_node("stats")

@onready var slot_1: Button = $"VBoxContainer/Inventory and Buttons/Inventory/Inventory/Slot1"
@onready var slot_2: Button = $"VBoxContainer/Inventory and Buttons/Inventory/Inventory/Slot2"
@onready var slot_3: Button = $"VBoxContainer/Inventory and Buttons/Inventory/Inventory/Slot 3"
@onready var slot_4: Button = $"VBoxContainer/Inventory and Buttons/Inventory/Inventory/Slot4"
@onready var label_error: Label = $"../Message/PanelContainer/Label"

var buy_slot_weapons: Array = []

func _ready():
	slot_1.set_player(player)
	slot_2.set_player(player)
	slot_3.set_player(player)
	slot_4.set_player(player)
	populate_buy_slots(-1)
	connect_buy_signals()
	merge_weapons()
	populate_inventory_ui()
	fill_stats()
	%Message.layer = 2
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))
	set_process(visible)

func _on_visibility_changed():
	set_process(visible)

func _show_message(a: String):
	label_error.text = a
	%Message.visible = true
	%Timer.start()

func _on_timer_timeout():
	%Message.visible = false
	%Timer.stop()

func _on_resume_pressed():
	emit_signal("shop_closed")

func _on_exit_pressed():
	get_tree().quit()

func _on_save_pressed():
	emit_signal("save_progress")

func connect_buy_signals():
	slot_1_buy.connect("pressed", Callable(self, "_on_buy_slot_pressed").bind(1))
	slot_2_buy.connect("pressed", Callable(self, "_on_buy_slot_pressed").bind(2))

func populate_buy_slots(slot_index := -1):
	var wave = GameManager.__current_wave+1
	if slot_index == -1 or slot_index == 1:
		var weapon_1 = WeaponDB.get_weapon_for_wave(wave)
		if buy_slot_weapons.size() >= 1:
			buy_slot_weapons[0] = weapon_1
		else:
			buy_slot_weapons.append(weapon_1)
		texture_rect_1.texture = weapon_1.icon
		weapon_name_1.text = weapon_1.weapon_name
		rarity_1.text = weapon_1.rarity
		price_1.text = str(weapon_1.price) + " " + tr("COINS")
		description_1.text = weapon_1.description
	if slot_index == -1 or slot_index == 2:
		var weapon_2 = WeaponDB.get_weapon_for_wave(wave)
		if buy_slot_weapons.size() >= 2:
			buy_slot_weapons[1] = weapon_2
		else:
			while buy_slot_weapons.size() < 1:
				buy_slot_weapons.append(null)
			buy_slot_weapons.append(weapon_2)
		texture_rect_2.texture = weapon_2.icon
		weapon_name_2.text = weapon_2.weapon_name
		rarity_2.text = weapon_2.rarity
		price_2.text = str(weapon_2.price) + " " + tr("COINS")
		description_2.text = weapon_2.description
	debug_print_inventory()

func _on_buy_slot_pressed(slot_index):
	if buy_slot_weapons.size() == 0:
		_show_message(tr("EMPTY_SLOT"))
		return
	var weapon = buy_slot_weapons[slot_index - 1]
	if player_stats.__coins < weapon.price:
		_show_message(tr("NO_MONEY"))
		return
	var inserted = false
	for i in range(4):
		if inventory.slots[i].get("weapon", null) == null:
			inventory.add_weapon_from_data(weapon, i)
			inserted = true
			break
	if not inserted:
		for i in range(4):
			var w_data = inventory.slots[i].get("weapon_data", null)
			if w_data and w_data.weapon_name == weapon.weapon_name and w_data.tier == weapon.tier:
				var new_weapon = weapon.duplicate()
				new_weapon.tier += 1
				new_weapon.damage = calculate_upgraded_damage(new_weapon.weapon_name, new_weapon.tier, new_weapon.rarity)
				new_weapon.price = calculate_upgraded_price(weapon.price, new_weapon.tier, new_weapon.rarity)
				inventory.remove_weapon(i)
				inventory.remove_weapon(4)
				inventory.add_weapon_from_data(new_weapon, i)
				player_stats.__coins -= weapon.price
				populate_inventory_ui()
				fill_stats()
				debug_print_inventory()
				return
		_show_message(tr("FULL INVENTORY"))
		return
	player_stats.__coins -= weapon.price
	clear_shop_section(slot_index)
	populate_inventory_ui()
	fill_stats()


func clear_shop_section(slot_index):
	if slot_index == 1:
		texture_rect_1.texture = null
		weapon_name_1.text = ""
		rarity_1.text = ""
		price_1.text = ""
		description_1.text = ""
		if buy_slot_weapons.size() >= 1:
			buy_slot_weapons[0] = null
	elif slot_index == 2:
		texture_rect_2.texture = null
		weapon_name_2.text = ""
		rarity_2.text = ""
		price_2.text = ""
		description_2.text = ""
		if buy_slot_weapons.size() >= 2:
			buy_slot_weapons[1] = null
	populate_buy_slots(slot_index)

func merge_weapons():
	var ui_slots := [slot_1, slot_2, slot_3, slot_4]
	var merged = true
	while merged:
		merged = false
		var grouped = {}
		for i in range(5):
			var data = inventory.slots[i]
			var weapon_data = data.get("weapon_data", null)
			if weapon_data != null:
				var key = "%s_%d" % [weapon_data.weapon_name, weapon_data.tier]
				if not grouped.has(key):
					grouped[key] = []
				grouped[key].append(i)
		for key in grouped.keys():
			var indexes = grouped[key]
			while indexes.size() >= 2:
				var index1 = -1
				var index2 = -1
				if indexes.has(3):
					index1 = 3
					indexes.erase(3)
					index2 = indexes.pop_back()
				else:
					index1 = indexes.pop_back()
					index2 = indexes.pop_back()
				var w1 = inventory.slots[index1].weapon_data
				var new_weapon = w1.duplicate()
				new_weapon.tier += 1
				new_weapon.damage = calculate_upgraded_damage(new_weapon.weapon_name, new_weapon.tier, new_weapon.rarity)
				new_weapon.price = calculate_upgraded_price(w1.price, new_weapon.tier, new_weapon.rarity)
				inventory.remove_weapon(index1)
				inventory.remove_weapon(index2)
				var target_index = index1 if index1 == 3 or find_first_free_inventory_slot() == -1 else find_first_free_inventory_slot()
				inventory.add_weapon_from_data(new_weapon, target_index)
				if target_index < 4:
					ui_slots[target_index].update_display(new_weapon, target_index, inventory)
					apply_tier_color_to_slot(ui_slots[target_index], new_weapon.tier)
				merged = true
	populate_inventory_ui()
	fill_stats()



func find_first_free_inventory_slot() -> int:
	for i in range(5):
		if inventory.slots[i].get("weapon", null) == null:
			return i
	return -1

func populate_inventory_ui():
	var ui_slots := [slot_1, slot_2, slot_3, slot_4]
	for i in range(4):
		var ui_slot = ui_slots[i]
		var slot_data = inventory.slots[i]
		var weapon_data = slot_data.get("weapon_data", null)
		if slot_data.weapon != null:
			ui_slot.update_display(weapon_data, i, inventory)
			apply_tier_color_to_slot(ui_slot, weapon_data.tier)
		else:
			ui_slot.update_display(null, i, inventory)
			apply_tier_color_to_slot(ui_slot, 0)
	fill_stats()

func fill_stats():
	$"VBoxContainer/BuySlots and Stats/Stats/Health/Value".text = str(player_stats.__max_health)
	$"VBoxContainer/BuySlots and Stats/Stats/Damage/Value".text = str(player_stats.__damage)
	$"VBoxContainer/BuySlots and Stats/Stats/AS/Value".text = str(player_stats.__attack_speed)
	$"VBoxContainer/BuySlots and Stats/Stats/Crit_chance/Value".text = str(player_stats.__crit_chance)
	$"VBoxContainer/BuySlots and Stats/Stats/Level/Value".text = str(player_stats.__level)
	$"VBoxContainer/BuySlots and Stats/Stats/Gold/Value".text = str(round(player_stats.__coins))
	$"VBoxContainer/BuySlots and Stats/Stats/Armor/Value".text = str(player_stats.__armor)

func apply_tier_color_to_slot(slot_button: Button, tier: int):
	var tier_colors := {
		1: Color(1, 1, 1),
		2: Color(0.6, 1, 0.6),
		3: Color(0.6, 0.6, 1),
		4: Color(0.9, 0.6, 1),
		5: Color(1, 0.8, 0.2),
	}
	var clamped_tier = tier if tier <= 4 else 5
	slot_button.modulate = tier_colors.get(clamped_tier, Color(1, 1, 1))

func debug_print_inventory():
	print("=== Инвентарь игрока ===")
	for i in range(inventory.slots.size()):
		var data = inventory.slots[i]
		var weapon_data = data.get("weapon_data", null)
		if weapon_data != null:
			print("Слот %d: %s | Тир: %d | Цена: %d | Урон: %.2f | Раритет: %s" % [
				i,
				weapon_data.weapon_name,
				weapon_data.tier,
				weapon_data.price,
				weapon_data.damage,
				weapon_data.rarity,
			])
		else:
			print("Слот %d: пустой" % i)
	print("=========================")

func calculate_upgraded_damage(name: String, tier: int, rarity: String) -> float:
	var base_damage = 10.0
	var rarity_bonus = {
		"common": 1.0,
		"uncommon": 1.1,
		"rare": 1.2,
		"epic": 1.3,
		"legendary": 1.5
	}.get(rarity, 1.0)
	var wave_bonus = GameManager.__current_wave * 0.2
	var tier_multiplier = pow(1.1, tier)
	return base_damage * tier_multiplier * rarity_bonus + wave_bonus

func calculate_upgraded_price(base_price: int, tier: int, rarity: String) -> int:
	var rarity_multiplier = {
		"common": 1.0,
		"uncommon": 1.2,
		"rare": 1.5,
		"epic": 1.8,
		"legendary": 2.2
	}.get(rarity, 1.0)
	var tier_multiplier = pow(1.3, tier)
	return int(base_price * tier_multiplier * rarity_multiplier)

func _process(delta: float) -> void:
	merge_weapons()
	populate_inventory_ui()
