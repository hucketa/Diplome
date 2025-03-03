extends EnemyBase
class_name Reaper

func _ready() -> void:
	movement_speed = 70
	health = 25
	damage = 1.5
	var new_sprite: AnimatedSprite2D = $Reaper
	set_sprite(new_sprite)

func face_player(direction: Vector2) -> void:
	var is_facing_left = direction.x >= 0
	var flip_value = 1
	if is_facing_left:
		flip_value = -1
	if last_flip != flip_value:
		sprite.flip_h = is_facing_left
		update_hitbox_position(is_facing_left)
		last_flip = flip_value
