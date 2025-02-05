extends CharacterBody2D

@export var movement_speed: float = 20.0
@export var health: float = 5
@export var damage: float = 1
@export var armor: int = 1
@onready var player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * movement_speed
		move_and_slide()
		face_player(direction)
		play_walk_animation()

func face_player(direction: Vector2) -> void:
	$NightBorne.flip_h = direction.x < 0

func play_walk_animation():
	$NightBorne.play("walk")

func play_die_animation():
	$NightBorne.play("death")

func play_take_damage_animation():
	$NightBorne.play("take_damage")

func play_idle_animation():
	$NightBorne.play("idle")

func play_attack_animation():
	$NightBorne.play("attack")

func take_damage(amount: float) -> void:
	var reduced_damage = max(amount - armor, 1)
	health -= reduced_damage
	print("Найтборн отримав урон:", reduced_damage, "Здоров'я:", health)
	play_take_damage_animation()
	if health <= 0:
		die()

func die() -> void:
	print("Найтборн знищений.")
	play_die_animation()
	await get_tree().create_timer(0.5).timeout
	queue_free()
