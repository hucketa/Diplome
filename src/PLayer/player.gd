class_name PlayerCharacterBody extends CharacterBody2D

@export_range(10.0, 500.0) var movement_speed : float = 100.0

@onready var stats = $stats
@onready var hitbox: Area2D = $HitBox
@onready var hurtbox: Area2D = $HurtBox
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D

var last_flip: int = 1


var __enemy_in_attack_range : EnemyCharacterBody2D = null
var __facing_left : bool = false
var __attacking : bool = false


func _ready() -> void:
	stats.connect(&"health_changed", Callable(self, &"_on_health_changed"))
	stats.connect(&"died", Callable(self, &"_on_player_died"))
	stats.connect(&"level_up", Callable(self, &"_on_level_up"))
	__update_hitbox_position()


func _physics_process(delta: float) -> void:
	if not stats.is_dead:
		if not __attacking:
			if Input.is_action_just_pressed(&"attack"):
				self.perform_attack()
			else:
				movement(delta)


func movement(delta: float) -> void:
	var move = Input.get_vector(
		&"player_move_left",
		&"player_move_right",
		&"player_move_up",
		&"player_move_down"
	).normalized()
	if move.x != 0:
		__facing_left = move.x < 0
		sprite.flip_h = __facing_left
		__face_player()
	if move != Vector2.ZERO:
		sprite.play(&"walk")
	else:
		sprite.play(&"idle")
	velocity = move * self.movement_speed
	move_and_slide()


func __face_player() -> void:
	var new_flip = -1 if __facing_left else 1
	if last_flip != new_flip:
		__update_hitbox_position()
		last_flip = new_flip


func __update_hitbox_position() -> void:
	var flip_value = -1 if __facing_left else 1
	hitbox.scale.x = abs(hitbox.scale.x) * flip_value
	hurtbox.scale.x = abs(hurtbox.scale.x) * flip_value
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x


func take_damage(amount: float) -> void:
	print("# Гравець отримує урон:", amount)
	stats.take_damage(amount)


func _on_player_died():
	sprite.play(&"die")
	print("# Гравець загинув.")
	get_tree().paused = true


func perform_attack():
	if stats.is_dead:
		return
	if not __enemy_in_attack_range:
		print("# Немає ворогів у зоні атаки")
		sprite.play(&"idle")
		return
	__attacking = true
	sprite.play(&"attack3")
	await self.sprite.animation_finished
	__attacking = false


func _on_animation_finished():
	match sprite.animation:
		&"attack3":
			if __enemy_in_attack_range:
				var damage = stats.calculate_damage()
				print("# Гравець атакує. Урон:", damage)
				__enemy_in_attack_range.take_damage(damage)


func __enemy_entered_attack_range(area: Area2D) -> void:
	__enemy_in_attack_range = area.get_parent()
	return


func __enemy_exited_attack_range(area: Area2D) -> void:
	__enemy_in_attack_range = null
	return
