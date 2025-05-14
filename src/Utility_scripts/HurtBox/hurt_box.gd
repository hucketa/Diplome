extends Area2D

signal hit(damage)

@onready var damage_timer: Timer = Timer.new()

var attacker: Node2D = null

func _on_area_entered(area):
	if not area.is_in_group("attack"):
		return
	if not area.has_method("get_damage"):
		return
	if area.owner == owner:
		return
	if area.get_parent().is_in_group("enemies") and get_parent().is_in_group("enemies"):
		return
	attacker = area
	if not attacker.has_method("get_damage"):
		return
	_apply_damage()
	damage_timer.start()

func _on_area_exited(area):
	if area == attacker:
		damage_timer.stop()
		attacker = null

func _apply_damage():
	if attacker and is_instance_valid(attacker):
		var damage = attacker.get_damage()
		emit_signal("hit", damage)
		if get_parent().has_method("take_damage"):
			get_parent().take_damage(damage)
	else:
		damage_timer.stop()
