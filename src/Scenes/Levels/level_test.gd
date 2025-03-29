extends Node2D

@onready var pause_screen: CanvasLayer = $Pause_Screen
@onready var player = %Player
@onready var exp_bar: ProgressBar = $UI/MarginContainer/VBoxContainer/HBoxContainer2/Exp_bar
@onready var label_2: Label = %Label2
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var shop_scene: PackedScene
@onready var spawner: Node2D = $Spawner

var canvas_layer: CanvasLayer

const BUFF_SCENE = preload("res://src/Scenes/Buffs/Buffstscn.tscn")

func _ready() -> void:
	get_tree().debug_collisions_hint = true
	$UI.visible = true
	pause_screen.visible = false
	player.stats.connect("show_buff_cards", Callable(self, "_on_show_buff_cards"))

func _process(_delta: float) -> void:
	%Health_bar.value = player.stats.get_health()
	exp_bar.value = player.stats.get_exp()
	label_2.text = tr("BALANCE") + ": " + str(player.stats.__coins)


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_screen.visible = false

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
	var viewport_size = get_viewport().size
	var center_position = viewport_size / 2
	player.global_position = center_position
	shop_scene = load("res://src/shop/shop2.tscn")
	var shop_scene_instance = shop_scene.instantiate()
	canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(shop_scene_instance)
	get_tree().current_scene.add_child(canvas_layer)
	var base_node = shop_scene_instance.get_node("Base")
	var shop_rect = base_node.get_rect()
	var shop_size = shop_rect.size
	shop_scene_instance.global_position = player.global_position - 1.70*(shop_size / 2)
	var shop_control = shop_scene_instance.get_node("Base")
	shop_control.connect("shop_closed", Callable(self, "_on_control_shop_closed"))
	get_tree().paused = true


func _on_control_shop_closed() -> void:
	canvas_layer.queue_free()
	get_tree().paused = false
	spawner.start_wave()
	shop_scene = null
