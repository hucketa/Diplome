class_name Bullet
extends Node2D

@export var speed: float = 300.0
@export var direction: Vector2 = Vector2.RIGHT
@export var damage: float = 10.0
var __is_in_zone: bool = false
var __enemy_in_attack_range: EnemyBase = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

#func _ready():
	#print("🚀 Пуля создана! Позиция:", global_position, "Направление:", direction)

func _process(delta):
	position += direction * speed * delta

func __enemy_entered_attack_range(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is EnemyBase:
		__is_in_zone = true
		__enemy_in_attack_range = enemy
		__enemy_in_attack_range.take_damage(damage)
		queue_free()

func __enemy_exited_attack_range(area: Area2D) -> void:
	if __enemy_in_attack_range and __enemy_in_attack_range == area.get_parent():
		__enemy_in_attack_range = null
		__is_in_zone = false
