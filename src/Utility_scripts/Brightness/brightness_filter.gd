extends CanvasModulate

const CONFIG_PATH = "user://settings.cfg"
@onready var canvas_modulate: CanvasModulate = $"."
		
func _ready():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		var brightness = config.get_value("Settings", "brightness", 1)
		var brightness_value = brightness
		canvas_modulate.color = Color(brightness_value, brightness_value, brightness_value)

func manual_analyse():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		var brightness = config.get_value("Settings", "brightness", 0)
		var brightness_value = brightness
		canvas_modulate.color = Color(brightness_value, brightness_value, brightness_value)
