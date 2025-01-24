extends CharacterBody2D

@export var movement_speed: float = 60.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	movement(delta)

func movement(delta: float) -> void:
	var x_move = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	var y_move = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var move = Vector2(x_move, y_move).normalized()
	velocity = move * movement_speed
	move_and_slide()
	if x_move != 0:
		%AnimatedSprite2D.flip_h = x_move < 0
	if move != Vector2.ZERO:
		%AnimatedSprite2D.play("walk")
	else:
		%AnimatedSprite2D.play("idle")
