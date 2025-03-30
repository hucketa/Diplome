class_name Experience
extends Node2D

@onready var player = get_tree().get_first_node_in_group(&"Player")
var __player_in_attack_range : PlayerCharacterBody = null
var __experience: float = 1

func _process(delta: float) -> void:
	if __player_in_attack_range != null and __experience!=0:
		print("ff")
		player.stats.gain_experience(__experience)
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	__player_in_attack_range = area.get_parent()

func _on_area_2d_area_exited(area: Area2D) -> void:
	__player_in_attack_range = null
	
func set_experience(a: float) -> void:
	if a >= 0:
		__experience = a
