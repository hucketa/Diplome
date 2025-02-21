extends CharacterBody2D

@export var movement_speed: float = 30.0
@export var health: float = 100
@export var damage: float = 2
@export var attack_delay: float = 0.5
@export var stun_duration: float = 1

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_timer = Timer.new()
@onready var hitbox = $HitBox
@onready var hurtbox = $HurtBox
@onready var sprite: AnimatedSprite2D = %Reaper

var is_attacking: bool = false
var is_dead: bool = false
var is_stunned: bool = false
var last_flip = 1

func _ready() -> void:
	sprite.play("walk")
	add_child(attack_timer)
	attack_timer.wait_time = attack_delay
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	hitbox.monitoring = true
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x

func _physics_process(delta: float) -> void:
	if is_dead or is_stunned:
		return
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		if not hitbox.monitoring:
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
		return
	is_attacking = true
	sprite.play("attack")
	await get_tree().create_timer(attack_delay).timeout
	if hitbox.monitoring and hitbox.has_overlapping_areas():
		for area in hitbox.get_overlapping_areas():
			if area.is_in_group("Player") and not area.is_in_group("enemies"):
				player.take_damage(damage)
	attack_timer.start()
	is_attacking = false
	if not is_dead and not is_stunned and velocity.length() > 0:
		play_walk_animation()

func _on_attack_timeout() -> void:
	is_attacking = false
	if not is_dead and not is_stunned and velocity.length() > 0:
		play_walk_animation()

func face_player(direction: Vector2) -> void:
	var is_facing_left = direction.x > 0
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
	health -= amount
	health = max(health, 0)
	if health <= 0:
		die()
	else:
		sprite.play("take_damage")
		apply_stun()

func apply_stun() -> void:
	is_stunned = true
	hitbox.monitoring = false
	await get_tree().create_timer(stun_duration).timeout
	is_stunned = false
	hitbox.call_deferred("set_monitoring", true)
	if not is_dead and velocity.length() > 0:
		play_walk_animation()

func die() -> void:
	if not is_dead:
		is_dead = true
		sprite.play("die")
		attack_timer.stop()
		await get_tree().create_timer(0.600).timeout
		queue_free()
