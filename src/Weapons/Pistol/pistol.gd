class_name Pistol
extends Weapon

var __gun_sprite: AnimatedSprite2D = null
var bullet_scene = load("res://src/Weapons/bullet/bullet.tscn")
var damage: float = 0
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
var music_volume: int

func _ready() -> void:
	if __gun_sprite == null:
		__gun_sprite = $GunSprite
	self.connect("attack_started", Callable(self, "_on_attack_started"))
	__gun_sprite.connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_volume = config.get_value("Settings", "s_volume", -50)
	else:
		music_volume = 0
	sfx.volume_db = music_volume

func attack():
	__gun_sprite.play("attack")

func _process(delta: float) -> void:
	__gun_sprite.flip_h = super.get_flip()

func _on_attack_started():
	pass

func _on_animated_sprite_2d_animation_finished():
	var bullet = bullet_scene.instantiate()
	bullet.damage = self.damage
	self.add_child(bullet)
	bullet.global_position = self.global_position + Vector2(0, +10)
	var is_facing_left = __gun_sprite.flip_h
	bullet.set_direction(Vector2.LEFT if is_facing_left else Vector2.RIGHT)
	play_effect("res://src/Weapons/Pistol/pistol_shot.wav")
	attack_completed()

func play_effect(effect_path: String) -> void:
	var effect_stream = load(effect_path)
	if effect_stream:
		sfx.stop()
		sfx.stream = effect_stream
		sfx.play()
	else:
		push_error("Не вдалося завантажити ефект: " + effect_path)
		

func set_data(data: WeaponData):
	if not __gun_sprite:
		__gun_sprite = $GunSprite
	if data.sprite_frames:
		__gun_sprite.sprite_frames = data.sprite_frames
		__gun_sprite.play("attack")
		self.damage = data.damage
