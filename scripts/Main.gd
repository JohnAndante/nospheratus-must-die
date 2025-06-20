extends Node2D

# Modo Debug
var debug_mode = false

@onready var player = $Player
@onready var enemy_spawner = $EnemySpawner
@onready var health_bar = $UI/HealthBar
@onready var level_label = $UI/LevelLabel
@onready var xp_bar = $UI/XPBar
@onready var wave_label = $UI/WaveLabel
@onready var kill_count_label = $UI/KillCountLabel
@onready var debug_label = $UI/DebugLabel
@onready var upgrade_menu = $UI/UpgradeMenu
@onready var game_over_screen = $UI/GameOver
@onready var pause_menu = $UI/PauseMenu

var enemy_scene = preload("res://scenes/enemies/RegularEnemy.tscn")
var fast_enemy_scene = preload("res://scenes/enemies/FastEnemy.tscn")
var tank_enemy_scene = preload("res://scenes/enemies/TankEnemy.tscn")

var enemies = []
var spawn_timer = 0.0
var spawn_interval = 2.8
var wave = 1
var enemies_killed_this_wave = 0
var enemies_per_wave = 12

func _ready():
	# Configurar sinais do player
	player.health_changed.connect(_on_player_health_changed)
	player.level_changed.connect(_on_player_level_changed)
	player.xp_changed.connect(_on_player_xp_changed)
	player.show_upgrade_menu.connect(_on_show_upgrade_menu)
	player.player_died.connect(_on_player_died)

	# Configurar menu de upgrade
	upgrade_menu.upgrade_selected.connect(_on_upgrade_selected)

	# Inicializar UI de debug
	update_debug_ui()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		pause_menu.toggle_pause()

	# Debug mode toggle (F10)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F10:
		debug_mode = !debug_mode
		update_debug_ui()
		print("Debug mode: ", "ON" if debug_mode else "OFF")

	# Debug: Click to kill enemies
	if debug_mode and event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			var clicked_enemy = get_enemy_at_position(mouse_pos)
			if clicked_enemy:
				var enemy_type = clicked_enemy.get_script().get_path().get_file().replace(".gd", "")
				print("Debug: Matando inimigo clicado - Tipo: ", enemy_type, " | Vida: ", clicked_enemy.health)
				clicked_enemy.take_damage(9999)  # Dano suficiente para matar qualquer inimigo
			else:
				print("Debug: Nenhum inimigo encontrado na posição clicada")

		# Debug: Right click to spawn enemy
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			var mouse_pos = get_global_mouse_position()
			spawn_enemy_at_position(mouse_pos)
			print("Debug: Spawnando inimigo na posição do mouse: ", mouse_pos)

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0

func spawn_enemy():
	var enemy_scene_to_use = enemy_scene

	# Escolher tipo de inimigo baseado na wave com chances progressivas
	var rand = randf()
	var fast_chance = min(0.4, 0.1 + (wave * 0.05))  # Aumenta chance com wave
	var tank_chance = min(0.3, 0.05 + (wave * 0.03))  # Aumenta chance com wave

	if wave >= 2 and rand < fast_chance:
		if fast_enemy_scene:
			enemy_scene_to_use = fast_enemy_scene
	elif wave >= 4 and rand < (fast_chance + tank_chance):
		if tank_enemy_scene:
			enemy_scene_to_use = tank_enemy_scene

	var enemy = enemy_scene_to_use.instantiate()

	# Aplicar difficulty scaling nos inimigos
	apply_difficulty_scaling(enemy)

	# Spawnar inimigo fora da tela
	var spawn_distance = 700
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
	enemies_per_wave = int(enemies_per_wave * 1.3)

	# Aumentar dificuldade progressivamente
	spawn_interval = max(0.3, spawn_interval * 0.85)

	# Aumentar vida e dano dos inimigos a cada 3 waves
	if wave % 3 == 0:
		increase_enemy_difficulty()

	# Spawnar inimigos mais fortes em waves específicas
	if wave % 5 == 0:
		print("Wave especial! Inimigos mais fortes aparecem!")

	# Atualizar UI
	wave_label.text = "Wave: " + str(wave)
	update_kill_count_ui()
	print("Wave ", wave, " começou! Inimigos para matar: ", enemies_per_wave)
	print("Intervalo de spawn: ", spawn_interval, "s")

