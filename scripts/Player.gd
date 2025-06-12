extends CharacterBody2D

signal health_changed(health, max_health)
signal level_changed(level)
signal xp_changed(xp, xp_to_next)
signal show_upgrade_menu
signal player_died

# Variáveis do jogador
@export var speed = 200.0
@export var max_health = 100

var health = 100
var level = 1
var xp = 0
var xp_to_next = 100

var detection_range = 200.0  # Alcance de detecção de inimigos
var regeneration_rate = 0.0  # Vida por segundo
var critical_chance = 0.0    # Chance de crítico
var armor_reduction = 0.0    # Redução de dano

# Variáveis relacionadas ao movimento
@onready var weapon_pivot = $WeaponPivot
@onready var weapon_timer = $WeaponTimer

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

	# Verificar e atirar com cada arma independentemente
	check_and_shoot_weapons()
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
	xp_to_next = int(xp_to_next * 1.2)

	level_changed.emit(level)
	xp_changed.emit(xp, xp_to_next)

	# Mostrar menu de upgrade
	show_upgrade_menu.emit()
	print("Level Up! Nível ", level)

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
		"armor":
			armor_reduction += amount
			print("Redução de dano aumentada para: ", armor_reduction, "%")
# Debug visual - círculos de detecção
func _draw():
	if OS.is_debug_build():
		# Círculo de detecção de inimigos (amarelo) - usa o detection_range
		draw_arc(Vector2.ZERO, detection_range, 0, TAU, 64, Color.YELLOW, 2.0)
