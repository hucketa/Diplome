extends EnemyBase
class_name Skelet

func _ready() -> void:
	movement_speed = 40
	health = 5
	damage = 1.5
	var new_sprite: AnimatedSprite2D = $Skeleton
	set_sprite(new_sprite)
