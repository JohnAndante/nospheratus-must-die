extends CharacterBody2D

signal health_changed(health, max_health)
signal level_changed(level)
signal xp_changed(xp, xp_to_next)
signal show_upgrade_menu
signal player_died

# Variáveis do jogador
@export var speed = 50.0
@export var max_health = 100

var health = 100
var level = 1
var xp = 0
var xp_to_next = 30

var detection_range = 75.0   # Alcance de detecção de inimigos
var regeneration_rate = 0.0  # Vida por segundo
var critical_chance = 0.0    # Chance de crítico
var base_magnet_range = 10.0 # Alcance base para coleta de XP
var xp_magnet_range = 0.0    # Alcance extra para coleta de XP
var armor_reduction = 0.0    # Redução de dano

# Variáveis relacionadas ao movimento
@onready var weapon_pivot = $WeaponPivot
@onready var weapon_timer = $WeaponTimer

# Sprite do jogador
@onready var sprite = $Sprite2D

var bullet_scene = preload("res://scenes/Bullet.tscn")
var weapons: Array[WeaponData] = []

func _ready():
	# Adicionar o player ao grupo para identificação
	add_to_group("player")

	health = max_health
	weapons.append(PistolData.new())

	health_changed.emit(health, max_health)
	level_changed.emit(level)
	xp_changed.emit(xp, xp_to_next)

func _physics_process(_delta):
	handle_input()
	move_and_slide()

	# Verificar e atirar com cada arma independentemente (só se não estiver pausado)
	if not get_tree().paused:
		check_and_shoot_weapons()
		check_and_attract_xp_orbs()
	else:
		# Atualizar tempo das armas quando pausado para evitar acúmulo
		var current_time = Time.get_unix_time_from_system()
		for weapon in weapons:
			weapon.last_shot_time = current_time

	# Aplicar regeneração se ativa
	if regeneration_rate > 0 and health < max_health:
		health = min(max_health, health + regeneration_rate * _delta)
		health_changed.emit(health, max_health)

func handle_input():
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1

	velocity = input_vector.normalized() * speed

	# Virar o sprite para a direção do movimento
	if input_vector.x != 0:
		sprite.flip_h = input_vector.x > 0

func check_and_shoot_weapons():
	var current_time = Time.get_unix_time_from_system()

	# Encontrar o inimigo mais próximo
	var closest_enemy = find_closest_enemy()
	if closest_enemy == null:
		return

	var direction = (closest_enemy.global_position - global_position).normalized()

	# Verificar cada arma de forma independente
	for weapon in weapons:
		if weapon.can_shoot(current_time):
			weapon.shoot(self, direction, bullet_scene)
			weapon.last_shot_time = current_time

func find_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var closest = null
	var closest_distance = INF

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)

		if distance <= detection_range and distance < closest_distance:
			closest_distance = distance
			closest = enemy

	return closest

func check_and_attract_xp_orbs():
	var xp_orbs = get_tree().get_nodes_in_group("xp_orbs")
	var total_magnet_range = base_magnet_range + xp_magnet_range

	for orb in xp_orbs:
		if orb.has_method("attract_to_player"):
			var distance = global_position.distance_to(orb.global_position)
			if distance <= total_magnet_range:
				orb.attract_to_player(self)

func take_damage(damage):
	# Aplicar redução de dano por armadura
	var final_damage = damage
	if armor_reduction > 0:
		final_damage = damage * (1.0 - armor_reduction / 100.0)
		final_damage = max(1, int(final_damage))  # Garantir pelo menos 1 de dano

	print("Player recebeu ", final_damage, " de dano (original: ", damage, ")")
	health -= final_damage
	health = max(0, health)
	health_changed.emit(health, max_health)

	# Efeito visual de dano
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

	if health <= 0:
		die()

func die():
	print("Game Over!")
	player_died.emit()

func gain_xp(amount):
	xp += amount
	xp_changed.emit(xp, xp_to_next)

	if xp >= xp_to_next:
		level_up()

func level_up():
	level += 1
	xp = 0

	# TODO: Implementar função que calcule isso automaticamente
	var multiplier: float
	if level <= 10:
		multiplier = 1.10
	elif level <= 20:
		multiplier = 1.15
	elif level <= 30:
		multiplier = 1.20
	else:
		multiplier = 1.25

	xp_to_next = int(xp_to_next * multiplier)

	level_changed.emit(level)
	xp_changed.emit(xp, xp_to_next)

	# Mostrar menu de upgrade
	show_upgrade_menu.emit()
	print("Level Up! Nível ", level, " - Próximo nível: ", xp_to_next, " XP")

func add_weapon(weapon: WeaponData):
	weapons.append(weapon)

func has_weapon(weapon_name: String) -> bool:
	return WeaponManager.find_weapon_by_name(weapons, weapon_name) != null

func get_weapon(weapon_name: String) -> WeaponData:
	return WeaponManager.find_weapon_by_name(weapons, weapon_name)

func get_weapons() -> Array[WeaponData]:
	return weapons

func upgrade_stats(stat_type: String, amount: int):
	match stat_type:
		"health":
			max_health += amount
			health = max_health
			health_changed.emit(health, max_health)
		"speed":
			speed += amount
		"detection":
			detection_range += amount
			print("Alcance de detecção aumentado para: ", detection_range)
			queue_redraw()  # Forçar redesenho do círculo
		"regeneration":
			regeneration_rate += amount
			print("Regeneração aumentada para: ", regeneration_rate, " HP/s")
		"luck":
			critical_chance += amount
			print("Chance de crítico aumentada para: ", critical_chance, "%")
		"magnet":
			xp_magnet_range += amount
			print("Alcance de coleta de XP aumentado para: ", xp_magnet_range)
			queue_redraw()  # Forçar redesenho do círculo
		"armor":
			armor_reduction += amount
			print("Redução de dano aumentada para: ", armor_reduction, "%")

func get_magnet_range() -> float:
	return base_magnet_range + xp_magnet_range

# Debug visual - círculos de detecção
func _draw():
	if "Main" in get_tree().get_nodes_in_group("root") and get_tree().get_root().get_node("Main").debug_mode:
		# Círculo de detecção de inimigos (amarelo) - usa o detection_range
		draw_arc(Vector2.ZERO, detection_range, 0, TAU, 64, Color.YELLOW, 2.0)

		# Círculo de atração de XP (azul) - usa o alcance total do magnetismo
		var total_magnet_range = base_magnet_range + xp_magnet_range
		draw_arc(Vector2.ZERO, total_magnet_range, 0, TAU, 64, Color.CYAN, 2.0)
