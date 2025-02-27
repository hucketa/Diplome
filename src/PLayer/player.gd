class_name PlayerCharacterBody extends CharacterBody2D

@export_range(10.0, 300.0) var movement_speed: float = 150.0
@onready var stats = $stats
@onready var hitbox: Area2D = $HitBox
@onready var hurtbox: Area2D = $HurtBox
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D

var last_flip: int = 1
var __enemies_in_attack_range: Array = []
var __enemy_in_attack_range = null
var __facing_left: bool = false
var __attacking: bool = false

func _ready() -> void:
	stats.connect("health_changed", Callable(self, "_on_health_changed"))
	stats.connect("died", Callable(self, "_on_player_died"))
	stats.connect("level_up", Callable(self, "_on_level_up"))
	__update_hitbox_position()

func _physics_process(delta: float) -> void:
	if stats.is_dead:
		return
	if not __attacking:
		__check_enemies_in_hurtbox()
		if __enemy_in_attack_range:
			perform_attack()
		else:
			movement(delta)

func movement(delta: float) -> void:
	var move = Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down").normalized()
	if move.x != 0:
		__facing_left = move.x < 0
		sprite.flip_h = __facing_left
		__face_player()
	if move == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("walk")
	velocity = move * movement_speed
	move_and_slide()

func __face_player() -> void:
	var new_flip: int
	if __facing_left:
		new_flip = -1
	else:
		new_flip = 1
	if last_flip != new_flip:
		__update_hitbox_position()
		last_flip = new_flip

func __update_hitbox_position() -> void:
	var flip_value: int
	if __facing_left:
		flip_value = -1
	else:
		flip_value = 1
	hitbox.scale.x = abs(hitbox.scale.x) * flip_value
	hurtbox.scale.x = abs(hurtbox.scale.x) * flip_value
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x

func take_damage(amount: float) -> void:
	stats.take_damage(amount)

func _on_player_died():
	sprite.play("die")
	get_tree().paused = true

func perform_attack():
	if stats.is_dead:
		return
	if not __enemy_in_attack_range:
		sprite.play("idle")
		return
	__attacking = true
	sprite.play("attack3")
	await sprite.animation_finished
	__attacking = false

func _on_animation_finished():
	match sprite.animation:
		"attack3":
			__enemies_in_attack_range = __enemies_in_attack_range.filter(func(enemy):
				return is_instance_valid(enemy)
			)
			for enemy in __enemies_in_attack_range:
				var damage = stats.calculate_damage()
				enemy.take_damage(damage)

func __check_enemies_in_hurtbox() -> void:
	var overlapping_areas = hurtbox.get_overlapping_areas()
	__enemies_in_attack_range = __enemies_in_attack_range.filter(func(enemy):
		return is_instance_valid(enemy)
	)
	for area in overlapping_areas:
		var enemy = area.get_parent()
		if is_instance_valid(enemy) and enemy not in __enemies_in_attack_range:
			__enemies_in_attack_range.append(enemy)
	if __enemies_in_attack_range.size() > 0:
		__enemy_in_attack_range = __enemies_in_attack_range[0]
	else:
		__enemy_in_attack_range = null
