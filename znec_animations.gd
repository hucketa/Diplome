extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func play_walk_animation():
	%AnimationPlayer.play("walk")

func play_die_animation():
	%AnimationPlayer.play("die")

func play_take_damage_animation():
	%AnimationPlayer.play("take_damage")

func play_idle_animation():
	%AnimationPlayer.play("idle")

func play_attack_animation():
	%AnimationPlayer.play("attack")
