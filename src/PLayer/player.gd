extends CharacterBody2D

@onready var attack_timer = $AttackTimer
@onready var stats = $stats
@onready var hitbox: Area2D = $HitBox
@onready var hurtbox: Area2D = $HurtBox
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D

var last_flip: int = 1

func _ready() -> void:
	attack_timer.connect("timeout", Callable(self, "perform_attack"))
	attack_timer.start()
	stats.connect("health_changed", Callable(self, "_on_health_changed"))
	stats.connect("died", Callable(self, "_on_player_died"))
	stats.connect("level_up", Callable(self, "_on_level_up"))
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	if not stats.is_dead:
		movement(delta)

func movement(delta: float) -> void:
	var x_move = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	var y_move = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var move = Vector2(x_move, y_move).normalized()
	velocity = move * 100
	move_and_slide()
	if x_move != 0:
		var flip = x_move < 0
		sprite.flip_h = flip
		face_player(flip)
	if move != Vector2.ZERO and not sprite.animation.begins_with("attack"):
		sprite.play("walk")
	elif move == Vector2.ZERO and not sprite.animation.begins_with("attack"):
		sprite.play("idle")

func face_player(is_facing_left: bool) -> void:
	var new_flip = -1 if is_facing_left else 1
	if last_flip != new_flip:
		update_hitbox_position(is_facing_left)
		last_flip = new_flip

func update_hitbox_position(is_facing_left: bool) -> void:
	var flip_value = -1 if is_facing_left else 1
	hitbox.scale.x = abs(hitbox.scale.x) * flip_value
	hurtbox.scale.x = abs(hurtbox.scale.x) * flip_value
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x

func take_damage(amount: float) -> void:
	print("# Гравець отримує урон:", amount)
	stats.take_damage(amount)

func _on_player_died():
	sprite.play("die")
	print("# Гравець загинув.")
	attack_timer.stop()
	get_tree().paused = true

func perform_attack():
	if stats.is_dead:
		return
	hitbox.monitoring = true  # Включаем хитбокс перед проверкой
	await get_tree().process_frame  # Ждём один кадр, чтобы обновились столкновения
	var enemy_nearby = false
	for area in hitbox.get_overlapping_areas():
		if area.is_in_group("enemies"):
			enemy_nearby = true
			break
	if not enemy_nearby:
		print("# Немає ворогів у зоні атаки")
		hitbox.monitoring = false  # Отключаем хитбокс, если врагов нет
		sprite.play("idle")
		return
	sprite.play("attack3")
	await sprite.animation_finished
	var damage_a = stats.calculate_damage()
	print("# Гравець атакує. Урон:", damage_a)
	hitbox.damage = damage_a
	await get_tree().create_timer(0.1).timeout
	hitbox.monitoring = false


func _on_animation_finished():
	if sprite.animation.begins_with("attack"):
		sprite.play("idle")
