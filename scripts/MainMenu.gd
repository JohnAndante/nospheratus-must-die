extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var options_menu = $OptionsMenu
@onready var quit_dialog = $QuitDialog

var buttons: Array[Button] = []
var current_button_index: int = 0

func _ready():
	# Configurar array de botões para navegação
	buttons = [play_button, options_button, quit_button]

	# Conectar sinais
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Conectar sinais do menu de opções
	options_menu.back_pressed.connect(_on_options_back)

	# Conectar sinais do diálogo de sair
	quit_dialog.confirmed.connect(_on_quit_confirmed)
	quit_dialog.canceled.connect(_on_quit_canceled)

	# Focar no primeiro botão
	play_button.grab_focus()

func _input(event):
	if not visible:
		return

	if options_menu.visible or quit_dialog.visible:
		return

	# Navegação com teclado
	if event.is_action_pressed("move_down"):
		navigate_down()
	elif event.is_action_pressed("move_up"):
		navigate_up()
	elif event.is_action_pressed("ui_accept"):
		buttons[current_button_index].pressed.emit()
	elif event.is_action_pressed("ui_cancel"):
		print("\nCancel pressed")
		print("Options menu visible:", options_menu.visible)
		print("Quit dialog visible:", quit_dialog.visible)
		# Se estiver no menu de opções ou diálogo de sair, fechar o menu ou diálogo
		if options_menu.visible:
			print("Closing options menu")
			options_menu.hide_menu()
			play_button.grab_focus()
		elif quit_dialog.visible:
			print("Closing quit dialog")
			quit_dialog.hide()
			play_button.grab_focus()
		else:
			print("Exiting game")
			# Se não estiver em nenhum menu, sair do jogo
			_on_quit_pressed()

func navigate_down():
	current_button_index = (current_button_index + 1) % buttons.size()
	buttons[current_button_index].grab_focus()

func navigate_up():
	current_button_index = (current_button_index - 1 + buttons.size()) % buttons.size()
	buttons[current_button_index].grab_focus()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_options_pressed():
	options_menu.show_menu()

func _on_quit_pressed():
	quit_dialog.popup_centered()

func _on_options_back():
	play_button.grab_focus()

func _on_quit_confirmed():
	get_tree().quit()

func _on_quit_canceled():
	play_button.grab_focus()
