extends Control

signal slot_selected(slot: int)
signal slot_deleted(slot: int)
signal new_game_requested
signal closed()

@export var is_saving: bool = false
@export var block_cancel_button: bool = false

@onready var slot_1: Button = $VBoxContainer2/VBoxContainer/slot1/Slot1
@onready var del_1: Button = $VBoxContainer2/VBoxContainer/slot1/Del1
@onready var slot_2: Button = $VBoxContainer2/VBoxContainer/slot2/Slot2
@onready var del_2: Button = $VBoxContainer2/VBoxContainer/slot2/Del2
@onready var slot_3: Button = $VBoxContainer2/VBoxContainer/slot3/Slot3
@onready var del_3: Button = $VBoxContainer2/VBoxContainer/slot3/Del3
@onready var new_game: Button = $VBoxContainer2/HBoxContainer/NewGame
@onready var cancel_button: Button = $VBoxContainer2/HBoxContainer2/Cancel

@onready var slot_buttons := [slot_1, slot_2, slot_3]
@onready var delete_buttons := [del_1, del_2, del_3]

@onready var popup: Popup = $Popup
@onready var popup_label: Label = $Popup/PanelContainer/VBoxContainer/Label
@onready var popup_yes: Button = $Popup/PanelContainer/VBoxContainer/Buttons/Yes
@onready var popup_no: Button = $Popup/PanelContainer/VBoxContainer/Buttons/No

var pending_slot: int = -1
var pending_delete_slot: int = -1

func _ready():
	_update_slots()

	for i in range(3):
		slot_buttons[i].connect("pressed", Callable(self, "_on_slot_pressed").bind(i + 1))
		delete_buttons[i].connect("pressed", Callable(self, "_on_delete_pressed").bind(i + 1))

	new_game.connect("pressed", Callable(self, "_on_new_game_pressed"))
	cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))
	popup_yes.connect("pressed", Callable(self, "_on_popup_yes"))
	popup_no.connect("pressed", Callable(self, "_on_popup_no"))

	if block_cancel_button:
		cancel_button.disabled = true

func _update_slots():
	for i in range(3):
		var info = GameManager.get_save_summary(i + 1)
		if info.exists:
			slot_buttons[i].text = tr("SAVE_SLOT_INFO") % [i + 1, info.level, info.wave, info.coins]
			slot_buttons[i].disabled = false
			delete_buttons[i].disabled = false
		else:
			slot_buttons[i].text = tr("SAVE_SLOT_EMPTY") % (i + 1)
			slot_buttons[i].disabled = not is_saving
			delete_buttons[i].disabled = true
	new_game.disabled = is_saving


func _on_slot_pressed(slot: int):
	var info = GameManager.get_save_summary(slot)
	if is_saving and info.exists:
		pending_slot = slot
		pending_delete_slot = -1
		popup_label.text = tr("OVERWRITE_SLOT")
		popup_yes.text = tr("YES")
		popup_no.text = tr("NO") #% slot
		popup.popup_centered()
	else:
		emit_signal("slot_selected", slot)
		queue_free()

func _on_delete_pressed(slot: int):
	pending_delete_slot = slot
	pending_slot = -1
	popup_label.text = tr("DELETE_SLOT") #% slot
	popup_yes.text = tr("YES")
	popup_no.text = tr("NO")
	popup.popup_centered()

func _on_popup_yes():
	if pending_slot != -1:
		emit_signal("slot_selected", pending_slot)
		queue_free()
	elif pending_delete_slot != -1:
		GameManager.delete_save(pending_delete_slot)
		_update_slots()
		pending_delete_slot = -1
	popup.hide()

func _on_popup_no():
	pending_slot = -1
	pending_delete_slot = -1
	popup.hide()

func _on_new_game_pressed():
	emit_signal("new_game_requested")
	queue_free()

func _on_close_pressed():
	emit_signal("closed")
	queue_free()

func _on_cancel_pressed() -> void:
	emit_signal("closed")
	queue_free()
