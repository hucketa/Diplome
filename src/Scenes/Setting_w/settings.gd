extends Control

const CONFIG_PATH = "user://settings.cfg"
var hp_scale = false
var gold_scale = false
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
@onready var low_exp_scale_button: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Experience_scale/low_exp_scale_button"
@onready var caption_bright_2: Label = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/BrightnessProgressBar/Caption_bright2"
@onready var music_sound_slider: HSlider = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/MusicProgressBar/music_sound_slider"
@onready var volumme_slider: HSlider = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/SoundProgressBar/volumme_slider"
@onready var en_button: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/Localisation_buttons/VBoxContainer/EnButton"
@onready var less_gold_button: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/HPBarView/less_gold_button"
@onready var hard_mode: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Hard_mode/hard_mode"

func _ready():
	load_settings()
	update_ui()

#Конфиг

func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		hp_scale = config.get_value("Settings", "hp_scale", false)
		gold_scale = config.get_value("Settings", "gold_scale", false)
		reduced_experience = config.get_value("Settings", "reduced_experience", false)
		sound_volume = config.get_value("Settings", "s_volume", 0)
		music_volume = config.get_value("Settings", "m_volume", 0)
		brightness = config.get_value("Settings", "brightness", 1)
		localisation = config.get_value("Settings", "locale", "en")
		TranslationServer.set_locale(localisation)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("Settings", "hp_scale", hp_scale)
	config.set_value("Settings", "gold_scale", gold_scale)
	config.set_value("Settings", "reduced_experience", reduced_experience)
	config.set_value("Settings", "m_volume", music_volume)
	config.set_value("Settings", "s_volume", sound_volume)
	config.set_value("Settings", "brightness", brightness)
	config.set_value("Settings", "locale", localisation)
	config.save(CONFIG_PATH)
	
func update_ui():
	hard_mode.set_pressed(hp_scale)
	less_gold_button.set_pressed(gold_scale)
	low_exp_scale_button.set_pressed(reduced_experience)
	brightness_slider.value = ((brightness - 0.4)/0.6)
	caption_bright_2.text = str((brightness_slider.value)*100) + "%"
	music_sound_slider.value = 1 - (music_volume/-(10))
	%Caption_music2.text = str(music_sound_slider.value * 100) + "%"
	volumme_slider.value = 1 - (sound_volume/-(10))
	%Caption_sound2.text = str(volumme_slider.value * 100) + "%"
	var current_locale = TranslationServer.get_locale()
	match current_locale:
		"ru":
			ru_button.grab_focus()
		"uk":
			ua_button.grab_focus()
		_:
			en_button.grab_focus()

func _on_back_main_pressed():
	get_tree().change_scene_to_file("res://src/Scenes/MainMenu/MainScene.tscn")

#Кнопки мута

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
	if sound_volume == -80:
		sound_volume = 0
	else:
		sound_volume = -80
	%volumme_slider.value = 1 - (sound_volume/-(10))
	%Caption_sound2.text = str(%volumme_slider.value * 100) + "%"
	save_settings()
	GameManager.sfx_volume = sound_volume

#Локализация

func _on_ru_button_pressed():
	TranslationServer.set_locale("ru")
	localisation = "ru"
	save_settings()

func _on_ua_button_pressed():
	TranslationServer.set_locale("uk")
	localisation = "uk"
	save_settings()

func _on_en_button_pressed() -> void:
	TranslationServer.set_locale("en")
	localisation = "en"
	save_settings()

#Слайдеры

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

func _on_volumme_slider_drag_ended(value_changed: bool) -> void:
	if volumme_slider.value == 0:
		sound_volume = -80
		%Caption_sound2.text = str(0)+"%"
	else:
		var percent = volumme_slider.value
		sound_volume = -10  + (percent * 10)
		%Caption_sound2.text = str(percent*100)+"%"
	save_settings()
	GameManager.sfx_volume = sound_volume	

# Дополнительные натсройки

func _on_hard_mode_pressed() -> void:
	if(hp_scale):
		GameManager.set_hp_scale(1)
		hp_scale = false
	else:
		GameManager.set_hp_scale(0.5)
		hp_scale = true
	save_settings()

func _on_less_gold_button_pressed() -> void:
	if(gold_scale):
		GameManager.set_gold_scale(1)
		gold_scale = false
	else:
		GameManager.set_gold_scale(0.5)
		gold_scale = true
	save_settings()

func _on_low_exp_scale_button_pressed() -> void:
	if(reduced_experience):
		GameManager.set_xp_scale(1)
		reduced_experience = false
	else:
		GameManager.set_xp_scale(0.5)
		reduced_experience = true
	save_settings()
