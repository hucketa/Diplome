extends CharacterBody2D

@export var movement_speed: float = 30.00
@export var health: float = 15
@export var damage: float = 2
@onready var player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * movement_speed
		move_and_slide()
		if is_instance_valid(player):
			face_player(direction)
		play_walk_animation()

func face_player(direction: Vector2) -> void:
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

func play_walk_animation():
	%AnimatedSprite2D.play("walk")

func play_die_animation():
	%AnimatedSprite2D.play("die")

func play_take_damage_animation():
	%AnimatedSprite2D.play("take_damage")

func play_idle_animation():
	%AnimatedSprite2D.play("idle")

func play_attack_animation():
	%AnimatedSprite2D.play("attack")
