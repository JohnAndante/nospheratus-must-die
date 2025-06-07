extends Node2D

@onready var player = $Player
@onready var enemy_spawner = $EnemySpawner
@onready var health_bar = $UI/HealthBar
@onready var level_label = $UI/LevelLabel
@onready var xp_bar = $UI/XPBar
@onready var wave_label = $UI/WaveLabel
@onready var kill_count_label = $UI/KillCountLabel
@onready var upgrade_menu = $UI/UpgradeMenu
@onready var game_over_screen = $UI/GameOver
@onready var pause_menu = $UI/PauseMenu

var enemy_scene = preload("res://scenes/Enemy.tscn")
var fast_enemy_scene = preload("res://scenes/FastEnemy.tscn")
var tank_enemy_scene = preload("res://scenes/TankEnemy.tscn")

var enemies = []
var spawn_timer = 0.0
var spawn_interval = 2.0
var wave = 1
var enemies_killed_this_wave = 0
var enemies_per_wave = 10

func _ready():
	# Configurar sinais do player
	player.health_changed.connect(_on_player_health_changed)
	player.level_changed.connect(_on_player_level_changed)
	player.xp_changed.connect(_on_player_xp_changed)
	player.show_upgrade_menu.connect(_on_show_upgrade_menu)
	player.player_died.connect(_on_player_died)

	# Configurar menu de upgrade
	upgrade_menu.upgrade_selected.connect(_on_upgrade_selected)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # ESC
		pause_menu.toggle_pause()

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0

func spawn_enemy():
	var enemy_scene_to_use = enemy_scene

	# Escolher tipo de inimigo baseado na wave
	var rand = randf()
	if wave >= 3 and rand < 0.3:
		if fast_enemy_scene:
			enemy_scene_to_use = fast_enemy_scene
	elif wave >= 5 and rand < 0.2:
		if tank_enemy_scene:
			enemy_scene_to_use = tank_enemy_scene

	var enemy = enemy_scene_to_use.instantiate()

#	Spawnar inimigo fora da tela
	var spawn_distance = 600
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance

	enemy.global_position = spawn_pos
	enemy.target = player
	enemy.died.connect(_on_enemy_died)

	add_child(enemy)
	enemies.append(enemy)

func _on_enemy_died(enemy):
	if enemy in enemies:
		enemies.erase(enemy)

	enemies_killed_this_wave += 1
	update_kill_count_ui()

	if enemies_killed_this_wave >= enemies_per_wave:
		next_wave()

func next_wave():
	wave += 1
	enemies_killed_this_wave = 0
	enemies_per_wave = int(enemies_per_wave * 1.2)

	# Aumentar dificuldade
	spawn_interval = max(0.5, spawn_interval * 0.9)
#
	# Atualizar UI
	wave_label.text = "Wave: " + str(wave)
	update_kill_count_ui()
	print("Wave ", wave, " começou! Inimigos para matar: ", enemies_per_wave)

func update_kill_count_ui():
	kill_count_label.text = "Kills: " + str(enemies_killed_this_wave) + "/" + str(enemies_per_wave)

func _on_show_upgrade_menu():
	var available_upgrades = WeaponManager.get_available_upgrades(player.get_weapons())
	upgrade_menu.show_upgrades(available_upgrades)

func _on_upgrade_selected(upgrade_type: String):
	# Extrair o nome da arma do texto do upgrade
	var upgrade_name = upgrade_type.split(":")[0]
	apply_upgrade_to_player(upgrade_name)

func apply_upgrade_to_player(upgrade_name: String):
	match upgrade_name:
		"Pistol", "Shotgun", "Laser":
			apply_weapon_upgrade(upgrade_name)
		"health":
			player.upgrade_stats("health", 20)
		"speed":
			player.upgrade_stats("speed", 10)

func apply_weapon_upgrade(weapon_name: String):
	if player.has_weapon(weapon_name):
		# Upgrade arma existente
		var weapon = player.get_weapon(weapon_name)
		weapon.upgrade()
	else:
		# Adicionar nova arma
		var new_weapon = WeaponManager.create_weapon(weapon_name)
		if new_weapon != null:
			player.add_weapon(new_weapon)

func toggle_pause():
	get_tree().paused = !get_tree().paused
	print("Jogo ", "pausado" if get_tree().paused else "despausado")

func _on_player_died():
	game_over_screen.show_game_over(player.level, wave)

func _on_player_health_changed(health, max_health):
	health_bar.value = (float(health) / max_health) * 100

func _on_player_level_changed(level):
	level_label.text = "Level: " + str(level)

func _on_player_xp_changed(xp, xp_to_next):
	xp_bar.value = (float(xp) / xp_to_next) * 100
