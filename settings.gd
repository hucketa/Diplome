extends Control

@onready var loudness_bar: ProgressBar = %Loudness_bar
@onready var brightness_bar: ProgressBar = %Brightness_bar
const GameStateScript = preload("res://src/GameStateScript/GameStateScript.gd")
var game_state_script_instance = GameStateScript.new()  # Создаем экземпляр

func _on_button_pressed():
	get_tree().change_scene_to_file("res://MainScene.tscn")

func _on_increase_pressed():
	if %Loudness_bar.value < 100:
		%Loudness_bar.value += 1

func _on_decrease_2_pressed():
	if %Loudness_bar.value > 0:
		%Loudness_bar.value -= 1

func _on_decrease_pressed():
	if %Brightness_bar.value > 0:
		%Brightness_bar.value -= 1

func _on_increase_2_pressed():
	if %Brightness_bar.value < 100:
		%Brightness_bar.value += 1

func _on_sound_check_pressed():
	var current_iterator = game_state_script_instance.get_iterator_for_sound()
	game_state_script_instance.set_iterator_for_sound(not current_iterator)
	%SoundIcon.flip_v = not current_iterator

func _on_music_check_pressed():
	var current_iterator = game_state_script_instance.get_iterator_for_music()
	game_state_script_instance.set_iterator_for_music(not current_iterator)
	%MusicIcon.flip_v = not current_iterator
