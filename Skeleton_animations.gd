extends AnimatedSprite2D

func play_idle_animation():
	%AnimationPlayer.play("idle")

func play_attack_animation():
	%AnimationPlayer.play("attack")

func play_die_animation():
	%AnimationPlayer.play("die")
	
func play_walk_animation():
	%AnimationPlayer.play("walk")
	
func play_take_damage_animation():
	%AnimationPlayer.play("take_damage")
