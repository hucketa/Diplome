extends Node2D

const enemy_nightborne = preload("res://src/Enemies/Nightborne/nightborne.tscn")
const enemy_skeleton = preload("res://src/Enemies/Sceleton/skeleton_enemy.tscn")
const enemy_reaper = preload("res://src/Enemies/Zhnec/zhec.tscn")

@onready var spawn_timer: Timer = $Area2D/SpawnTimer
@onready var spawn_area: CollisionShape2D = $Area2D/CollisionShape2D
@onready var label: Label = $"../UI/MarginContainer/VBoxContainer/Label"

@export var wave_delay: float = 5.0
@export var spawn_interval: float = 1.5

var current_wave: int = 0
var base_enemy_count: int = 4
var wave_multiplier: float = 1.2
var enemies_to_spawn: int = 0
var spawned_enemies: Array = []

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_SpawnTimer_timeout)
	start_wave()

func start_wave():
	current_wave += 1
	label.text = "Хвиля " + str(current_wave)
	print("Початок хвилі:", current_wave)
	
	enemies_to_spawn = int(base_enemy_count * pow(wave_multiplier, current_wave))
	print("Кількість ворогів у цій хвилі:", enemies_to_spawn)

	spawn_timer.start()
	
	# Запуск нового таймера для отсчета перед следующей волной
	get_tree().create_timer(wave_delay + spawn_interval * enemies_to_spawn).timeout.connect(start_wave, CONNECT_ONE_SHOT)

func _on_SpawnTimer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		print("Заспавнено ворога. Залишилося:", enemies_to_spawn)
	else:
		spawn_timer.stop()
		print("Всі вороги для хвилі", current_wave, "заспавнені.")

func spawn_enemy():
	var enemy_type = choose_enemy_type()
	var enemy_scene = get_enemy_scene(enemy_type)
	var enemy = enemy_scene.instantiate()
	enemy.position = get_random_point_in_area()
	spawned_enemies.append(enemy)
	
	# Параметры врагов в зависимости от типа
	var stats = {
		"skeleton": { "health": 10 + current_wave * 2, "speed": 100, "damage": 5 + current_wave * 0.5 },
		"nightborne": { "health": 8 + current_wave * 1.5, "speed": 150, "damage": 4 + current_wave * 0.4 },
		"reaper": { "health": 20 + current_wave * 3, "speed": 80, "damage": 10 + current_wave * 1.5 }
	}
	
	if stats.has(enemy_type):
		enemy.health = stats[enemy_type]["health"]
		enemy.movement_speed = stats[enemy_type]["speed"] + randf_range(-10, 10)
		enemy.damage = stats[enemy_type]["damage"]
	
	add_child(enemy)
	print("Заспавнено:", enemy_type, "у позиції:", enemy.position)

func choose_enemy_type() -> String:
	var probabilities = {
		30: {"reaper": 0.2, "nightborne": 0.3, "skeleton": 0.5},
		15: {"skeleton": 0.4, "nightborne": 0.6},
		 0: {"skeleton": 1.0}
	}
	for wave_threshold in probabilities.keys():
		if current_wave >= wave_threshold:
			var roll = randf()
			var cumulative = 0.0
			for enemy in probabilities[wave_threshold].keys():
				cumulative += probabilities[wave_threshold][enemy]
				if roll < cumulative:
					return enemy
	return "skeleton" 


func get_enemy_scene(enemy_type: String) -> PackedScene:
	match enemy_type:
		"nightborne":
			return enemy_nightborne
		"reaper":
			return enemy_reaper
		_:
			return enemy_skeleton

func get_random_point_in_area() -> Vector2:
	var shape = spawn_area.shape
	var area_position = spawn_area.global_position

	if shape is RectangleShape2D:
		var half_size = shape.size * 0.5
		return area_position + Vector2(randf_range(-half_size.x, half_size.x), randf_range(-half_size.y, half_size.y))
	elif shape is CircleShape2D:
		var radius = shape.radius
		var angle = randf() * TAU
		var distance = sqrt(randf()) * radius
		return area_position + Vector2(cos(angle), sin(angle)) * distance

	return area_position
