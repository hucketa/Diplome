extends CharacterBody2D

func play_idle_animation():
	%Skelton.play("idle")

func play_attack_animation():
	%Skelton.play("attack")

func play_die_animation():
	%Skelton.play("die")
	
func play_walk_animation():
	%Skelton.play("walk")
	
func play_take_damage_animation():
	%Skelton.play("take_damage")
