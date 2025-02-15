extends CharacterBody2D

@export var movement_speed: float = 30.0
@export var health: float = 500
@export var damage: float = 1
@export var attack_range: float = 70.0
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_timer = Timer.new()
@onready var skeleton: AnimatedSprite2D = $Skeleton

var is_attacking: bool = false
var is_dead: bool = false
var attack_duration: float = 0.5

func _ready() -> void:
	print("Скелет ініціалізовано. Додавання таймера атаки.")
	add_child(attack_timer)
	if skeleton and skeleton.get_sprite_frames().has_animation("attack"):
		attack_duration = skeleton.get_sprite_frames().get_frame_count("attack") / skeleton.get_sprite_frames().get_animation_speed("attack")
	
	attack_timer.wait_time = attack_duration
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	
	print("Таймер атаки налаштовано: затримка = ", attack_duration)

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player) and not is_dead:
		print("Фізичний процес. Перевірка гравця...")
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()

		print("Відстань до гравця: ", distance_to_player)
		print("Напрямок до гравця: ", direction)

		if distance_to_player > attack_range:
			print("Гравець поза зоною атаки. Переміщення...")
			velocity = direction * movement_speed
			move_and_slide()
			face_player(direction)
			play_walk_animation()
		else:
			print("Гравець у зоні атаки.")
			velocity = Vector2.ZERO
			if not is_attacking:
				start_attack()

func start_attack() -> void:
	print("Запуск атаки...")
	if is_attacking or is_dead:
		print("Атака скасована: ворог вже атакує або мертвий.")
		return
	is_attacking = true
	play_attack_animation()
	attack_timer.start()
	print("Таймер атаки запущено.")

func _on_attack_timeout() -> void:
	print("Таймер атаки закінчився. Перевірка можливості атаки...")
	if player and is_instance_valid(player) and not is_dead:
		var distance_to_player = global_position.distance_to(player.global_position)
		print("Поточна відстань до гравця: ", distance_to_player)

		if distance_to_player <= attack_range:
			print("Гравець у зоні атаки! Завдаємо шкоди.")
			player.take_damage(damage)
			print("Гравець отримав шкоду: ", damage)
	is_attacking = false

func face_player(direction: Vector2) -> void:
	print("Поворот скелета у бік гравця.")
	if direction.x < 0:
		skeleton.flip_h = true
	else:
		skeleton.flip_h = false
	print("flip_h встановлено у: ", skeleton.flip_h)

func play_walk_animation():
	print("Запуск анімації ходьби скелета.")
	if skeleton.animation != "walk":
		skeleton.play("walk")

func play_attack_animation():
	print("Запуск анімації атаки скелета.")
	skeleton.stop()
	skeleton.play("attack")

func play_die_animation():
	print("Запуск анімації смерті скелета.")
	skeleton.play("die")

func play_take_damage_animation():
	print("Запуск анімації отримання шкоди скелетом.")
	skeleton.play("take_damage")

func play_idle_animation():
	print("Запуск анімації очікування скелета.")
	skeleton.play("idle")

func take_damage(amount: float) -> void:
	if is_dead:
		return
	print("Отримано шкоду: ", amount)
	health -= amount
	health = max(health, 0)
	print("Залишилось здоров'я у скелета: ", health)

	play_take_damage_animation()
	if health <= 0:
		die()

func die() -> void:
	if not is_dead:
		is_dead = true
		print("Скелет знищено.")
		play_die_animation()
		attack_timer.stop()
		await get_tree().create_timer(0.200).timeout
		queue_free()
