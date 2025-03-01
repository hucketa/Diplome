class_name PlayerStats extends Node

@export var __max_health: float = 100
@export var __current_health: float = 100
@export var __damage: float = 100
@export var __armor: int = 0
@export var __crit_chance: float = 0
@export var __crit_multiplier: float = 0
@export var __attack_speed: float = 2.0
@export var __current_experience: int = 0
@export var __experience_to_level_up: int = 5
@export var __level: int = 1

signal health_changed(current_health)
signal died
signal level_up(new_level)

var is_dead: bool = false

func get_health() -> int:
	return max(__current_health, 0)

func get_exp() -> int:
	return __current_experience

func get_lvl() -> int:
	return __level

func _ready():
	__current_health = __max_health

func take_damage(amount: int):
	if is_dead:
		return
	var reduced_damage = max(amount - __armor, 1)
	__current_health -= reduced_damage
	__current_health = max(__current_health, 0)
	emit_signal("health_changed", __current_health)
	print("Отримано урон:", reduced_damage, "Поточне здоров'я:", __current_health)
	if __current_health <= 0 and not is_dead:
		is_dead = true
		emit_signal("died")
		die()

func heal(amount: int):
	if not is_dead:
		__current_health = min(__current_health + amount, __max_health)
		emit_signal("health_changed", __current_health)
		print("Відновлено здоров'я на:", amount)

func gain_experience(amount: int):
	__current_experience += amount
	print("Отримано досвід:", amount, "Поточний досвід:", __current_experience)
	while __current_experience >= __experience_to_level_up:
		__current_experience -= __experience_to_level_up
		level_uped()

func level_uped():
	__level += 1
	__experience_to_level_up = int(__experience_to_level_up * 1.5)
	__max_health += 20
	__damage += 5
	__current_health = __max_health
	emit_signal("level_up", __level)
	print("Вітаємо з новим рівнем:", __level)

func calculate_damage() -> float:
	var is_critical = randf() < __crit_chance
	var final_damage = __damage * __crit_multiplier if is_critical else __damage
	if is_critical:
		print("Нанесено урон:", final_damage, "(Критичний удар!)")
	else:
		print("Нанесено урон:", final_damage)
	return final_damage

func die():
	print("Герой помер.")
