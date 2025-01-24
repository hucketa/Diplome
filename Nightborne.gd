extends CharacterBody2D
	
func play_walk_animation():
	%NightBorne.play("walk")

func play_die_animation():
	%NightBorne.play("deadth")

func play_take_damage_animation():
	%NightBorne.play("take_damage")

func play_idle_animation():
	%NightBorne.play("idle")

func play_attack_animation():
	%NightBorne.play("attack")
