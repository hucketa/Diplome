class_name Sword
extends Weapon

@onready var hitbox: Area2D = $Sword_sprite/HitBox

var sword_sprite: AnimatedSprite2D = null
var __is_in_zone: bool = false
var __enemy_in_attack_range: EnemyBase = null
var __facing_left: bool = false
var last_flip: bool = false
@export var damage_sword = 150
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
var music_volume: int

func _ready() -> void:
	if sword_sprite == null:
		sword_sprite = $Sword_sprite
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_volume = config.get_value("Settings", "s_volume", 40)
	else:
		music_volume = 0
	sfx.volume_db = music_volume
	__update_hitbox_position()

func attack():
	__face_sword()
	
	sword_sprite.play("attack")

func _process(delta: float) -> void:
	__facing_left = sword_sprite.flip_h
	sword_sprite.flip_h = super.get_flip()
	if not __attacking and __enemy_in_attack_range:
		perform_attack()

func __face_sword() -> void:
	var new_flip: bool = __facing_left
	if last_flip != new_flip:
		__update_hitbox_position()
		last_flip = new_flip

func __update_hitbox_position() -> void:
	var flip_value = 1 if __facing_left else -1
	hitbox.scale.x = abs(hitbox.scale.x) * flip_value
	if not __facing_left:
		hitbox.position.x = (sword_sprite.position.x)
	else:
		hitbox.position.x = (sword_sprite.position.x)+10

func perform_attack():
	if __enemy_in_attack_range:
		__attacking = true
		play_effect("res://src/Weapons/Sword/Sword_attack.wav")
		sword_sprite.play("attack")
		await sword_sprite.animation_finished
		__attacking = false
		if __enemy_in_attack_range != null:
			__enemy_in_attack_range.take_damage(damage_sword)
		else:
			print("# Ворог відсутній.")

func __enemy_entered_attack_range(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is EnemyBase:
		__is_in_zone = true
		__enemy_in_attack_range = enemy

func __enemy_exited_attack_range(area: Area2D) -> void:
	if __enemy_in_attack_range and __enemy_in_attack_range == area.get_parent():
		__enemy_in_attack_range = null
		__is_in_zone = false

func play_effect(effect_path: String) -> void:
	var effect_stream = load(effect_path)
	if effect_stream:
		sfx.stop()
		sfx.stream = effect_stream
		sfx.play()
	else:
		push_error("Не вдалося завантажити ефект: " + effect_path)

func set_data(data: WeaponData):
	if not sword_sprite:
		sword_sprite = $Sword_sprite
	if data.sprite_frames:
		sword_sprite.sprite_frames = data.sprite_frames
		damage_sword = data.damage
		sword_sprite.play("attack")
