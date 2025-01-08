extends Node

var sound_iterator
var music_iterator

func set_iterator_for_sound(fl: bool) -> void:
	sound_iterator = fl

func get_iterator_for_sound():
	return sound_iterator

func set_iterator_for_music(fl: bool) -> void:
	music_iterator = fl

func get_iterator_for_music():
	return music_iterator
