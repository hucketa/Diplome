extends CharacterBody2D

@export var movement_speed: float = 10.0
@export var health: float = 3
@export var damage: float = 1
@export var attack_range: float = 50.0
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var skelton: AnimatedSprite2D = %Skelton
@onready var attack_timer: Timer = $AttackTimer

var is_dead: bool = false

func _ready() -> void:
	attack_timer.wait_time = 0.200
	attack_timer.connect("timeout", Callable(self, "attack"))

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player) and not is_dead:
		var direction = (player.global_position - global_position).normalized()
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > attack_range:
			velocity = direction * movement_speed
			move_and_slide()
			play_walk_animation()
			attack_timer.stop()
		else:
			velocity = Vector2.ZERO
			play_attack_animation()
			if not attack_timer.is_stopped():
				return
			attack_timer.start()
		face_player(direction)

func face_player(direction: Vector2) -> void:
	skelton.flip_h = direction.x < 0

func play_idle_animation():
	skelton.play("idle")

func play_attack_animation():
	if skelton.animation != "attack":
		skelton.play("attack")

func play_die_animation():
	skelton.play("die")

func play_walk_animation():
	if skelton.animation != "walk":
		skelton.play("walk")

func play_take_damage_animation():
	skelton.play("take_damage")

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	health = max(health, 0)
	print("Скелет отримав урон:", amount, "Здоров'я:", health)
	play_take_damage_animation()
	if health <= 0:
		die()

func die() -> void:
	if not is_dead:
		is_dead = true
		print("Скелет знищений.")
		play_die_animation()
		attack_timer.stop()
		await get_tree().create_timer(0.200).timeout
		queue_free()

func attack() -> void:
	if player and is_instance_valid(player):
		print("Скелет атакует игрока на", damage, "урона.")
		if player.has_method("take_damage"):
			player.take_damage(damage)
