class_name PlayerStats
extends Node

enum Stats { HEALTH, DAMAGE, ARMOR, CRIT_CHANCE, ATTACK_SPEED }

@export var __max_health: float = 5
@export var __current_health: float = 1
@export var __damage: float = 10
@export var __armor: int = 0
@export var __crit_chance: float = 0.01
@export var __crit_multiplier: float = 2.0
@export var __attack_speed: float = 1
@export var __current_experience: float = 0
@export var __experience_to_level_up: float = 15
@export var __level: int = 1
@export var __coins: float = 0


signal health_changed(current_health)
signal died
signal level_up(new_level)
signal show_buff_cards

var is_dead: bool = false
var buff_effects = {}

func _ready():
	buff_effects = {
		Stats.HEALTH: func(value): __max_health += value; __current_health = __max_health,
		Stats.DAMAGE: func(value): __damage += value,
		Stats.ARMOR: func(value): __armor += int(value),
		Stats.CRIT_CHANCE: func(value): __crit_chance += value,
		Stats.ATTACK_SPEED: func(value): __attack_speed += value
	}

func get_health() -> int:
	return (__current_health/__max_health)*100

func get_exp() -> float:
	return (__current_experience / __experience_to_level_up) * 100

func get_lvl() -> int:
	return __level

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

func get_coins() -> float:
	return __coins

func heal(amount: int):
	if not is_dead:
		__current_health = min(__current_health + amount, __max_health)
		emit_signal("health_changed", __current_health)
		print("Відновлено здоров'я на:", amount)

func gain_experience(amount: float):
	__current_experience += amount
	print("Отримано досвід:", amount, "Поточний досвід:", __current_experience)
	print(str(__experience_to_level_up)+"не вистачає")
	while __current_experience >= __experience_to_level_up:
		__current_experience -= __experience_to_level_up
		level_uped()

func level_uped():
	__level += 1
	var extra_xp = 3 if __level <= 3 else 3 + (__level - 3) / 3
	__experience_to_level_up += extra_xp * 2
	emit_signal("level_up", __level)
	emit_signal("show_buff_cards")
	print("Вітаємо з новим рівнем:", __level)

func calculate_damage() -> float:
	print(__coins)
	var is_critical = randf() < __crit_chance
	var final_damage = __damage * __crit_multiplier if is_critical else __damage
	if is_critical:
		print("Нанесено урон:", final_damage, "(Критичний удар!)")
	else:
		print("Нанесено урон:", final_damage)
	return final_damage

func apply_buff(buff_type: int, value: float) -> void:
	if buff_effects.has(buff_type):
		buff_effects[buff_type].call(value)

func die():
	print("Герой помер.")
	
func gain_coins(amount: float):
	__coins += amount
	print("Отримано монет:", amount, "Всього монет:", __coins)

func print_stats() -> void:
	print("# Статистика гравця:")
	print("  - Здоров'я:", __current_health, "/", __max_health)
	print("  - Урон:", __damage)
	print("  - Броня:", __armor)
	print("  - Шанс критичного удару:", __crit_chance * 100, "%")
	print("  - Множник критичного удару:", __crit_multiplier, "x")
	print("  - Швидкість атаки:", __attack_speed)
	print("  - Досвід:", __current_experience, "/", __experience_to_level_up, "(", str(get_exp()), "% )")
	print("  - Рівень:", __level)
	print("  - Монети:", __coins)

func to_dict() -> Dictionary:
	return {
		"max_health": __max_health,
		"current_health": __current_health,
		"damage": __damage,
		"armor": __armor,
		"crit_chance": __crit_chance,
		"crit_multiplier": __crit_multiplier,
		"attack_speed": __attack_speed,
		"current_experience": __current_experience,
		"experience_to_level_up": __experience_to_level_up,
		"level": __level,
		"coins": __coins
	}

func from_dict(data: Dictionary) -> void:
	__max_health = data.get("max_health", 5)
	__current_health = data.get("current_health", 1)
	__damage = data.get("damage", 10)
	__armor = data.get("armor", 0)
	__crit_chance = data.get("crit_chance", 0.01)
	__crit_multiplier = data.get("crit_multiplier", 2.0)
	__attack_speed = data.get("attack_speed", 1)
	__current_experience = data.get("current_experience", 0)
	__experience_to_level_up = data.get("experience_to_level_up", 15)
	__level = data.get("level", 1)
	__coins = data.get("coins", 5)

func revive():
	is_dead = false
	if __current_health <= 0:
		__current_health = __max_health
	emit_signal("health_changed", __current_health)

func _default_stats():
	__max_health = 5
	__current_health = __max_health
	__damage = 10
	__armor = 0
	__crit_chance = 0.01
	__crit_multiplier = 2.0
	__attack_speed = 1
	__current_experience = 0
	__experience_to_level_up = 15
	__level = 1
	__coins = 0
	emit_signal("health_changed", __current_health)
