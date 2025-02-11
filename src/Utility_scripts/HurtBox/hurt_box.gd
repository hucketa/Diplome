extends Area2D

signal hit(damage)

@onready var damage_timer: Timer = Timer.new()

func _ready():
	print("Хартбокс готовий.")
	
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
	
	damage_timer.wait_time = 1.0
	damage_timer.one_shot = false
	damage_timer.connect("timeout", Callable(self, "_apply_damage"))
	add_child(damage_timer)

var attacker: Node2D = null

func _on_area_entered(area):
	if not area.is_in_group("attack"):
		return
	if not area.has_method("get_damage"):
		print("# ❌ Ігнор об'єкта без get_damage:", area.name)
		return
	if area.get_parent() == get_parent():
		print("# ❌ Хартбокс ігнорує атаку від власного персонажа.")
		return
	if area.get_parent().is_in_group("Enemy") and get_parent().is_in_group("Enemy"):
		print("# ❌ Хартбокс ігнорує атаку від іншого скелета.")
		return  # 🔹 Головне правило!
	print("# ✅ Виявлено атаку від:", area.name)
	attacker = area
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
