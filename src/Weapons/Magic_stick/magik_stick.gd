class_name MagicStick
extends Weapon

@onready var __stick_sprite: AnimatedSprite2D = $StickSprite
var bullet_scene = load("res://src/Weapons/Magic_projectile/Magik_projectile.tscn")
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
var music_volume: int
var damage: float = 0

func _ready() -> void:
	if __stick_sprite == null:
		__stick_sprite = $StickSprite
	self.connect("attack_started", Callable(self, "_on_attack_started"))
	__stick_sprite.connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_volume = config.get_value("Settings", "s_volume", 40)
	else:
		music_volume = 0
	sfx.volume_db = music_volume

func attack():
	__stick_sprite.play("attack")

func _process(delta: float) -> void:
	__stick_sprite.flip_h = super.get_flip()

func _on_attack_started():
	pass

func _on_animated_sprite_2d_animation_finished():
	var bullet = bullet_scene.instantiate()
	self.add_child(bullet)
	bullet.damage = self.damage
	print(bullet.damage)
	bullet.global_position = self.global_position + Vector2(0, 0)
	var is_facing_left = __stick_sprite.flip_h
	bullet.set_direction(Vector2.LEFT if is_facing_left else Vector2.RIGHT)
	play_effect("res://src/Weapons/Magic_stick/Magic_attack.wav")
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
	if not __stick_sprite:
		__stick_sprite = $StickSprite
	if data.sprite_frames:
		__stick_sprite.sprite_frames = data.sprite_frames
		self.damage = data.damage
		__stick_sprite.play("attack")
