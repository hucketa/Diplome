extends CharacterBody2D

func play_walk_animation():
	%AnimatedSprite2D.play("walk")

func play_die_animation():
	%AnimatedSprite2D.play("die")

func play_take_damage_animation():
	%AnimatedSprite2D.play("take_damage")

func play_idle_animation():
	%AnimatedSprite2D.play("idle")

func play_attack_animation():
	%AnimatedSprite2D.play("attack")
