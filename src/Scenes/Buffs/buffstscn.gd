extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var buttons = [
	$Baffs_block/First_button,
	$Baffs_block/Second_button,
	$Baffs_block/Third_button
]

enum Stats { HEALTH, DAMAGE, ARMOR, CRIT_CHANCE, ATTACK_SPEED }

const STAT_KEYS = {
	Stats.HEALTH: "stat_health",
	Stats.DAMAGE: "stat_damage",
	Stats.ARMOR: "stat_armor",
	Stats.CRIT_CHANCE: "stat_crit_chance",
	Stats.ATTACK_SPEED: "stat_attack_speed"
}

const CARDS_STATS = [
	{ "stat": Stats.HEALTH, "description": "HP_BUFF", "icon": "res://src/Scenes/Buffs/Buff_icons/hp_buff.webp" },
	{ "stat": Stats.DAMAGE, "description": "DAMAGE_BUFF", "icon": "res://src/Scenes/Buffs/Buff_icons/Attack_buff.webp" },
	{ "stat": Stats.ARMOR, "description": "ARMOR_BUFF", "icon": "res://src/Scenes/Buffs/Buff_icons/armor.png" },
	{ "stat": Stats.CRIT_CHANCE, "description": "CRIT_BUFF", "icon": "res://src/Scenes/Buffs/Buff_icons/crit_chace.png" },
	{ "stat": Stats.ATTACK_SPEED, "description": "AS_BUFF", "icon": "res://src/Scenes/Buffs/Buff_icons/attack_speed.png" }
]

func get_random_card() -> Dictionary:
	return CARDS_STATS.pick_random()

func fill_button(button: Button, card: Dictionary) -> void:
	var details = button.get_node_or_null("Button_details")
	if details and not card.is_empty():
		var stat_name_label = details.get_node_or_null("Stat_name")
		if stat_name_label:
			stat_name_label.text = tr(STAT_KEYS.get(card["stat"], "stat_unknown"))
			stat_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			stat_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var stat_icon = details.get_node_or_null("Stat_ico")
		if stat_icon:
			var texture = ResourceLoader.load(card["icon"])
			if texture and texture is Texture2D:
				stat_icon.texture = texture
			else:
				print_debug("Ошибка загрузки иконки: ", card["icon"])
			stat_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var description_label = details.get_node_or_null("Description")
		if description_label:
			description_label.text = tr("desc_" + card["description"].to_lower())
			description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _ready() -> void:
	color_rect.color = Color(0.1, 0.1, 0.1, 0.8)
	var shuffled_cards = CARDS_STATS.duplicate()
	shuffled_cards.shuffle()
	for i in range(buttons.size()):
		fill_button(buttons[i], shuffled_cards[i])
