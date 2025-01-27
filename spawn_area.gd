extends Area2D

@onready var timer: Timer = $Timer
@export var spawn_interval: float = 1.0

var monster_scene: PackedScene = preload("res://nightborne.tscn")
@onready var area: CollisionShape2D = $CollisionShape2D  # Ссылка на конкретный дочерний CollisionShape2D

func _ready() -> void:
	if area and monster_scene:
		timer.wait_time = spawn_interval
		timer.one_shot = false  # Убедимся, что таймер повторяется
		timer.timeout.connect(spawn_monster)
		timer.start()
	else:
		print("Ошибка: Не найдена зона спавна или сцена монстра!")

func spawn_monster() -> void:
	randomize()
	if not area or not area.shape:
		print("Ошибка: Отсутствует зона спавна или форма коллайдера!")
		return

	# Проверяем, что форма является RectangleShape2D
	if area.shape is RectangleShape2D:
		var rect = area.shape.get_rect()
		var spawn_position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		var monster = monster_scene.instantiate()
		monster.global_position = area.global_position + spawn_position
		get_tree().root.add_child(monster)
		print("Монстр заспавнен в:", monster.global_position)
	else:
		print("Ошибка: Форма коллайдера должна быть RectangleShape2D!")
