extends ParallaxBackground

var SPEED = 100

func _process(delta):
	scroll_offset.x -= SPEED * delta
