extends CharacterBody2D

@export var movement_speed: float = 10.00
@export var health: float = 3
@export var damage: float = 0.5
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
		$Skelton.flip_h = false
	else:
		$Skelton.flip_h = true

func play_idle_animation():
	%Skelton.play("idle")

func play_attack_animation():
	%Skelton.play("attack")

func play_die_animation():
	%Skelton.play("die")
	
func play_walk_animation():
	%Skelton.play("walk")
	
func play_take_damage_animation():
	%Skelton.play("take_damage")
