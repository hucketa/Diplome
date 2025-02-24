extends Control

const CONFIG_PATH = "user://settings.cfg"
var one_shot_mode = false
var health_bar_scale = false
var reduced_experience = false
var sound_volume = 0  
var brightness = 1 
var music_volume = 0
var localisation = "uk"

@onready var brightness_slider: HSlider = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/BrightnessProgressBar/brightness_slider"
@onready var music_player: AudioStreamPlayer2D = $bg_music
@onready var ru_button: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/Localisation_buttons/VBoxContainer/RuButton"
@onready var ua_button: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/Localisation_buttons/VBoxContainer/UaButton"
@onready var music_mute_off: Button = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/MusicBox/music_mute_off"
@onready var sound_mute_off: Button = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/SoundBox/sound_mute_off"
@onready var one_try: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Hard_mode/one_try"
@onready var view_bar_button: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/HPBarView/view_bar_button"
@onready var low_exp_scale_button: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Experience_scale/low_exp_scale_button"
@onready var back_button: Button = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/BackButton"
@onready var button: Button = %Button
@onready var label: Label = $mainContainer/Caption/Label
@onready var caption_sound: Label = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/SoundProgressBar/Caption_sound"
@onready var caption_music: Label = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/MusicProgressBar/Caption_music"
@onready var caption_bright: Label = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/BrightnessProgressBar/Caption_bright"
@onready var caption_odd: Label = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Caption_odd"
@onready var label_hm: Label = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Hard_mode/Label_hm"
@onready var label_hp: Label = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/HPBarView/Label_hp"
@onready var label_exp: Label = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Experience_scale/Label_exp"
@onready var label_mute_s: Label = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/SoundBox/Label_mute_s"
@onready var label_mute_m: Label = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/MusicBox/Label_mute_m"
@onready var caption_bright_2: Label = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/BrightnessProgressBar/Caption_bright2"
@onready var music_sound_slider: HSlider = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/MusicProgressBar/music_sound_slider"

func _ready():
	load_settings()
	update_ui()
	one_try.connect("toggled", Callable(self, "_on_one_try_toggled"))
	view_bar_button.connect("toggled", Callable(self, "_on_view_bar_toggled"))
	low_exp_scale_button.connect("toggled", Callable(self, "_on_low_exp_toggled"))
	back_button.connect("pressed", Callable(self, "_on_back_main_pressed"))
	music_mute_off.connect("pressed", Callable(self, "_on_music_mute_off_pressed"))
	sound_mute_off.connect("pressed", Callable(self, "_on_sound_mute_off_pressed"))
	

func change_language_ui():
	label.text = tr(&"SETTINGS")
	caption_sound.text = tr(&"SOUND")
	caption_music.text = tr(&"MUSIC")
	caption_bright.text = tr(&"BRIGHTNESS")
	caption_odd.text = tr(&"ADDITIONAL")
	label_hm.text = tr(&"ONE_TRY")
	label_hp.text = tr(&"HEALTH_BAR_SHOW")
	label_exp.text = tr(&"LOWER_EXP")
	label_mute_s.text = tr(&"SOUND_MUTE")
	label_mute_m.text = tr(&"MUSIC_MUTE")
	back_button.text = tr(&"BACK")

func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		one_shot_mode = config.get_value("Settings", "one_shot_mode", false)
		health_bar_scale = config.get_value("Settings", "health_bar_scale", false)
		reduced_experience = config.get_value("Settings", "reduced_experience", false)
		sound_volume = config.get_value("Settings", "s_volume", 0)
		music_volume = config.get_value("Settings", "m_volume", 0)
		brightness = config.get_value("Settings", "brightness", 0)
		localisation = config.get_value("Settings", "locale", "en")
		TranslationServer.set_locale(localisation)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("Settings", "one_shot_mode", one_shot_mode)
	config.set_value("Settings", "health_bar_scale", health_bar_scale)
	config.set_value("Settings", "reduced_experience", reduced_experience)
	config.set_value("Settings", "m_volume", music_volume)
	config.set_value("Settings", "s_volume", sound_volume)
	config.set_value("Settings", "brightness", brightness)
	config.set_value("Settings", "locale", localisation)
	config.save(CONFIG_PATH)
	
func update_ui():
	one_try.set_pressed(one_shot_mode)
	view_bar_button.set_pressed(health_bar_scale)
	low_exp_scale_button.set_pressed(reduced_experience)
	brightness_slider.value = ((brightness - 0.4)/0.6)
	caption_bright_2.text = str((brightness_slider.value)*100) + "%"
	music_sound_slider.value = 1 - (music_volume/-(10))
	%Caption_music2.text = str(music_sound_slider.value * 100) + "%"
	var current_locale = TranslationServer.get_locale()
	match current_locale:
		"ru":
			ru_button.grab_focus()
		"uk":
			ua_button.grab_focus()
		_:
			%Button.grab_focus()
	change_language_ui()

func _on_one_try_toggled(pressed):
	one_shot_mode = pressed
	save_settings()

func _on_view_bar_toggled(pressed):
	health_bar_scale = pressed
	save_settings()

func _on_low_exp_toggled(pressed):
	reduced_experience = pressed
	save_settings()

func _on_back_main_pressed():
	get_tree().change_scene_to_file("res://src/Scenes/MainMenu/MainScene.tscn")

func _on_music_mute_off_pressed():
	if music_volume == -80:
		music_volume = 0
	else:
		music_volume = -80
	music_sound_slider.value = 1 - (music_volume/-(10))
	%Caption_music2.text = str(music_sound_slider.value * 100) + "%"
	save_settings()
	music_player.set_music_volume(music_volume)

func _on_sound_mute_off_pressed():
	pass

func _on_ru_button_pressed():
	TranslationServer.set_locale("ru")
	localisation = "ru"
	save_settings()
	change_language_ui()

func _on_ua_button_pressed():
	TranslationServer.set_locale("uk")
	localisation = "uk"
	save_settings()
	change_language_ui()

func _on_button_pressed() -> void:
	localisation = "en"
	TranslationServer.set_locale("en")
	save_settings()
	change_language_ui()

func _on_brightness_slider_drag_ended(value_changed: bool) -> void:
	var s = brightness_slider.value
	brightness = 0.4 + 0.6 * s
	caption_bright_2.text = str(((brightness - 0.4)/(0.6))*100) + "%"
	save_settings()
	var canvas_modulate: CanvasModulate = $CanvasModulate
	canvas_modulate.color = Color(brightness, brightness, brightness)

func _on_music_sound_slider_drag_ended(value_changed: bool) -> void:
	if music_sound_slider.value == 0:
		music_volume = -80
		%Caption_music2.text = str(0) + "%"
	else:
		var percentage = music_sound_slider.value
		music_volume = -10 + (percentage * 10)
		%Caption_music2.text = str(percentage * 100) + "%"
	save_settings()
	music_player.set_music_volume(music_volume)
