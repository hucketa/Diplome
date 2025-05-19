extends EnemyBase
class_name Reaper

@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
var music_volume: int

func _ready() -> void:
	movement_speed = 70
	health = 25
	damage = 1.5
	var new_sprite: AnimatedSprite2D = $Reaper
	set_sprite(new_sprite)
	$WordCollision.scale.x = abs($WordCollision.scale.x) * -1
	$WordCollision.position = sprite.position
	$WordCollision.position.x -= 45
	$WordCollision.position.y += 20
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_volume = config.get_value("Settings", "s_volume", 40)
	else:
		music_volume = 0
	sfx.volume_db = music_volume

func face_player(direction: Vector2) -> void:
	var is_facing_left = direction.x < 0
	var flip_value = 1
	if is_facing_left:
		flip_value = -1
	if last_flip != flip_value:
		sprite.flip_h = is_facing_left
		$WordCollision.scale.x = abs($WordCollision.scale.x) * flip_value
		$WordCollision.position = sprite.position
		if is_facing_left:
			$WordCollision.position.x += 40
			$WordCollision.position.y += 20
		else:
			$WordCollision.position.x -= 40
			$WordCollision.position.y += 15
		update_hitbox_position(is_facing_left)
		last_flip = flip_value

func __die() -> void:
	if not is_dead:
		is_dead = true
		sprite.play(&"die")
		play_sound("res://src/Enemies/Zhnec/monster_die.wav")
		give_coins_to_player()
		call_deferred("drop_experience")
		emit_signal("died")

func start_attack() -> void:
	is_attacking = true
	play_sound("res://src/Enemies/Zhnec/znec_attack.wav")
	sprite.play("attack")

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= max(amount - armor, 1)
	if health <= 0:
		__die()
	else:
		if is_attacking:
			is_attacking = false
		play_sound("res://src/Enemies/hurt.wav")
		sprite.play("take_damage")
		__apply_stun()

func play_sound(effect_path: String):
	var effect_stream = load(effect_path)
	if effect_stream:
		sfx.stop()
		sfx.stream = effect_stream
		sfx.play()
	else:
		push_error("Не вдалося завантажити ефект: " + effect_path)
