extends Node2D

@onready var pause_screen: CanvasLayer = $Pause_Screen

func _ready() -> void:
	$UI.visible = true
	pause_screen.visible = false

func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_screen.visible = false

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	#await get_tree().process_frame
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_exit_pressed() -> void:
	get_tree().paused = false
	#await get_tree().process_frame
	get_tree().change_scene_to_file("res://MainScene.tscn")

func _on_pause_ui_pressed() -> void:
	get_tree().paused = true
	pause_screen.visible = true
