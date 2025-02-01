extends CharacterBody2D

@export var movement_speed: float = 20.00
@export var health = 5
@export var damage = 1
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
		$NightBorne.flip_h = false
	else:
		$NightBorne.flip_h = true

func play_walk_animation():
	$NightBorne.play("walk")

func play_die_animation():
	$NightBorne.play("deadth")

func play_take_damage_animation():
	$NightBorne.play("take_damage")

func play_idle_animation():
	$NightBorne.play("idle")

func play_attack_animation():
	$NightBorne.play("attack")
