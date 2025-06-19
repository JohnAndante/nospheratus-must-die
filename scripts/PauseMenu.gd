extends Control

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var options_button = $Panel/VBoxContainer/OptionsButton
@onready var restart_button = $Panel/VBoxContainer/RestartButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton
@onready var options_menu = $OptionsMenu
@onready var quit_dialog = $QuitDialog

var buttons: Array[Button] = []
var current_button_index: int = 0
var is_paused: bool = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Configurar array de botões
	buttons = [resume_button, options_button, restart_button, main_menu_button, quit_button]

	# Conectar sinais
	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Conectar sinais do menu de opções
	options_menu.back_pressed.connect(_on_options_back)

	# Conectar sinais do diálogo de sair
	quit_dialog.confirmed.connect(_on_quit_confirmed)
	quit_dialog.canceled.connect(_on_quit_canceled)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

	if not visible or options_menu.visible or quit_dialog.visible:
		return

	if event.is_action_pressed("ui_down") or event.is_action_pressed("move_down"):
		navigate_down()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("move_up"):
		navigate_up()
	elif event.is_action_pressed("ui_accept"):
		buttons[current_button_index].pressed.emit()

func toggle_pause():
	if options_menu.visible or quit_dialog.visible:
		return

	is_paused = !is_paused

	if is_paused:
		show_pause_menu()
	else:
		hide_pause_menu()

func show_pause_menu():
	visible = true
	get_tree().paused = true
	resume_button.grab_focus()
	current_button_index = 0

func hide_pause_menu():
	visible = false
	get_tree().paused = false

func navigate_down():
	current_button_index = (current_button_index + 1) % buttons.size()
	buttons[current_button_index].grab_focus()

func navigate_up():
	current_button_index = (current_button_index - 1 + buttons.size()) % buttons.size()
	buttons[current_button_index].grab_focus()

func _on_resume_pressed():
	is_paused = false
	hide_pause_menu()

func _on_options_pressed():
	options_menu.show_menu()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_quit_pressed():
	quit_dialog.popup_centered()

func _on_options_back():
	resume_button.grab_focus()

func _on_quit_confirmed():
	get_tree().quit()

func _on_quit_canceled():
	resume_button.grab_focus()
