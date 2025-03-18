class_name Pistol
extends Weapon

var __gun_sprite: AnimatedSprite2D = null
var bullet_scene = load("res://src/Weapons/bullet/bullet.tscn")

func _ready() -> void:
	if __gun_sprite == null:
		__gun_sprite = $GunSprite
	self.connect("attack_started", Callable(self, "_on_attack_started"))
	__gun_sprite.connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))

func attack():
	__gun_sprite.play("attack")

func _process(delta: float) -> void:
	__gun_sprite.flip_h = super.get_flip()

func _on_attack_started():
	print("Gun: Атака началась!")

func _on_animated_sprite_2d_animation_finished():
	print("Анимация атаки завершена!")
	var bullet = bullet_scene.instantiate()
	self.add_child(bullet)
	bullet.global_position = self.global_position + Vector2(0,+10)
	if !__gun_sprite.flip_h:
		bullet.direction = Vector2.RIGHT
	else:
		bullet.direction = Vector2.LEFT
	attack_completed()
