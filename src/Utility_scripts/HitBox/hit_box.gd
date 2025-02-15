extends Area2D

@export var damage: float = 1.0

func _ready() -> void:
	print("Хітбокс готовий. Урон:", damage)
	set_deferred("monitoring", false)

func activate() -> void:
	print("# Активуємо хитбокс.")
	set_deferred("monitoring", true)
	await get_tree().create_timer(0.2).timeout
	set_deferred("monitoring", false)
	print("# Вимкнено хитбокс після атаки. monitoring =", monitoring)

func get_damage() -> float:
	print("Запит урону:", damage)
	return damage
