extends Control

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

var buy_slot_weapons: Array = []

func _ready():
	TranslationServer.set_locale("uk")
	slot_1.set_player(player)
	slot_2.set_player(player)
	slot_3.set_player(player)
	slot_4.set_player(player)
	populate_buy_slots()
	connect_buy_signals()
	populate_inventory_ui()
	fill_stats()

func populate_buy_slots():
	buy_slot_weapons.clear()
	var weapons = WeaponDB.get_random(2)

	var weapon_1 = weapons[0]
	buy_slot_weapons.append(weapon_1)
	texture_rect_1.texture = weapon_1.icon
	weapon_name_1.text = weapon_1.weapon_name
	rarity_1.text = weapon_1.rarity
	price_1.text = str(weapon_1.price) + " " + tr("COINS")
	description_1.text = weapon_1.description

	var weapon_2 = weapons[1]
	buy_slot_weapons.append(weapon_2)
	texture_rect_2.texture = weapon_2.icon
	weapon_name_2.text = weapon_2.weapon_name
	rarity_2.text = weapon_2.rarity
	price_2.text = str(weapon_2.price) + " " + tr("COINS")
	description_2.text = weapon_2.description

func connect_buy_signals():
	slot_1_buy.connect("pressed", Callable(self, "_on_buy_slot_pressed").bind(1))
	slot_2_buy.connect("pressed", Callable(self, "_on_buy_slot_pressed").bind(2))

func _on_buy_slot_pressed(slot_index: int):
	var weapon = buy_slot_weapons[slot_index - 1]
	if player_stats.__coins >= weapon.price:
		var free_index = find_first_free_inventory_slot()
		if free_index != -1:
			player_stats.__coins -= weapon.price
			inventory.add_weapon_from_data(weapon, free_index)
			var ui_slots = [slot_1, slot_2, slot_3, slot_4]
			var ui_slot = ui_slots[free_index]
			ui_slot.update_display(weapon, free_index, inventory)
			fill_stats()
		else:
			print("Немає вільних слотів в інвентарі.")
	else:
		print("Недостатньо золота для покупки.")

func find_first_free_inventory_slot() -> int:
	for i in inventory.slots.size():
		var data = inventory.slots[i]
		if data.get("weapon", null) == null:
			return i
	return -1

func populate_inventory_ui() -> void:
	var ui_slots := [slot_1, slot_2, slot_3, slot_4]
	for i in range(inventory.slots.size()):
		var ui_slot = ui_slots[i]
		var slot_data = inventory.slots[i]
		var weapon_data = slot_data.get("weapon_data", null)
		if slot_data.weapon != null:
			ui_slot.update_display(weapon_data, i, inventory)
		else:
			ui_slot.update_display(null, i, inventory)
		fill_stats()

func fill_stats() -> void:
	$"VBoxContainer/BuySlots and Stats/Stats/Health/Value".text = str(player_stats.__max_health)
	$"VBoxContainer/BuySlots and Stats/Stats/Damage/Value".text = str(player_stats.__damage)
	$"VBoxContainer/BuySlots and Stats/Stats/AS/Value".text = str(player_stats.__attack_speed)
	$"VBoxContainer/BuySlots and Stats/Stats/Crit_chance/Value".text = str(player_stats.__crit_chance * 100)
	$"VBoxContainer/BuySlots and Stats/Stats/Level/Value".text = str(player_stats.__level)
	$"VBoxContainer/BuySlots and Stats/Stats/Experience/Value".text = str(player_stats.__experience_to_level_up)
	$"VBoxContainer/BuySlots and Stats/Stats/Gold/Value".text = str(player_stats.__coins)
