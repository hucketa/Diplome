extends Area2D

@export var damage: float = 1.0

func _ready() -> void:
	print("Хітбокс готовий. Урон:", damage)


func get_damage() -> float:
	print("Запит урону:", damage)
	return damage
