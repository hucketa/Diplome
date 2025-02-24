extends CharacterBody2D

@export var movement_speed: float = 60.0
@export var health: float = 200
@export var damage: float = 1
@export var armor: int = 0
@export var stun_duration: float = 2

@onready var player = get_tree().get_first_node_in_group(&"Player")
@onready var hitbox: Area2D = $HitBox
@onready var hurtbox: Area2D = $HurtBox
@onready var sprite: AnimatedSprite2D = %Skeleton

var is_attacking: bool = false
var is_dead: bool = false
var is_stunned: bool = false
var last_flip := 1

var __player_in_attack_range : PlayerCharacterBody = null


func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= max(amount - armor, 1)
	if health <= 0:
		__die()
	else:
		if is_attacking:
			is_attacking = false
		sprite.play(&"take_damage")
		__apply_stun()


func _physics_process(delta: float) -> void:
	if is_dead or is_stunned:
		return
	if player and is_instance_valid(player):
		var direction: Vector2 = (player.global_position - global_position).normalized()
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
	sprite.play(&"attack")


func face_player(direction: Vector2) -> void:
	var is_facing_left := direction.x < 0
	if last_flip != (-1 if is_facing_left else 1):
		sprite.flip_h = is_facing_left
		update_hitbox_position(is_facing_left)
		last_flip = -1 if is_facing_left else 1


func update_hitbox_position(is_facing_left: bool) -> void:
	var flip_value := -1 if is_facing_left else 1
	hitbox.scale.x = abs(hitbox.scale.x) * flip_value
	hurtbox.scale.x = abs(hurtbox.scale.x) * flip_value
	hitbox.position.x = sprite.position.x
	hurtbox.position.x = sprite.position.x


func play_walk_animation() -> void:
	sprite.play(&"walk")


func __die() -> void:
	if not is_dead:
		is_dead = true
		sprite.play(&"die")


func __apply_stun() -> void:
	is_stunned = true
	await get_tree().create_timer(stun_duration).timeout
	is_stunned = false


func __animation_finished() -> void:
	match self.sprite.animation:
		&"attack":
			if __player_in_attack_range:
				__player_in_attack_range.take_damage(self.damage)
			self.is_attacking = false
		&"die":
			self.call_deferred(&"queue_free")
	return


func __player_entered(_v : Area2D) -> void:
	print("F")
	__player_in_attack_range = _v.get_parent()
	return


func __player_exited(area: Area2D) -> void:
	__player_in_attack_range = null
	return
