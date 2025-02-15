extends CharacterBody2D

@export var movement_speed: float = 60.0
@export var health: float = 40
@export var damage: float = 1
@export var armor: int = 0
@export var attack_range: float = 100.0
@export var attack_delay: float = 0.450  # Таймер між атаками

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_timer = Timer.new()
@onready var hitbox = $HitBox
@onready var hurtbox = $HurtBox
@onready var sprite: AnimatedSprite2D = %NightBorne

var is_attacking: bool = false
var is_dead: bool = false
var last_flip = 1

func _ready() -> void:
	add_child(attack_timer)
	attack_timer.wait_time = attack_delay
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player) and not is_dead:
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()

		if distance_to_player > attack_range:
			velocity = direction * movement_speed
			move_and_slide()
			face_player(direction)
			if not is_attacking:
				play_walk_animation()
		else:
			velocity = Vector2.ZERO
			if not is_attacking and not attack_timer.is_stopped():
				start_attack()

func start_attack() -> void:
	if is_attacking or is_dead:
		return
	is_attacking = true
	print("🗡 NightBorne атакует!")
	sprite.play("attack")
	hitbox.activate()  # Активація хитбоксу

	await sprite.animation_finished  # Очікуємо завершення атаки

	if hitbox.monitoring and player and is_instance_valid(player):
		var player_hurtbox = player.get_node("HurtBox")
		player_hurtbox._apply_damage()
		print("💥 Гравець отримав урон:", damage)

	attack_timer.start()  # Затримка перед наступною атакою
	is_attacking = false

func _on_attack_timeout() -> void:
	is_attacking = false

func face_player(direction: Vector2) -> void:
	var is_facing_left = direction.x < 0
	if last_flip != (-1 if is_facing_left else 1):
		sprite.flip_h = is_facing_left
		update_hitbox_position(is_facing_left)
		last_flip = -1 if is_facing_left else 1

func update_hitbox_position(is_facing_left: bool):
	var flip_value = -1 if is_facing_left else 1
	hitbox.scale.x = abs(hitbox.scale.x) * flip_value
	hurtbox.scale.x = abs(hurtbox.scale.x) * flip_value
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x

func play_walk_animation():
	if sprite.animation != "walk":
		sprite.play("walk")

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= max(amount - armor, 1)
	if health <= 0:
		die()
	else:
		sprite.play("take_damage")

func die() -> void:
	if not is_dead:
		is_dead = true
		sprite.play("die")
		attack_timer.stop()
		await get_tree().create_timer(0.200).timeout
		queue_free()
