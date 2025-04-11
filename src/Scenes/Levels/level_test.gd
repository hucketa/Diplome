extends Node2D

@onready var pause_screen: CanvasLayer = $Pause_Screen
@onready var player = %Player
@onready var exp_bar: ProgressBar = $UI/MarginContainer/VBoxContainer/HBoxContainer2/Exp_bar
@onready var label_2: Label = %Label2
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var shop_scene: PackedScene
@onready var spawner: Spawner_logic = $Spawner
@onready var label: Label = $UI/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var canvas_layer: CanvasLayer = $CanvasLayer

const BUFF_SCENE = preload("res://src/Scenes/Buffs/Buffstscn.tscn")

func _ready():
	#get_tree().debug_collisions_hint = true
	$UI.visible = true
	pause_screen.visible = false
	player.stats.connect("show_buff_cards", Callable(self, "_on_show_buff_cards"))
	player.stats.connect("died", Callable(self, "_on_died"))
	%GameOver.visible = false

	var has_any_save = false
	for i in range(1, 4):
		if GameManager.get_save_summary(i).exists:
			has_any_save = true
			break
	if has_any_save:
		_show_save_menu(false, true)
	else:
		_start_new_game()

func _process(_delta: float) -> void:
	%Health_bar.value = player.stats.get_health()
	exp_bar.value = player.stats.get_exp()
	label_2.text = tr("BALANCE") + ": " + str(round(player.stats.__coins))

func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_screen.visible = false

func _input(event):
	if event.is_action_pressed("Pause"):
		if not get_tree().paused:
			get_tree().paused = true
			pause_screen.visible = true


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/Scenes/Setting_w/settings.tscn")

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/Scenes/MainMenu/MainScene.tscn")

func _on_pause_ui_pressed() -> void:
	get_tree().paused = true
	pause_screen.visible = true

func _on_show_buff_cards() -> void:
	var buff_scene_instance = BUFF_SCENE.instantiate()
	get_tree().current_scene.add_child(buff_scene_instance)
	await get_tree().process_frame
	var player_position = player.global_position
	var buff_size = buff_scene_instance.get_rect().size
	buff_scene_instance.global_position = player_position - Vector2(buff_size.x / 2, buff_size.y * 0.6)

func _on_spawner_wave_finished() -> void:
	var window_size = get_viewport().get_visible_rect().size
	var center_position = window_size / 2
	await get_tree().process_frame
	player.global_position = center_position
	player.stats.__current_health = player.stats.__max_health
	shop_scene = load("res://src/shop/shop2.tscn")
	var shop_scene_instance = shop_scene.instantiate()
	canvas_layer.add_child(shop_scene_instance)
	var base_node = shop_scene_instance.get_node("Base")
	var shop_rect = base_node.get_rect()
	var shop_size = shop_rect.size
	var shop_control = shop_scene_instance.get_node("Base")
	shop_control.connect("shop_closed", Callable(self, "_on_control_shop_closed"))
	shop_control.connect("save_progress", Callable(self, "_on_save_game_menu"))
	get_tree().paused = true

func _on_control_shop_closed() -> void:
	for child in canvas_layer.get_children():
		child.queue_free()
	get_tree().paused = false
	_pick_up_experience()
	spawner.start_wave()
	shop_scene = null

func _on_spawner_wave_started() -> void:
	label.text = tr("WAWE") + ": " + str(spawner.get_current_wave())

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_new_game_pressed() -> void:
	respawn_player()
	player.stats._default_stats()
	player._clear_inventory()
	_clear_lost_xp()
	spawner.set_current_wave(0)
	%GameOver.visible = false
	get_tree().paused = false

func _on_load_game_pressed() -> void:
	_show_save_menu(false)

func _on_save_game_menu() -> void:
	_show_save_menu(true)

func _on_slot_selected(slot: int, is_saving: bool):
	if is_saving:
		GameManager.save_game(slot, player.stats, player.inventory_ui, spawner)
		print("Сохранено в слот", slot)
	else:
		var data = GameManager.load_game(slot)
		if data:
			player.stats.from_dict(data["player_stats"])
			player.inventory_ui.load_inventory_data(data["inventory"])
			spawner.set_current_wave(data.get("wave", 1))
			respawn_player()
		get_tree().paused = false
	%GameOver.visible = false


func _show_save_menu(is_saving: bool, block_cancel := false):
	var menu_scene = preload("res://src/Saves slots/SaveSlotsScene.tscn")
	var menu = menu_scene.instantiate()
	menu.is_saving = is_saving
	menu.block_cancel_button = block_cancel
	var new_canvas_layer = CanvasLayer.new()
	new_canvas_layer.name = "SaveMenuCanvas"
	new_canvas_layer.add_child(menu)
	add_child(new_canvas_layer)
	menu.connect("slot_selected", Callable(self, "_on_slot_selected").bind(is_saving))
	menu.connect("new_game_requested", Callable(self, "_start_new_game"))


func respawn_player():
	var center = get_viewport().size / 2
	player.global_position = center
	_clear_lost_xp()
	player.stats.revive()
	player.sprite.play("idle")

func _on_died():
	get_tree().paused = true
	%GameOver.visible = true

func _clear_lost_xp():
	for child in get_tree().get_current_scene().get_children():
		if child is Experience:
			child.queue_free()

func _start_new_game():
	player.stats._default_stats()
	player._clear_inventory()
	spawner.set_current_wave(0)
	respawn_player()
	%GameOver.visible = false
	get_tree().paused = false

func _pick_up_experience():
	for child in get_tree().get_current_scene().get_children():
		if child is Experience:
			player.stats.gain_experience(child.__experience)
			child.queue_free()
	#get_tree().paused = true


func _on_save_last_wave_pressed() -> void:
	_show_save_menu(true)
