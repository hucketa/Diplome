extends Area2D

# Таймер спавна врагов
@onready var spawn_timer: Timer = $SpawnTimer

# Сцены врагов для спавна
const ENEMY_SCENES: Dictionary = {
	"skelet": preload("res://skeleton_enemy.tscn"),
	"znec": preload("res://zhec.tscn"),
	"nightborne": preload("res://nightborne.tscn")
}

# Переменные волны
var wave_number: int = 1
var enemies_spawned: int = 0
var max_enemies_per_wave: int = 10
var max_enemies_on_screen: int = 10
# Активность волны
var wave_active: bool = false
var enemies_on_screen: int = 0

func _ready() -> void:
	print("[СИСТЕМА] Запуск спавнера.")
	if not $CollisionShape2D:
		print("[ПОМИЛКА] Не знайдено зону спавну!")
		return
	if not spawn_timer.timeout.is_connected(_on_SpawnTimer_timeout):
		spawn_timer.timeout.connect(_on_SpawnTimer_timeout)
	
	start_wave()

# Запуск новой волны
func start_wave() -> void:
	print("[ХВИЛЯ] Початок хвилі:", wave_number)
	
	wave_active = true
	enemies_spawned = 0
	max_enemies_per_wave = min(10 + 3 * wave_number, 100)
	
	spawn_timer.wait_time = get_spawn_rate()
	spawn_timer.start()

# Получение скорости спавна (чем выше сложность, тем быстрее спавн)
func get_spawn_rate() -> float:
	return max(1.5 * exp(-0.05 * wave_number), 0.5)

# Спавн одного врага
func _on_SpawnTimer_timeout() -> void:
	if enemies_spawned >= max_enemies_per_wave or enemies_on_screen >= max_enemies_on_screen:
		if enemies_spawned >= max_enemies_per_wave and enemies_on_screen == 0:
			wave_active = false
			wave_number += 1
			start_wave()
		return
	var enemy_type: String = get_random_enemy()
	var enemy_scene: PackedScene = ENEMY_SCENES[enemy_type]
	var spawn_position: Vector2 = get_random_spawn_position()
	var enemy = enemy_scene.instantiate()

	enemy.global_position = spawn_position
	# Добавляем врага в сцен (исправлено)
	if get_tree() and get_tree().root:
		get_tree().root.add_child(enemy)
	else:
		add_child(enemy)  # Если get_tree() временно не доступен
	enemies_on_screen += 1
	enemies_spawned += 1
	print("[СПАВН] Ворог заспавнений:", enemy_type, "у позиції:", spawn_position)
	print("[СТАТИСТИКА] Ворогів на екрані:", enemies_on_screen, "/", max_enemies_on_screen)
	print("[СТАТИСТИКА] Ворогів заспавнено у хвилі:", enemies_spawned, "/", max_enemies_per_wave)

# Выбор случайного типа врага
func get_random_enemy() -> String:
	var enemy_list: Array = ENEMY_SCENES.keys()
	return enemy_list[randi() % enemy_list.size()]

# Генерация случайной позиции спавна в пределах CollisionShape2D
func get_random_spawn_position() -> Vector2:
	var area: CollisionShape2D = $CollisionShape2D
	
	if area.shape is RectangleShape2D:
		var rect = area.shape.extents * 2
		return Vector2(
			randf_range(-rect.x / 2, rect.x / 2),
			randf_range(-rect.y / 2, rect.y / 2)
		) + area.global_position
	
	print("[ПОМИЛКА] Непідтримувана форма зони спавну!")
	return Vector2.ZERO
