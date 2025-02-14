extends CharacterBody2D

@export var movement_speed: float = 60.0
@export var health: float = 40
@export var damage: float = 1
@export var armor: int = 0
@export var attack_range: float = 100.0  # Радіус атаки
@export var attack_delay: float = 0.450  # Затримка між атаками
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_timer = Timer.new()

var is_attacking: bool = false
var push_strength: float = 200.0

func _ready() -> void:
	print("NightBorne ініціалізовано. Додавання таймера атаки.")
	add_child(attack_timer)
	attack_timer.wait_time = attack_delay
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	print("Таймер атаки налаштовано: затримка = ", attack_delay)

func _on_area_entered(area: Area2D) -> void:
	print("Виявлено зону входу: ", area.name)
	if area.is_in_group("enemies"):
		var direction = (area.global_position - global_position).normalized()
		print("Напрям відштовхування: ", direction)
		var push_velocity = direction * push_strength
		print("Застосування імпульсу відштовхування: ", push_velocity)
		area.velocity = push_velocity
		print("Об'єкт з групи 'enemies' відштовхнуто.")

func _physics_process(delta: float) -> void:
	print("Фізичний процес. Перевірка гравця...")
	if player and is_instance_valid(player):
		print("Гравець знайдений. Обчислення відстані...")
		var distance_to_player = global_position.distance_to(player.global_position)
		print("Відстань до гравця: ", distance_to_player)
		var direction = (player.global_position - global_position).normalized()
		print("Напрямок до гравця: ", direction)
		if distance_to_player > attack_range:
			print("Гравець поза зоною атаки. Переміщення...")
			velocity = direction * movement_speed
			move_and_slide()
			print("Персонаж перемістився в напрямку: ", direction)
			face_player(direction)
			play_walk_animation()
		else:
			print("Гравець у зоні атаки.")
			if not is_attacking:
				print("Початок атаки.")
				start_attack()
				play_attack_animation()

func start_attack() -> void:
	print("Запуск атаки...")
	if is_attacking:
		print("Атака вже виконується. Переривання.")
		return
	is_attacking = true
	attack_timer.start()
	print("Таймер атаки запущено.")

func _on_attack_timeout() -> void:
	print("Таймер атаки закінчився. Перевірка можливості атаки...")
	if player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		print("Поточна відстань до гравця: ", distance_to_player)

		if distance_to_player <= attack_range:
			print("Гравець у зоні атаки! Завдаємо шкоди.")
			player.take_damage(damage)
			print("Гравець отримав шкоду: ", damage)
			is_attacking = false
		else:
			print("Гравець вийшов із зони атаки. Атака скасована.")
			is_attacking = false

func face_player(direction: Vector2) -> void:
	print("Поворот персонажа у бік гравця.")
	$NightBorne.flip_h = direction.x < 0
	print("flip_h встановлено у: ", $NightBorne.flip_h)

func play_walk_animation():
	print("Запуск анімації ходьби.")
	$NightBorne.play("walk")

func play_die_animation():
	print("Запуск анімації смерті.")
	$NightBorne.play("die")

func play_take_damage_animation():
	print("Запуск анімації отримання шкоди.")
	$NightBorne.play("take_damage")

func play_idle_animation():
	print("Запуск анімації очікування.")
	$NightBorne.play("idle")

func play_attack_animation():
	print("Запуск анімації атаки.")
	$NightBorne.play("attack")

func take_damage(amount: float) -> void:
	print("Отримано шкоду: ", amount, "Поточна броня: ", armor)
	var reduced_damage = max(amount - armor, 1)
	print("Фактично отримана шкода (з урахуванням броні): ", reduced_damage)
	play_take_damage_animation()
	health -= reduced_damage
	print("Залишилось здоров'я: ", health)

	if health <= 0:
		print("Здоров'я на нулі. Ворог помирає.")
		$NightBorne.play("die")
		die()

func die() -> void:
	print("NightBorne знищено.")
	play_die_animation()
	await get_tree().create_timer(0.250).timeout
	print("Видалення об'єкта зі сцени...")
	queue_free()
