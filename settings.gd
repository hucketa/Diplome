extends Control

const CONFIG_PATH = "user://settings.cfg"
var one_shot_mode = false
var health_bar_scale = false
var reduced_experience = false
var sound_volume = 0  
var brightness = 0 
var music_volume = 0
var localisation = "ru"  

@onready var sound_val_decrease: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/SoundProgressBar/sound_val_decrease"
@onready var sound_val_increase: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/SoundProgressBar/sound_val_increase"
@onready var mus_val_decrease: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/MusicProgressBar/mus_val_decrease"
@onready var mus_val_increase: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/MusicProgressBar/mus_val_increase"
@onready var bright_val_decrease: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/BrightnessProgressBar/bright_val_decrease"
@onready var bright_val_increase: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/ProgressBars/BrightnessProgressBar/bright_val_increase"
@onready var ru_button: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/Localisation_buttons/VBoxContainer/RuButton"
@onready var en_button: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/Localisation_buttons/VBoxContainer/EnButton"
@onready var ua_button: Button = $"mainContainer/ProgressBars and language Choice/ProgressBars and language Choice/Localisation_buttons/VBoxContainer/UaButton"
@onready var music_mute_off: Button = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/MusicBox/music_mute_off"
@onready var sound_mute_off: Button = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/SoundBox/sound_mute_off"
@onready var one_try: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Hard_mode/one_try"
@onready var view_bar_button: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/HPBarView/view_bar_button"
@onready var low_exp_scale_button: CheckButton = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/Experience_scale/low_exp_scale_button"
@onready var back_button: Button = $"mainContainer/Additional and mute buttons/Additional and mute buttons container/Addition_settings_border_box/Additional_Settings/BackButton"
@onready var button: Button = %Button


func _ready():
	load_settings()
	update_ui()
	one_try.connect("toggled", Callable(self, "_on_one_try_toggled"))
	view_bar_button.connect("toggled", Callable(self, "_on_view_bar_toggled"))
	low_exp_scale_button.connect("toggled", Callable(self, "_on_low_exp_toggled"))
	back_button.connect("pressed", Callable(self, "_on_back_main_pressed"))
	sound_val_increase.connect("pressed", Callable(self, "_on_sound_val_increase_pressed"))
	sound_val_decrease.connect("pressed", Callable(self, "_on_sound_val_decrease_pressed"))
	mus_val_increase.connect("pressed", Callable(self, "_on_mus_val_increase_pressed"))
	mus_val_decrease.connect("pressed", Callable(self, "_on_mus_val_decrease_pressed"))
	bright_val_increase.connect("pressed", Callable(self, "_on_bright_val_increase_pressed"))
	bright_val_decrease.connect("pressed", Callable(self, "_on_bright_val_decrease_pressed"))
	music_mute_off.connect("pressed", Callable(self, "_on_music_mute_off_pressed"))
	sound_mute_off.connect("pressed", Callable(self, "_on_sound_mute_off_pressed"))
	
func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		one_shot_mode = config.get_value("Settings", "one_shot_mode", false)
		health_bar_scale = config.get_value("Settings", "health_bar_scale", false)
		reduced_experience = config.get_value("Settings", "reduced_experience", false)
		sound_volume = config.get_value("Settings", "s_volume", 0)
		music_volume = config.get_value("Settings", "m_volume", 0)
		brightness = config.get_value("Settings", "brightness", 0)
		localisation = config.get_value("Settings", "locale", "en")  # Значение по умолчанию "en"
		TranslationServer.set_locale(localisation)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("Settings", "one_shot_mode", one_shot_mode)
	config.set_value("Settings", "health_bar_scale", health_bar_scale)
	config.set_value("Settings", "reduced_experience", reduced_experience)
	config.set_value("Settings", "m_volume", music_volume)
	config.set_value("Settings", "s_volume", sound_volume)
	config.set_value("Settings", "brightness", brightness)
	config.set_value("Settings", "locale", localisation)  # Сохраняем текущую локализацию
	config.save(CONFIG_PATH)
	
func update_ui():
	one_try.set_pressed(one_shot_mode)
	view_bar_button.set_pressed(health_bar_scale)
	low_exp_scale_button.set_pressed(reduced_experience)
	%Sound_val_bar.value = sound_volume
	%Brightness_bar.value = brightness
	%mus_val_bar.value = music_volume
	var current_locale = TranslationServer.get_locale()
	match current_locale:
		"ru":
			ru_button.grab_focus()
		"ua":
			ua_button.grab_focus()
		_:
			%Button.grab_focus()

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
	get_tree().change_scene_to_file("res://MainScene.tscn")

func _on_sound_val_increase_pressed():
	if sound_volume <= 0 || sound_volume < 100:
		sound_volume+= 5
		%Sound_val_bar.value = sound_volume
		save_settings()

func _on_sound_val_decrease_pressed():
	if sound_volume > -80:  # Уменьшаем громкость до -80 dB
		sound_volume -= 5
		%Sound_val_bar.value = sound_volume
		save_settings()

func _on_mus_val_decrease_pressed():
	if music_volume > -80:  # Уменьшаем громкость до -80 dB
		music_volume -= 5
		%mus_val_bar.value = music_volume
		save_settings()

func _on_mus_val_increase_pressed():
	if music_volume <= 0 || music_volume < 100:
		music_volume+= 5
		%mus_val_bar.value = music_volume
		save_settings()

func _on_bright_val_increase_pressed():
	if brightness < 100:
		brightness += 10
		%Brightness_bar.value = brightness
		save_settings()

func _on_bright_val_decrease_pressed():
	if brightness > 0:
		brightness -= 10
		%Brightness_bar.value = brightness
		save_settings()

func _on_music_mute_off_pressed():
	if music_volume == 0:
		music_volume = 100
	else:
		music_volume = 0
	%mus_val_bar.value = music_volume
	save_settings()

func _on_sound_mute_off_pressed():
	if sound_volume == 0:
		sound_volume = 100
	else:
		sound_volume = 0
	%Sound_val_bar.value = sound_volume
	save_settings()

func _on_ru_button_pressed():
	TranslationServer.set_locale("ru")
	localisation = "ru"
	save_settings()

func _on_ua_button_pressed():
	TranslationServer.set_locale("ua")
	localisation = "ua"
	save_settings()

func _on_button_pressed() -> void:
	localisation = "en"
	TranslationServer.set_locale("en")
	save_settings()
