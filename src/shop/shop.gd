extends Control

@onready var slot_1_buy: Button = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy"
#@onready var slot_2_buy: Button = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot_2_buy"
@onready var slot_1_buy_container: HBoxContainer = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1"
@onready var slot_2_buy_container: HBoxContainer = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2"
@onready var rarity_1: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy/HBoxContainer/Slot 1/HBoxContainer/Rarity"
@onready var weapon_name_1: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy/HBoxContainer/Slot 1/HBoxContainer/WeaponName"
@onready var price_1: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy/HBoxContainer/Slot 1/HBoxContainer/Price"
@onready var description_1: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/Slot_1_buy/HBoxContainer/Slot 1/VBoxContainer/Description"
@onready var texture_rect_1: TextureRect = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot1/TextureRect/TextureRect"
@onready var slot_2_buy: Button = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy"

#@onready var rarity_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot_2_buy/HBoxContainer/Slot 2/HBoxContainer/Rarity"
#@onready var weapon_name_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot_2_buy/HBoxContainer/Slot 2/HBoxContainer/WeaponName"
#@onready var price_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot_2_buy/HBoxContainer/Slot 2/HBoxContainer/Price"
#@onready var description_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot_2_buy/HBoxContainer/Slot 2/VBoxContainer/Description"
@onready var texture_rect_2: TextureRect = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/TextureRect/TextureRect"
@onready var weapon_name_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy/HBoxContainer/Slot 1/HBoxContainer/WeaponName"
@onready var rarity_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy/HBoxContainer/Slot 1/HBoxContainer/Rarity"
@onready var price_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy/HBoxContainer/Slot 1/HBoxContainer/Price"
@onready var description_2: Label = $"VBoxContainer/BuySlots and Stats/Buy_slots/BuySlot2/Slot2_buy/HBoxContainer/Slot 1/VBoxContainer/Description"

var buy_slot_weapons: Array = []

@onready var player := get_tree().current_scene.get_node("Player")
@onready var inventory := player.get_node("InventoryUi")
@onready var player_stats := player.get_node("stats")

func _ready():
	populate_buy_slots()
	connect_buy_signals()

func populate_buy_slots():
	buy_slot_weapons.clear()
	var weapons = WeaponDB.get_random(2)
	
	# Обновляем первый слот
	var weapon_1 = weapons[0]
	buy_slot_weapons.append(weapon_1)
	texture_rect_1.texture = weapon_1.icon
	weapon_name_1.text = weapon_1.weapon_name
	rarity_1.text = weapon_1.rarity
	price_1.text = str(weapon_1.price)+" "+tr("COINS")
	description_1.text = weapon_1.description
	
	# Обновляем второй слот
	var weapon_2 = weapons[1]
	buy_slot_weapons.append(weapon_2)
	texture_rect_2.texture = weapon_2.icon
	weapon_name_2.text = weapon_2.weapon_name
	rarity_2.text = weapon_2.rarity
	price_2.text = str(weapon_2.price)+" "+tr("COINS")
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
			print("Куплено зброю:", weapon.weapon_name)
		else:
			print("Немає вільних слотів в інвентарі.")
	else:
		print("Недостатньо золота для покупки.")

func find_first_free_inventory_slot() -> int:
	for i in inventory.slots.size():
		if inventory.slots[i].weapon == null:
			return i
	return -1
