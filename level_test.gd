extends Node2D

@onready var pause_screen: CanvasLayer = %Pause_Screen

func _ready():
	%UI.visible = true
	%Pause_Screen.visible = false

func _on_resume_pressed() -> void:
	%Pause_Screen.visible = false

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")
	%Pause_Screen.visible = false

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://MainScene.tscn")
	%Pause_Screen.visible = false

func _on_pause_ui_pressed() -> void:
	%Pause_Screen.visible = true
