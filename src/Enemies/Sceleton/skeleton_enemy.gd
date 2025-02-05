extends CharacterBody2D

@export var movement_speed: float = 10.0
@export var health: float = 3
@export var damage: float = 0.5
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var skelton: AnimatedSprite2D = %Skelton

var is_dead: bool = false  # Проверка состояния "мертв"

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player) and not is_dead:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * movement_speed
		move_and_slide()
		face_player(direction)
		play_walk_animation()
		#play_attack_animation()

func face_player(direction: Vector2) -> void:
	skelton.flip_h = direction.x < 0

func play_idle_animation():
	skelton.play("idle")

func play_attack_animation():
	skelton.play("attack")

func play_die_animation():
	skelton.play("die")

func play_walk_animation():
	skelton.play("walk")

func play_take_damage_animation():
	skelton.play("take_damage")

func take_damage(amount: float) -> void:
	if is_dead:
		return  # Не принимаем урон, если враг уже мертв

	health -= amount
	health = max(health, 0)  # Ограничение здоровья до 0
	print("Скелет отримав урон:", amount, "Здоров'я:", health)
	play_take_damage_animation()

	if health <= 0:
		die()

func die() -> void:
	if not is_dead:
		is_dead = true
		print("Скелет знищений.")
		play_die_animation()
		await get_tree().create_timer(0.5).timeout
		queue_free()
