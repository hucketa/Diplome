extends Area2D

signal hit(damage)

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):
	if area.is_in_group("attack") and area.has_method("get_damage"):
		print("Обнаружен объект:", area.name)
		var damage = area.get_damage()
		emit_signal("hit", damage)
		print("Отримано урон:", damage)
		if get_parent().has_method("take_damage"):
			get_parent().take_damage(damage)
