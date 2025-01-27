extends CharacterBody2D

@export var movement_speed: float = 60.00

@onready var player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * movement_speed
		move_and_slide()
		
		# Поворачиваем монстра в сторону игрока
		face_player(direction)

		play_walk_animation()

func face_player(direction: Vector2) -> void:
	# Поворачиваем монстра в сторону игрока с помощью flip_h
	if direction.x > 0:  # Игрок справа
		$NightBorne.flip_h = false
	else:  # Игрок слева
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
