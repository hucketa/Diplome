extends Node2D

@onready var pause_screen: CanvasLayer = $Pause_Screen
@onready var player = %Player
@onready var exp_bar: ProgressBar = $UI/MarginContainer/VBoxContainer/HBoxContainer2/Exp_bar
@onready var label_2: Label = %Label2
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var control: Control = $Control

const BUFF_SCENE = preload("res://src/Scenes/Buffs/Buffstscn.tscn")

func _ready() -> void:
	control.show()
	get_tree().debug_collisions_hint = true
	$UI.visible = true
	pause_screen.visible = false
	%Resume.text = tr("BACK")
	%Main_Menu.text = tr("SETTINGS")
	%Exit.text = tr("MAIN_MENU")
	%Pause_ui.text = tr("PAUSE")

	player.stats.connect("show_buff_cards", Callable(self, "_on_show_buff_cards"))

func _process(_delta: float) -> void:
	%Health_bar.value = player.stats.get_health()
	exp_bar.value = player.stats.get_exp()
	label_2.text = tr("РІВЕНЬ") + ": " + str(player.stats.__coins)

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
