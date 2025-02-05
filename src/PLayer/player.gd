extends CharacterBody2D

@onready var attack_timer = $AttackTimer
@onready var stats = $stats
@onready var hitbox: Area2D = $HitBox

func _ready() -> void:
	attack_timer.connect("timeout", Callable(self, "perform_attack"))
	attack_timer.start()
	stats.connect("health_changed", Callable(self, "_on_health_changed"))
	stats.connect("died", Callable(self, "_on_player_died"))
	stats.connect("level_up", Callable(self, "_on_level_up"))

func _physics_process(delta: float) -> void:
	if not stats.is_dead:
		movement(delta)

func movement(delta: float) -> void:
	var x_move = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	var y_move = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var move = Vector2(x_move, y_move).normalized()
	velocity = move * 100
	move_and_slide()
	if x_move != 0:
		%AnimatedSprite2D.flip_h = x_move < 0
	if move != Vector2.ZERO:
		%AnimatedSprite2D.play("walk")
	else:
		%AnimatedSprite2D.play("idle")

func take_damage(amount: int) -> void:
	stats.take_damage(amount)

func _on_player_died():
	%AnimatedSprite2D.play("die")
	print("Гравець загинув.")
	attack_timer.stop()
	get_tree().paused = true

func _on_health_changed(current_health: int):
	print("Поточне здоров'я гравця:", current_health)

func _on_level_up(new_level: int):
	print("Гравець досягнув рівня:", new_level)

func perform_attack():
	if stats.is_dead:
		return
	var damage = stats.calculate_damage()
	print("Гравець атакує з уроном:", damage)
	%AnimatedSprite2D.play("attack")
	hitbox.monitoring = true
	await get_tree().create_timer(0.1).timeout
	hitbox.monitoring = false
