extends Control

signal upgrade_selected(upgrade_type: String)

@onready var option1_button = $Panel/VBoxContainer/UpgradeOptions/Option1
@onready var option2_button = $Panel/VBoxContainer/UpgradeOptions/Option2
@onready var option3_button = $Panel/VBoxContainer/UpgradeOptions/Option3

var upgrade_options = []

func _ready():
	visible = false

func show_upgrades(available_upgrades: Array):
	upgrade_options = available_upgrades

	# Sempre mostrar 3 opções, preenchendo com upgrades básicos se necessário
	var options = []

	# Adicionar upgrades disponíveis
	for upgrade in available_upgrades:
		options.append(upgrade)

	# Preencher com upgrades básicos se necessário
	while options.size() < 3:
		if options.size() == 1:
			options.append("Vida +20 HP")
		elif options.size() == 2:
			options.append("Velocidade +10")

	option1_button.text = options[0] if options.size() > 0 else "Upgrade 1"
	option2_button.text = options[1] if options.size() > 1 else "Upgrade 2"
	option3_button.text = options[2] if options.size() > 2 else "Upgrade 3"

	visible = true
	get_tree().paused = true

func _on_option_selected(option_index: int):
	var selected_upgrade = ""

	if option_index < upgrade_options.size():
		selected_upgrade = upgrade_options[option_index]
	else:
		# Upgrades básicos
		match option_index:
			1:
				selected_upgrade = "health"
			2:
				selected_upgrade = "speed"
			_:
				selected_upgrade = "health"

	upgrade_selected.emit(selected_upgrade)
	visible = false
	get_tree().paused = false
