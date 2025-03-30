extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var buttons = [
	$Baffs_block/First_button,
	$Baffs_block/Second_button,
	$Baffs_block/Third_button
]

enum Stats { HEALTH, DAMAGE, ARMOR, CRIT_CHANCE, ATTACK_SPEED }

const STAT_NAMES = {
	Stats.HEALTH: "Здоров'я",
	Stats.DAMAGE: "Урон",
	Stats.ARMOR: "Броня",
	Stats.CRIT_CHANCE: "Шанс крит. удару",
	Stats.ATTACK_SPEED: "Швидкість атаки"
}

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

const BUFF_VALUES = {
	Stats.HEALTH: 20,
	Stats.DAMAGE: 2,
	Stats.ARMOR: 1,
	Stats.CRIT_CHANCE: 0.05,
	Stats.ATTACK_SPEED: 0.2
}

func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	color_rect.color = Color(0.1, 0.1, 0.1, 0.8)
	var shuffled_cards = CARDS_STATS.duplicate()
	shuffled_cards.shuffle()
	for i in range(buttons.size()):
		var card = shuffled_cards[i]
		fill_button(buttons[i], card)
		buttons[i].set_meta("card", card)
		buttons[i].connect("pressed", Callable(self, "_on_buff_button_pressed").bind(buttons[i]))

func fill_button(button: Button, card: Dictionary) -> void:
	var details = button.get_node_or_null("Button_details")
	if details:
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
				print_debug("Помилка завантаження іконки: ", card["icon"])
			stat_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var description_label = details.get_node_or_null("Description")
		if description_label:
			description_label.text = tr("desc_" + card["description"].to_lower())
			description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _on_buff_button_pressed(button: Button) -> void:
	var card: Dictionary = button.get_meta("card")
	var stat = card["stat"]
	var buff_value = BUFF_VALUES[stat]
	var player = get_tree().current_scene.get_node("Player")
	if player:
		player.stats.apply_buff(stat, buff_value)
		var buff_name = STAT_NAMES.get(stat, "Невідомий бафф")
	else:
		print("Помилка: гравець не знайдений!")
	get_tree().paused = false
	player.stats.print_stats()
	queue_free()
	
