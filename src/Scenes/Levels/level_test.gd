extends Node2D

@onready var pause_screen: CanvasLayer = $Pause_Screen
@onready var player = %Player
@onready var exp_bar: ProgressBar = $UI/MarginContainer/VBoxContainer/HBoxContainer2/Exp_bar
@onready var label_2: Label = %Label2

func _ready() -> void:
	#get_tree().debug_collisions_hint = true
	$UI.visible = true
	pause_screen.visible = false
	%Resume.text = tr("BACK")
	%Main_Menu.text = tr("SETTINGS")
	%Exit.text = tr("MAIN_MENU")
	%Pause_ui.text = tr("PAUSE")

func _process(_delta: float) -> void:
		%Health_bar.value = player.stats.get_health()
		exp_bar.value = player.stats.get_exp()
		label_2.text = tr(&"LEVEL") + ": "+str(player.stats.get_lvl())

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