func increase_enemy_difficulty():
	# Esta função será chamada pelos inimigos quando spawnarem
	# Vamos criar um multiplicador global de dificuldade
	var difficulty_multiplier = 1.0 + (wave * 0.1)  # +10% por wave
	print("Dificuldade aumentada! Multiplicador: ", difficulty_multiplier)

func apply_difficulty_scaling(enemy):
	# Multiplicador de dificuldade baseado na wave
	var difficulty_multiplier = 1.0 + (wave * 0.15)  # +15% por wave

	# Aumentar vida e dano do inimigo
	if enemy.has_method("set_difficulty"):
		enemy.set_difficulty(difficulty_multiplier)
	else:
		# Aplicar diretamente se não tiver método específico
		enemy.health = int(enemy.health * difficulty_multiplier)
		enemy.damage = int(enemy.damage * difficulty_multiplier)

		# Limitar o scaling para não ficar impossível
		enemy.health = min(enemy.health, enemy.health * 3)  # Máximo 3x a vida original
		enemy.damage = min(enemy.damage, enemy.damage * 2)  # Máximo 2x o dano original

func update_kill_count_ui():
	kill_count_label.text = "Kills: " + str(enemies_killed_this_wave) + "/" + str(enemies_per_wave)

func _on_show_upgrade_menu():
	var available_upgrades = WeaponManager.get_available_upgrades(player.get_weapons(), player.level)
	upgrade_menu.show_upgrades(available_upgrades)

func _on_upgrade_selected(upgrade_type: String):
	# Extrair o nome da arma do texto do upgrade
	var upgrade_name = upgrade_type.split(":")[0]
	apply_upgrade_to_player(upgrade_name)

func apply_upgrade_to_player(upgrade_name: String):
	match upgrade_name:
		"Pistol", "Shotgun", "Laser":
			apply_weapon_upgrade(upgrade_name)
		"Health":
			player.upgrade_stats("health", 25)
		"Speed":
			player.upgrade_stats("speed", 15)
		"Detection":
			player.upgrade_stats("detection", 25)
		"Regeneration":
			player.upgrade_stats("regeneration", 2)
		"Luck":
			player.upgrade_stats("luck", 10)
		"Magnet":
			player.upgrade_stats("magnet", 15)
		"Armor":
			player.upgrade_stats("armor", 15)

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

func update_debug_ui():
	if debug_label:
		if debug_mode:
			debug_label.text = "DEBUG MODE - L-Click: Matar | R-Click: Spawnar | F10: Toggle"
		else:
			debug_label.text = ""

func get_enemy_at_position(mouse_position: Vector2) -> CharacterBody2D:
	# Verificar se há um inimigo na posição clicada
	for enemy in enemies:
		if enemy == null:
			continue

		# Verificar se a posição está dentro da área do inimigo
		var distance = mouse_position.distance_to(enemy.global_position)

		# Ajustar tolerância baseado no tipo de inimigo
		var click_tolerance = 32.0  # Valor padrão

		# Verificar tipo de inimigo e ajustar tolerância
		var script_path = enemy.get_script().get_path().get_file()
		match script_path:
			"TankEnemy.gd":
				click_tolerance = 50.0  # Tank é maior
			"FastEnemy.gd":
				click_tolerance = 25.0  # Fast é menor
			"Enemy.gd":
				click_tolerance = 32.0  # Normal

		if distance <= click_tolerance:
			return enemy

	return null

func spawn_enemy_at_position(spawn_pos: Vector2):
	var enemy_scene_to_use = enemy_scene

	# Escolher tipo de inimigo baseado na wave com chances progressivas
	var rand = randf()
	var fast_chance = min(0.4, 0.1 + (wave * 0.05))  # Aumenta chance com wave
	var tank_chance = min(0.3, 0.05 + (wave * 0.03))  # Aumenta chance com wave

	if wave >= 2 and rand < fast_chance:
		if fast_enemy_scene:
			enemy_scene_to_use = fast_enemy_scene
	elif wave >= 4 and rand < (fast_chance + tank_chance):
		if tank_enemy_scene:
			enemy_scene_to_use = tank_enemy_scene

	var enemy = enemy_scene_to_use.instantiate()

	# Aplicar difficulty scaling nos inimigos
	apply_difficulty_scaling(enemy)

	enemy.global_position = spawn_pos
	enemy.target = player
	enemy.died.connect(_on_enemy_died)

	add_child(enemy)
	enemies.append(enemy)
