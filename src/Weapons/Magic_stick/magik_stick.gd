class_name MagicStick
extends Weapon

var __stick_sprite: AnimatedSprite2D = null
var bullet_scene = load("res://src/Weapons/Magic_projectile/Magik_projectile.tscn")

func _ready() -> void:
	if __stick_sprite == null:
		__stick_sprite = $StickSprite
	self.connect("attack_started", Callable(self, "_on_attack_started"))
	__stick_sprite.connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))

func attack():
	__stick_sprite.play("attack")

func _process(delta: float) -> void:
	__stick_sprite.flip_h = super.get_flip()

func _on_attack_started():
	print("Gun: Атака началась!")

func _on_animated_sprite_2d_animation_finished():
	print("Анимация атаки завершена!")
	var bullet = bullet_scene.instantiate()
	self.add_child(bullet)
	bullet.global_position = self.global_position + Vector2(0, +10)
	var is_facing_left = __stick_sprite.flip_h
	bullet.set_direction(Vector2.LEFT if is_facing_left else Vector2.RIGHT)
	attack_completed()
