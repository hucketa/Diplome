class_name Weapon
extends Node2D

@export var damage_multiplier: float = 1.0

var __attacking: bool = false
var __flip_hei: bool = false
var attack_speed: float = 1.0
var stats = null
var player_ref = null

signal attack_started
signal attack_finished

func set_flip(h: bool) -> void:
	__flip_hei = h

func get_flip() -> bool:
	return __flip_hei

func _ready():
	pass
	#var player = get_tree().get_first_node_in_group("Player")
	#if player == null:
	#	print("Ошибка: Игрок не найден!")
	#	return
	#stats = player.get("stats")
	#if stats == null:
	#	print("Ошибка: Статистика игрока не найдена!")
	#	return
	#var attack_speed_value = stats.get("__attack_speed")
	#if attack_speed_value == null:
	#	print("Ошибка: Скорость атаки не найдена!")
	#	return
	#attack_speed = 1.0 / attack_speed_value

func set_player(p: Node):
	player_ref = p
	if player_ref == null:
		print("Ошибка: Игрок не установлен!")
		return
	stats = player_ref.get("stats")
	if stats == null:
		print("Ошибка: Статистика игрока не найдена!")
		return
	var attack_speed_value = stats.get("__attack_speed")
	if attack_speed_value == null:
		print("Ошибка: Скорость атаки не найдена!")
		return
	attack_speed = 1.0 / float(attack_speed_value)

func attack():
	if __attacking:
		return
	__attacking = true
	attack_started.emit()
	await get_tree().create_timer(attack_speed).timeout
	attack_completed()

func attack_completed():
	__attacking = false
	attack_finished.emit()
