class_name PlayerCharacterBody extends CharacterBody2D

@export_range(10.0, 500.0) var movement_speed : float = 100.0

@onready var stats = $stats
@onready var hitbox: Area2D = $HitBox
@onready var hurtbox: Area2D = $HurtBox
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var inventory_ui: SimplifiedInventory = $InventoryUi
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

var last_flip: int = 1
var __is_in_zone: bool = false
var __enemy_in_attack_range: EnemyBase = null
var __facing_left: bool = false
var __attacking: bool = false
var music_volume: int = 150

func _ready() -> void:
	stats.connect(&"health_changed", Callable(self, &"_on_health_changed"))
	stats.connect(&"died", Callable(self, &"_on_player_died"))
	stats.connect(&"level_up", Callable(self, &"_on_level_up"))
	__update_hitbox_position()
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_volume = config.get_value("Settings", "s_volume", 40)
	else:
		music_volume = 0
	sfx.volume_db = music_volume

func _physics_process(delta: float) -> void:
	if stats.is_dead:
		return
	__enemy_in_attack_range = null
	for area in hitbox.get_overlapping_areas():
		var parent = area.get_parent()
		if parent is EnemyBase:
			__enemy_in_attack_range = parent
			__is_in_zone = true
			break
	if not __enemy_in_attack_range:
		__is_in_zone = false
	
	if not __attacking:
		if __enemy_in_attack_range:
			play_effect("res://src/PLayer/SFX/player_attack.wav")
			perform_attack()
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
		sprite.speed_scale = 1
	else:
		sprite.play(&"idle")
		sprite.speed_scale = 1
	inventory_ui.synchronize_weapon_orientation(__facing_left)
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
	play_effect("res://src/PLayer/SFX/hurt.wav")
	stats.take_damage(amount)

func _on_player_died():
	sprite.play(&"die")
	play_effect("res://src/PLayer/SFX/Player_die.wav")
	get_tree().paused = true

func perform_attack():
	if stats.is_dead:
		return
	if not __enemy_in_attack_range:
		sprite.play(&"idle")
		sprite.speed_scale = 1
		return
	if __enemy_in_attack_range or __is_in_zone:
		__attacking = true
		sprite.play(&"attack3")
		sprite.speed_scale = stats.__attack_speed
		await self.sprite.animation_finished
		__attacking = false

func _on_animation_finished():
	match sprite.animation:
		&"attack3":
			if __enemy_in_attack_range && __is_in_zone:
				var damage = stats.calculate_damage()
				__enemy_in_attack_range.take_damage(damage)

func __enemy_entered_attack_range(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is EnemyBase:
		__is_in_zone = true
		__enemy_in_attack_range = enemy

func __enemy_exited_attack_range(area: Area2D) -> void:
	__enemy_in_attack_range = null
	__is_in_zone = false
	return

func play_effect(effect_path: String) -> void:
	var effect_stream = load(effect_path)
	if effect_stream:
		sfx.stop()
		sfx.stream = effect_stream
		sfx.play()
	else:
		push_error("Не вдалося завантажити ефект: " + effect_path)
		

func _clear_inventory():
	for i in range(inventory_ui.slots.size()-1):
		inventory_ui.remove_weapon(i)
