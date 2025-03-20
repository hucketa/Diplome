extends EnemyBase
class_name Nightborne

@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
var music_volume: int

func _ready() -> void:
	movement_speed = 70
	health = 10
	damage = 4
	var new_sprite: AnimatedSprite2D = $NightBorne
	set_sprite(new_sprite)
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_volume = config.get_value("Settings", "s_volume", 40)
	else:
		music_volume = 0
	print(music_volume)
	sfx.volume_db = music_volume

func start_attack() -> void:
	is_attacking = true
	play_sound("res://src/Enemies/Nightborne/Sword_attack.wav")
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

func __die() -> void:
	if not is_dead:
		is_dead = true
		sprite.play(&"die")
		play_sound("res://src/Enemies/Nightborne/monster_die.wav")
		emit_signal("died")
		call_deferred("drop_experience")
		call_deferred("give_coins_to_player")
