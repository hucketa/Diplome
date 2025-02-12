extends CharacterBody2D

@export var movement_speed: float = 60.0
@export var health: float = 40
@export var damage: float = 1
@export var armor: int = 0
@export var attack_range: float = 100.0  # Радиус атаки
@export var attack_delay: float = 0.450  # Задержка между атаками
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_timer = Timer.new()  # Таймер для задержки между атаками

var is_attacking: bool = false  # Флаг, чтобы не запускать несколько атак одновременно
var push_strength: float = 200.0  # Сила отталкивания

func _ready() -> void:
	add_child(attack_timer)
	attack_timer.wait_time = attack_delay
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))

# Отслеживаем столкновения с объектами группы "enemies"
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		# Отталкиваем объекты группы "enemies"
		var direction = (area.global_position - global_position).normalized()
		var push_velocity = direction * push_strength
		area.velocity = push_velocity
		print("Объект из группы 'enemies' отталкнут")

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()

		# Двигаемся к игроку, если он вне радиуса атаки
		if distance_to_player > attack_range:
			velocity = direction * movement_speed
			move_and_slide()
			face_player(direction)
			play_walk_animation()
		else:
			# Если игрок в радиусе атаки, начинаем атаку
			if not is_attacking:
				start_attack()
				play_attack_animation()

func start_attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	attack_timer.start()  # Запускаем таймер атаки

func _on_attack_timeout() -> void:
	if player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		# Если игрок в радиусе атаки, наносим урон
		if distance_to_player <= attack_range:
			player.take_damage(damage)
			print("Атака! Игрок получил урон:", damage)
			is_attacking = false  # Разрешаем следующую атаку

func face_player(direction: Vector2) -> void:
	$NightBorne.flip_h = direction.x < 0

func play_walk_animation():
	$NightBorne.play("walk")

func play_die_animation():
	$NightBorne.play("die")

func play_take_damage_animation():
	$NightBorne.play("take_damage")

func play_idle_animation():
	$NightBorne.play("idle")

func play_attack_animation():
	$NightBorne.play("attack")

func take_damage(amount: float) -> void:
	var reduced_damage = max(amount - armor, 1)
	play_take_damage_animation()
	health -= reduced_damage
	print("Найтборн отримав урон:", reduced_damage, "Здоров'я:", health)
	if health <= 0:
		$NightBorne.play("die")
		die()

func die() -> void:
	print("Найтборн знищений.")
	play_die_animation()
	await get_tree().create_timer(0.250).timeout
	queue_free()
