extends AudioStreamPlayer2D

var music_volume: int

func _ready():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_volume = config.get_value("Settings", "m_volume", 0)
	else:
		music_volume = 0
	self.volume_db = music_volume
	play(GameManager.music_position)
	
func _process(delta: float) -> void:
	GameManager.music_position = self.get_playback_position()

func set_music_volume(volume: int):
	music_volume = volume
	self.volume_db = music_volume
