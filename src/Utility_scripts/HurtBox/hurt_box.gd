extends Area2D

signal hit(damage)

@onready var damage_timer: Timer = Timer.new()


var attacker: Node2D = null

func _on_area_entered(area):
	if not area.is_in_group("attack"):
		return
	if not area.has_method("get_damage"):
		print("# ❌ Ігнор об'єкта без get_damage:", area.name)
		return
	print("🛠️ DEBUG: Attacker Owner:", area.owner.name, " Groups:", area.owner.get_groups())
	print("🛠️ DEBUG: Hurtbox Owner:", owner.name, " Groups:", owner.get_groups())
	print("🛠️ DEBUG: Attacker Parent:", area.get_parent().name, " Groups:", area.get_parent().get_groups())
	print("🛠️ DEBUG: Hurtbox Parent:", get_parent().name, " Groups:", get_parent().get_groups())
	if area.owner == owner:
		print("# ❌ Хартбокс ігнорує самопошкодження.")
		return
	if area.get_parent().is_in_group("enemies") and get_parent().is_in_group("enemies"):
		print("# ❌ Хартбокс ігнорує атаку від іншого ворога.")
		return
	print("# ✅ Виявлено атаку від:", area.name)
	attacker = area
	if not attacker.has_method("get_damage"):
		print("# ❌ У атакуючого немає get_damage()")
		return
	_apply_damage()
	damage_timer.start()


func _on_area_exited(area):
	if area == attacker:
		print("✅ Атакуючий покинув хартбокс. Зупиняємо урон.")
		damage_timer.stop()
		attacker = null

func _apply_damage():
	if attacker and is_instance_valid(attacker):
		var damage = attacker.get_damage()
		emit_signal("hit", damage)
		print("🎯 Отримано урон:", damage)
		if get_parent().has_method("take_damage"):
			get_parent().take_damage(damage)
	else:
		print("❌ Немає атакуючого, таймер зупинено.")
		damage_timer.stop()
