extends Node

@export var max_health: float = 60
@export var current_health: float = 60
@export var damage: float = 1
@export var armor: int = 0
@export var crit_chance: float = 0
@export var crit_multiplier: float = 2.0
@export var attack_speed: float = 1.0
@export var current_experience: int = 0
@export var experience_to_level_up: int = 100
@export var level: int = 1

signal health_changed(current_health)
signal died
signal level_up(new_level)

var is_dead: bool = false

func get_health() -> int:
	return max(current_health, 0)

func _ready():
	current_health = max_health

func take_damage(amount: int):
	if is_dead:
		return
	var reduced_damage = max(amount - armor, 1)
	current_health -= reduced_damage
	current_health = max(current_health, 0)
	emit_signal("health_changed", current_health)
	print("Отримано урон:", reduced_damage, "Поточне здоров'я:", current_health)
	if current_health <= 0 and not is_dead:
		is_dead = true
		emit_signal("died")
		die()

func heal(amount: int):
	if not is_dead:
		current_health = min(current_health + amount, max_health)
		emit_signal("health_changed", current_health)
		print("Відновлено здоров'я на:", amount)

func gain_experience(amount: int):
	current_experience += amount
	print("Отримано досвід:", amount, "Поточний досвід:", current_experience)
	while current_experience >= experience_to_level_up:
		current_experience -= experience_to_level_up
		level_uped()

func level_uped():
	level += 1
	experience_to_level_up = int(experience_to_level_up * 1.5)
	max_health += 20
	damage += 5
	current_health = max_health
	emit_signal("level_up", level)
	print("Вітаємо з новим рівнем:", level)

func calculate_damage() -> float:
	var is_critical = randf() < crit_chance
	var final_damage = damage * crit_multiplier if is_critical else damage
	if is_critical:
		print("Нанесено урон:", final_damage, "(Критичний удар!)")
	else:
		print("Нанесено урон:", final_damage)
	return final_damage

func die():
	print("Герой помер.")
