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

# Variáveis relacionadas ao movimento
@onready var weapon_pivot = $WeaponPivot
@onready var weapon_timer = $WeaponTimer

var bullet_scene = preload("res://scenes/Bullet.tscn")
var weapons: Array[WeaponData] = []
var current_weapon_index = 0

func _ready():
	health = max_health
	weapons.append(PistolData.new()) # Começa com pistola
	weapon_timer.wait_time = weapons[0].fire_rate

	health_changed.emit(health, max_health)
	level_changed.emit(level)
	xp_changed.emit(xp, xp_to_next)

func _physics_process(_delta):
	handle_input()
	move_and_slide()

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

func _on_weapon_timer_timeout():
	if weapons.size() > 0:
		shoot_current_weapon()

func shoot_current_weapon():
	var weapon = weapons[current_weapon_index]

	# Encontrar o inimigo mais próximo
	var closest_enemy = find_closest_enemy()
	if closest_enemy == null:
		return

	var direction = (closest_enemy.global_position - global_position).normalized()

	weapon.shoot(self, direction, bullet_scene)

	# Trocar para próxima arma se tiver múltiplas
	current_weapon_index = (current_weapon_index + 1) % weapons.size()
	if weapons.size() > current_weapon_index:
		weapon_timer.wait_time = weapons[current_weapon_index].fire_rate

func find_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var viewport_size = get_viewport().get_visible_rect().size
	var max_detection_range = min(viewport_size.x, viewport_size.y) * 0.6

	var closest = null
	var closest_distance = INF

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)

		if distance <= max_detection_range and distance < closest_distance:
			closest_distance = distance
			closest = enemy

	return closest

func take_damage(damage):
	health -= damage
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
