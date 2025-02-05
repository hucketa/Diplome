extends Node2D

const enemy_nightborne = preload("res://src/Enemies/Nightborne/nightborne.tscn")
const enemy_skeleton = preload("res://src/Enemies/Sceleton/skeleton_enemy.tscn")
const enemy_reaper = preload("res://src/Enemies/Zhnec/zhec.tscn")
@onready var spawn_timer: Timer = $Area2D/SpawnTimer
# Затримка між хвилями
@export var wave_delay: float = 5.0
# Інтервал між спавном ворогів
@export var spawn_interval: float = 1.5
@onready var spawn_area: CollisionShape2D = $Area2D/CollisionShape2D
@onready var label: Label = $"../UI/MarginContainer/VBoxContainer/Label"

# Параметри хвиль
var current_wave: int = 0
var base_enemy_count: int = 5
var wave_multiplier: float = 1.3
var enemies_to_spawn: int = 0
var spawned_enemies: Array = []


func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))
	start_wave()

# Запуск нової хвилі
func start_wave():
	current_wave += 1
#	clear_enemies()
	label.text = "Хвиля " + str(current_wave)
	print("Початок хвилі:", current_wave)
	enemies_to_spawn = int(base_enemy_count * pow(wave_multiplier, current_wave))
	print("Кількість ворогів у цій хвилі:", enemies_to_spawn)
	spawn_timer.start()
	await get_tree().create_timer(wave_delay + (spawn_interval * enemies_to_spawn)).timeout
	start_wave()

# Викликається кожного разу, коли спрацьовує таймер спавну ворогів
func _on_SpawnTimer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
		print("Заспавнено ворога. Залишилося:", enemies_to_spawn)
	else:
		spawn_timer.stop()
		print("Всі вороги для хвилі", current_wave, "заспавнені.")

# Створення ворога
func spawn_enemy():
	var enemy_type = choose_enemy_type()
	var enemy_scene = get_enemy_scene(enemy_type)
	var random_position = get_random_point_in_area()
	var enemy = enemy_scene.instantiate()
	enemy.position = random_position
	spawned_enemies.append(enemy)
	match enemy_type:
		"skeleton":
			enemy.health = 10 + (current_wave * 2)
			enemy.movement_speed = 100 + randf_range(-10, 10)
			enemy.damage = 5 + (current_wave * 0.5)
		"nightborne":
			enemy.health = 8 + (current_wave * 1.5)
			enemy.movement_speed = 150 + randf_range(10, 20)
			enemy.damage = 4 + (current_wave * 0.4)
		"reaper":
			enemy.health = 20 + (current_wave * 3)
			enemy.movement_speed = 80 + randf_range(-5, 5)
			enemy.damage = 10 + (current_wave * 1.5)
	add_child(enemy)
	print("Заспавнено:", enemy_type, "у позиції:", random_position)

# Видалення всіх ворогів попередньої хвилі
#func clear_enemies():
#	for enemy in spawned_enemies:
#		if enemy and enemy.is_inside_tree():
#			enemy.queue_free()
#	spawned_enemies.clear()
#	print("Вороги попередньої хвилі очищені.")

# Вибір типу ворога залежно від номера хвилі
func choose_enemy_type() -> String:
	var roll = randf()
	if current_wave >= 30:
		if roll < 0.2:
			return "reaper"
		elif roll < 0.5:
			return "nightborne"
		else:
			return "skeleton"
	elif current_wave >= 15:
		if roll < 0.4:
			return "nightborne"
		else:
			return "skeleton"
	else:
		return "skeleton"

# Отримання сцени ворога за його типом
func get_enemy_scene(enemy_type: String) -> PackedScene:
	match enemy_type:
		"nightborne":
			return enemy_nightborne
		"reaper":
			return enemy_reaper
		_:
			return enemy_skeleton

# Генерація випадкової точки спавну всередині області
func get_random_point_in_area() -> Vector2:
	var shape = spawn_area.shape
	if shape is RectangleShape2D:
		var half_size = shape.size * 0.5
		return spawn_area.global_position + Vector2(
			randf_range(-half_size.x, half_size.x),
			randf_range(-half_size.y, half_size.y)
		)
	elif shape is CircleShape2D:
		var radius = shape.radius
		var angle = randf() * TAU
		var distance = sqrt(randf()) * radius
		return spawn_area.global_position + Vector2(cos(angle), sin(angle)) * distance
	return spawn_area.global_position
