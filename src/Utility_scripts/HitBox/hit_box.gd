extends Area2D

@export var damage: float = 1

func _ready():
	print("Хітбокс готовий. Урон:", damage)
	set_deferred("monitoring", false)

func activate():
	print("# Активуємо хитбокс.")
	set_deferred("monitoring", true)
	await get_tree().create_timer(0.1).timeout
	set_deferred("monitoring", false)
	print("# Вимкнено хитбокс після атаки.")


func get_damage() -> float:
	print("Запит урону:", damage)
	return damage
