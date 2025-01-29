extends Area2D

@onready var timer: Timer = $Timer
@export var spawn_interval: float = 1.0

var nightborne = preload("res://nightborne.tscn")
var ZHEC = preload("res://zhec.tscn")
var skelet = preload("res://skeleton_enemy.tscn")
@onready var area: CollisionShape2D = $CollisionShape2D 

func _ready() -> void:
	if area:
		timer.wait_time = spawn_interval
		timer.one_shot = false
		timer.timeout.connect(spawn_monster)
		timer.start()
	else:
		print("Помилка: Не знайдено зону спавну або сцену монстра!")

func spawn_monster() -> void:
	randomize()
	if not area or not area.shape:
		print("Помилка: Відсутня зона спавну або форма колайдера!")
		return
	if area.shape is RectangleShape2D:
		var rect = area.shape.get_rect()
		var spawn_position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		var monster = nightborne.instantiate()
		monster.global_position = area.global_position + spawn_position
		get_tree().root.add_child(monster)
		print("Монстра заспавнено у:", monster.global_position)
	else:
		print("Помилка: Форма колайдера повинна бути RectangleShape2D!")
