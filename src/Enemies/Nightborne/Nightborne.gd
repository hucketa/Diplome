extends EnemyBase
class_name Nightborne

func _ready() -> void:
	movement_speed = 70
	health = 10
	damage = 4
	var new_sprite: AnimatedSprite2D = $NightBorne
	set_sprite(new_sprite)
