extends Button

var slot_index: int
var inventory: Node
var weapon_data: WeaponData
var player: CharacterBody2D
signal inventory_changed 

@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var name_label: Label = $VBoxContainer/Label
@onready var confirm_dialog: ConfirmationDialog = $ConfirmationDialog

func set_player(a: CharacterBody2D):
	player = a

func update_display(data: WeaponData, index: int, inv: Node):
	weapon_data = data
	slot_index = index
	inventory = inv
	if data == null:
		texture_rect.texture = null
		name_label.text = ""
		return
	texture_rect.texture = data.icon if data.icon else null
	name_label.text = data.weapon_name

func _ready() -> void:
	update_display(null, 0,null)
	update_display(null, 1,null)
	update_display(null, 2,null)
	update_display(null, 3,null)
	

func _on_confirmed():
	if inventory and inventory.has_method("remove_weapon"):
		inventory.remove_weapon(slot_index)
		player.stats.__coins += weapon_data.price
		emit_signal("inventory_changed")
		texture_rect.texture = null
		name_label.text = ""
		weapon_data = null


func _on_pressed() -> void:
	if weapon_data != null:
		confirm_dialog.popup_centered()

func _on_confirmation_dialog_canceled() -> void:
	pass
