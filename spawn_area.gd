extends Node

@export var spawn_area: Area2D
@export var player: Node2D

const NIGHTBORNE = preload("res://nightborne.tscn")
const ZHEC = preload("res://zhec.tscn")
const SKELETON_ENEMY = preload("res://skeleton_enemy.tscn")
@onready var wave_number: Label = $"../UI/MarginContainer/VBoxContainer/WaweNumber"
@onready var timer: Timer = $Timer

var base_enemies: int = 10
var growth_factor: int = 5
var growth_power: float = 1.2
var base_interval: float = 3.7
var interval_decay: float = 0.15
var current_wave: int = 0
var spawned_enemies: Array[Node2D] = []

func start_wave() -> void:
	remove_previous_wave_enemies()
	current_wave += 1
	wave_number.text = "Wave: " + str(current_wave)

	var total_enemies: int = int(base_enemies + growth_factor * pow(current_wave + 1, growth_power))
	var skeletons: int = int(0.6 * total_enemies)
	var nightborns: int = int(0.3 * total_enemies)
	var reapers: int = int(0.1 * total_enemies) if current_wave >= 5 else 0

	print("Wave ", current_wave, " - Skeletons: ", skeletons, ", Nightborns: ", nightborns, ", Reapers: ", reapers)

	spawn_enemies(SKELETON_ENEMY, skeletons)
	spawn_enemies(NIGHTBORNE, nightborns)
	spawn_enemies(ZHEC, reapers)

func spawn_enemies(enemy_scene: PackedScene, count: int) -> void:
	if not enemy_scene or count <= 0:
		return

	for i in range(count):
		spawn_wave_monsters(enemy_scene)

func spawn_wave_monsters(enemy_scene: PackedScene = null) -> void:
	if not spawn_area:
		print("Ошибка: SpawnArea не задана!")
		return

	var shape: CollisionShape2D = spawn_area.get_node("CollisionShape2D") as CollisionShape2D
	
	if not shape or not shape.shape is RectangleShape2D:
		print("Ошибка: Форма коллайдера должна быть RectangleShape2D!")
		return

	var rect_shape: RectangleShape2D = shape.shape
	var spawn_position = Vector2(
		randf_range(-rect_shape.extents.x, rect_shape.extents.x),
		randf_range(-rect_shape.extents.y, rect_shape.extents.y)
	)

	spawn_position += shape.global_position

	var enemy = (enemy_scene if enemy_scene else NIGHTBORNE).instantiate()
	enemy.global_position = spawn_position
	get_tree().root.add_child(enemy)
	spawned_enemies.append(enemy)
	print("Монстр заспавнен в:", enemy.global_position)

func remove_previous_wave_enemies() -> void:
	for enemy in spawned_enemies:
		if enemy and enemy.is_inside_tree():
			enemy.queue_free()
	spawned_enemies.clear()


func _on_ready() -> void:
	var shape: CollisionShape2D = get_tree().get_node("CollisionShape2D") as CollisionShape2D
	if not shape or not shape.shape is RectangleShape2D:
		print("Ошибка: Форма коллайдера должна быть RectangleShape2D!")
		return
	start_wave()
