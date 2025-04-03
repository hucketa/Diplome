class_name EnemyBase
extends CharacterBody2D

signal died

@export var base_health: float = 1
@export var base_speed: float = 60.0
@export var base_damage: float = 1
@export var health_growth_factor: float = 1.25
@export var damage_growth_factor: float = 1.10
@export var speed_growth_factor: float = 1.05
@export var xp_growth_factor: float = 1.15
@export var coins_growth_factor: float = 1.03
@export var base_xp_reward: float = 1
@export var base_coins_reward: float = 1

var XP_ITEM_SCENE = load("res://src/Scenes/Experience_item/Exp_scene.tscn")

var movement_speed: float
var health: float
var damage: float
var armor: int = 0
var stun_duration: float = 1.0

var xp_reward: float
var coins_reward: float

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var hitbox: Area2D = $HitBox
@onready var hurtbox: Area2D = $HurtBox
@onready var sprite: AnimatedSprite2D = null

var is_attacking: bool = false
var is_dead: bool = false
var is_stunned: bool = false
var last_flip: int = 1

var __player_in_attack_range: Node = null

func apply_wave_modifiers(current_wave: float) -> void:
	var wave_index = max(current_wave - 1, 0)
	health = base_health * pow(health_growth_factor, wave_index)
	damage = base_damage * pow(damage_growth_factor, wave_index)
	movement_speed = (base_speed * pow(speed_growth_factor, wave_index)) + randf_range(-10, 10)
	xp_reward = base_xp_reward * pow(xp_growth_factor, wave_index)
	coins_reward = base_coins_reward * pow(coins_growth_factor, wave_index)

func set_sprite(a: AnimatedSprite2D) -> void:
	sprite = a

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= max(amount - armor, 1)
	if health <= 0:
		__die()
	else:
		if is_attacking:
			is_attacking = false
		sprite.play("take_damage")
		__apply_stun()

func _physics_process(delta: float) -> void:
	if is_dead or is_stunned:
		return
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		if __player_in_attack_range:
			velocity = Vector2.ZERO
			if not is_attacking:
				start_attack()
		else:
			velocity = direction * movement_speed
			face_player(direction)
			if not is_attacking:
				play_walk_animation()
		move_and_slide()

func start_attack() -> void:
	is_attacking = true
	sprite.play("attack")

func face_player(direction: Vector2) -> void:
	var is_facing_left = direction.x < 0
	var flip_value = 1
	if is_facing_left:
		flip_value = -1
	if last_flip != flip_value:
		sprite.flip_h = is_facing_left
		update_hitbox_position(is_facing_left)
		last_flip = flip_value

func update_hitbox_position(is_facing_left: bool) -> void:
	var flip_value = 1
	if is_facing_left:
		flip_value = -1
	hitbox.scale.x = abs(hitbox.scale.x) * flip_value
	hurtbox.scale.x = abs(hurtbox.scale.x) * flip_value
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x

func play_walk_animation() -> void:
	sprite.play("walk")

func __die() -> void:
	if not is_dead:
		is_dead = true
		sprite.play("die")
		give_coins_to_player()
		call_deferred("drop_experience")
		emit_signal("died")

func give_coins_to_player() -> void:
	var player_stats = get_tree().get_first_node_in_group("PlayerStats")
	if player_stats:
		player_stats.gain_coins(round(coins_reward) * GameManager.__gold_scale)

func drop_experience() -> void:
	var xp_item = XP_ITEM_SCENE.instantiate()
	xp_item.global_position = global_position
	xp_item.set_experience(xp_reward * GameManager.__xp_scale)
	get_parent().add_child(xp_item)

func __apply_stun() -> void:
	is_stunned = true
	await get_tree().create_timer(stun_duration).timeout
	is_stunned = false

func __animation_finished() -> void:
	match sprite.animation:
		"attack":
			if __player_in_attack_range and __player_in_attack_range.has_method("take_damage"):
				__player_in_attack_range.take_damage(damage)
			is_attacking = false
		"die":
			call_deferred("queue_free")

func __player_entered(area: Area2D) -> void:
	__player_in_attack_range = area.get_parent()

func __player_exited(area: Area2D) -> void:
	__player_in_attack_range = null

func play_sound(effect_path: String):
	pass
