extends Control

signal back_pressed

@onready var master_volume_slider = $Panel/VBoxContainer/AudioContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_label = $Panel/VBoxContainer/AudioContainer/MasterVolumeContainer/MasterVolumeLabel
@onready var music_volume_slider = $Panel/VBoxContainer/AudioContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_label = $Panel/VBoxContainer/AudioContainer/MusicVolumeContainer/MusicVolumeLabel
@onready var sfx_volume_slider = $Panel/VBoxContainer/AudioContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_label = $Panel/VBoxContainer/AudioContainer/SFXVolumeContainer/SFXVolumeLabel

@onready var fullscreen_button = $Panel/VBoxContainer/VideoContainer/FullscreenButton
@onready var vsync_button = $Panel/VBoxContainer/VideoContainer/VSyncButton

@onready var back_button = $Panel/VBoxContainer/BackButton

var controls: Array = []
var current_control_index: int = 0
var settings_node

func _ready():
	visible = false

	# Obter referência para o autoload GameSettings
	settings_node = get_node("/root/GameSettings")

	# Configurar controles para navegação
	controls = [
		master_volume_slider, music_volume_slider, sfx_volume_slider,
		fullscreen_button, vsync_button, back_button
	]

	# Conectar sinais
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)

	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	vsync_button.pressed.connect(_on_vsync_pressed)
	back_button.pressed.connect(_on_back_pressed)

	# Conectar ao sistema de configurações
	if settings_node:
		settings_node.settings_changed.connect(_update_ui)

func show_menu():
	visible = true
	_update_ui()
	master_volume_slider.grab_focus()
	current_control_index = 0

func _update_ui():
	if not settings_node:
		return

	# Atualizar sliders de volume
	master_volume_slider.value = settings_node.master_volume
	music_volume_slider.value = settings_node.music_volume
	sfx_volume_slider.value = settings_node.sfx_volume

	# Atualizar labels de volume
	master_volume_label.text = "Volume Geral: " + str(int(settings_node.master_volume * 100)) + "%"
	music_volume_label.text = "Volume Música: " + str(int(settings_node.music_volume * 100)) + "%"
	sfx_volume_label.text = "Volume Efeitos: " + str(int(settings_node.sfx_volume * 100)) + "%"

	# Atualizar botões de vídeo
	fullscreen_button.text = "Tela Cheia: " + ("Ligado" if settings_node.fullscreen else "Desligado")
	vsync_button.text = "V-Sync: " + ("Ligado" if settings_node.vsync else "Desligado")

func _input(event):
	if not visible:
		return

	if event.is_action_pressed("ui_down") or event.is_action_pressed("move_down"):
		navigate_down()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("move_up"):
		navigate_up()
	elif event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		adjust_value(-0.1)
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		adjust_value(0.1)

func navigate_down():
	current_control_index = (current_control_index + 1) % controls.size()
	controls[current_control_index].grab_focus()

func navigate_up():
	current_control_index = (current_control_index - 1 + controls.size()) % controls.size()
	controls[current_control_index].grab_focus()

func adjust_value(delta: float):
	var current_control = controls[current_control_index]

	if current_control is HSlider:
		current_control.value = clamp(current_control.value + delta, 0.0, 1.0)
	elif current_control is Button and current_control != back_button:
		current_control.pressed.emit()

func _on_master_volume_changed(value: float):
	if settings_node:
		settings_node.set_master_volume(value)
		master_volume_label.text = "Volume Geral: " + str(int(value * 100)) + "%"

func _on_music_volume_changed(value: float):
	if settings_node:
		settings_node.music_volume = value
		music_volume_label.text = "Volume Música: " + str(int(value * 100)) + "%"

func _on_sfx_volume_changed(value: float):
	if settings_node:
		settings_node.sfx_volume = value
		sfx_volume_label.text = "Volume Efeitos: " + str(int(value * 100)) + "%"

func _on_fullscreen_pressed():
	if settings_node:
		settings_node.toggle_fullscreen()
		_update_ui()

func _on_vsync_pressed():
	if settings_node:
		settings_node.vsync = !settings_node.vsync
		settings_node.apply_settings()
		_update_ui()

func _on_back_pressed():
	if settings_node:
		settings_node.save_settings()
	visible = false
	back_pressed.emit()
