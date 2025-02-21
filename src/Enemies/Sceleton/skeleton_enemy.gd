extends CharacterBody2D

@export var movement_speed: float = 30.0
@export var health: float = 50
@export var damage: float = 1
@export var armor: int = 0
@export var attack_delay: float = 0.5
@export var stun_duration: float = 2

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_timer = Timer.new()
@onready var hitbox = $HitBox
@onready var hurtbox = $HurtBox
@onready var sprite: AnimatedSprite2D = %Skeleton

var is_attacking: bool = false
var is_dead: bool = false
var is_stunned: bool = false
var last_flip = 1
var cancel_attack: bool = false

func _ready() -> void:
	add_child(attack_timer)
	attack_timer.wait_time = attack_delay
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	hitbox.monitoring = true
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x
	print("✅ Враг готов. Хитбокс включен.")

func _physics_process(delta: float) -> void:
	if is_dead or is_stunned:
		return
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		if not hitbox.monitoring:
			print("⚠️ Хитбокс был выключен, включаем обратно.")
			hitbox.monitoring = true
		var player_near = false
		if hitbox.has_overlapping_areas():
			for area in hitbox.get_overlapping_areas():
				if area.is_in_group("Player") and not area.is_in_group("enemies"):
					player_near = true
					break
		if not player_near:
			velocity = direction * movement_speed
			move_and_slide()
			face_player(direction)
			if not is_attacking:
				play_walk_animation()
		else:
			velocity = Vector2.ZERO
			if not is_attacking and attack_timer.is_stopped():
				start_attack()

func start_attack() -> void:
	if is_attacking or is_dead or is_stunned:
		print("⛔ Атака невозможна. is_attacking:", is_attacking, ", is_dead:", is_dead, ", is_stunned:", is_stunned)
		return
	is_attacking = true
	cancel_attack = false
	print("🗡️ Начинаем атаку!")

	sprite.play("attack")
	await get_tree().create_timer(attack_delay).timeout

	if is_stunned or is_dead or cancel_attack:
		print("❌ Атака отменена. is_stunned:", is_stunned, ", is_dead:", is_dead, ", cancel_attack:", cancel_attack)
		is_attacking = false
		return

	# Проверяем еще раз перед нанесением урона!
	if is_stunned:
		print("⚠️ Враг в стане, отменяем урон!")
		return

	if hitbox.monitoring and hitbox.has_overlapping_areas():
		for area in hitbox.get_overlapping_areas():
			if area.is_in_group("Player") and not area.is_in_group("enemies"):
				print("🎯 Попадание по игроку! Наносим урон:", damage)
				player.take_damage(damage)

	attack_timer.start()
	is_attacking = false
	print("⚔️ Атака завершена.")

func _on_attack_timeout() -> void:
	print("🔄 Атака закончилась по таймеру.")
	is_attacking = false

func face_player(direction: Vector2) -> void:
	var is_facing_left = direction.x < 0
	if last_flip != (-1 if is_facing_left else 1):
		sprite.flip_h = is_facing_left
		update_hitbox_position(is_facing_left)
		last_flip = -1 if is_facing_left else 1

func update_hitbox_position(is_facing_left: bool) -> void:
	var flip_value = -1 if is_facing_left else 1
	hitbox.scale.x = abs(hitbox.scale.x) * flip_value
	hurtbox.scale.x = abs(hurtbox.scale.x) * flip_value
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x

func play_walk_animation() -> void:
	if sprite.animation != "walk":
		sprite.play("walk")

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= max(amount - armor, 1)
	print("🔥 Враг получил урон:", amount, "Текущее здоровье:", health)
	if health <= 0:
		die()
	else:
		sprite.play("take_damage")
		apply_stun()

func apply_stun() -> void:
	print("⚡ Враг оглушен на", stun_duration, "секунд!")
	is_stunned = true
	is_attacking = false
	cancel_attack = true
	hitbox.set_deferred("monitoring", false)  # Отключаем хитбокс **полностью**
	hurtbox.set_deferred("monitoring", false)  # Отключаем хартбокс

	attack_timer.stop()
	await get_tree().create_timer(stun_duration).timeout

	is_stunned = false
	hitbox.set_deferred("monitoring", true)  # Включаем хитбокс обратно
	hurtbox.set_deferred("monitoring", true)  # Включаем хартбокс обратно
	print("💢 Враг вышел из стана!")

func die() -> void:
	if not is_dead:
		is_dead = true
		is_attacking = false
		cancel_attack = true
		print("☠️ Враг умер.")
		sprite.play("die")
		hitbox.set_deferred("monitoring", false)  # Полностью убираем урон
		attack_timer.stop()
		await get_tree().create_timer(0.600).timeout
		queue_free()
