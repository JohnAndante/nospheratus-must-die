extends Control

@onready var level_label = $Panel/VBoxContainer/StatsContainer/LevelLabel
@onready var wave_label = $Panel/VBoxContainer/StatsContainer/WaveLabel

func _ready():
	visible = false

func show_game_over(level: int, wave: int):
	level_label.text = "Nível Alcançado: " + str(level)
	wave_label.text = "Wave Alcançada: " + str(wave)
	visible = true
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	get_tree().quit()
