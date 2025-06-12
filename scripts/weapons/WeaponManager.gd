class_name WeaponManager
extends Resource

static func get_all_weapon_types() -> Array[String]:
	return ["Pistol", "Shotgun", "Laser"]

static func get_available_upgrades(weapons: Array[WeaponData], player_level: int = 1) -> Array[String]:
	# Criar pools de upgrades diferentes baseados no nível
	var weapon_pool = get_weapon_upgrade_pool(weapons, player_level)
	var stat_pool = get_stat_upgrade_pool(player_level)

	# Sempre garantir 3 opções de upgrade
	var selected_upgrades = select_balanced_upgrades(weapon_pool, stat_pool)

	return selected_upgrades

static func get_weapon_upgrade_pool(weapons: Array[WeaponData], player_level: int) -> Array[String]:
	var weapon_descriptions = {
		"Pistol": "Arma básica confiável",
		"Shotgun": "Múltiplos projéteis devastadores",
		"Laser": "Tiro rápido e preciso com penetração"
	}

	var available_weapons: Array[String] = []
	var all_weapon_types = get_all_weapon_types()

	# Estratégia de disponibilidade baseada no nível
	var weapon_availability = get_weapon_availability_by_level(player_level)

	for weapon_type in all_weapon_types:
		# Verificar se a arma está disponível neste nível
		if not weapon_availability.has(weapon_type):
			continue

		var weapon = find_weapon_by_name(weapons, weapon_type)
		if weapon != null:
			# Arma já possuída - verificar se pode ser upgradada
			if weapon.can_upgrade():
				available_weapons.append(weapon_type + ": " + weapon.get_upgrade_description())
		else:
			# Nova arma - adicionar se desbloqueada
			available_weapons.append(weapon_type + ": " + weapon_descriptions[weapon_type])

	return available_weapons

static func get_stat_upgrade_pool(player_level: int) -> Array[String]:
	var base_stats: Array[String] = [
		"Health: +25 vida máxima",
		"Speed: +15 velocidade de movimento",
		"Detection: +25 alcance de detecção"  # Reduzido de 50 para 25
	]

	# Upgrades especiais desbloqueados por nível
	var special_stats: Array[String] = []

	if player_level >= 3:
		special_stats.append("Regeneration: +2 vida por segundo")

	if player_level >= 5:
		special_stats.append("Luck: +10% chance de crítico")

	if player_level >= 7:
		special_stats.append("Magnet: +15% alcance de coleta de XP")

	if player_level >= 10:
		special_stats.append("Armor: -15% dano recebido")

	var all_stats = base_stats + special_stats
	all_stats.shuffle()
	return all_stats

static func get_weapon_availability_by_level(player_level: int) -> Array[String]:
	var available: Array[String] = ["Pistol"]  # Pistola sempre disponível

	if player_level >= 2:
		available.append("Shotgun")

	if player_level >= 4:
		available.append("Laser")

	return available

static func select_balanced_upgrades(weapon_pool: Array[String], stat_pool: Array[String]) -> Array[String]:
	var selected: Array[String] = []

	# Estratégias diferentes de seleção
	var strategy = randi() % 4

	match strategy:
		0:  # Foco em armas (2 armas + 1 stat)
			selected = select_upgrades_with_ratio(weapon_pool, stat_pool, 2, 1)
		1:  # Foco em stats (1 arma + 2 stats)
			selected = select_upgrades_with_ratio(weapon_pool, stat_pool, 1, 2)
		2:  # Balanceado (1 arma + 1 stat + 1 qualquer)
			selected = select_balanced_mix(weapon_pool, stat_pool)
		3:  # Especialização (3 de um tipo só, se possível)
			selected = select_specialized(weapon_pool, stat_pool)

	# Garantir que sempre temos 3 opções
	while selected.size() < 3:
		var all_options: Array[String] = weapon_pool + stat_pool
		for option in all_options:
			if not selected.has(option) and selected.size() < 3:
				selected.append(option)
				break
		break  # Evitar loop infinito

	# Limitar a 3 opções
	if selected.size() > 3:
		selected = selected.slice(0, 3) as Array[String]

	print("Estratégia de upgrade ", strategy, ": ", selected)
	return selected

static func select_upgrades_with_ratio(weapon_pool: Array[String], stat_pool: Array[String], weapons_count: int, stats_count: int) -> Array[String]:
	var selected: Array[String] = []

	# Adicionar armas
	weapon_pool.shuffle()
	for i in range(min(weapons_count, weapon_pool.size())):
		selected.append(weapon_pool[i])

	# Adicionar stats
	stat_pool.shuffle()
	for i in range(min(stats_count, stat_pool.size())):
		selected.append(stat_pool[i])

	return selected

static func select_balanced_mix(weapon_pool: Array[String], stat_pool: Array[String]) -> Array[String]:
	var selected: Array[String] = []

	# 1 arma garantida
	if weapon_pool.size() > 0:
		weapon_pool.shuffle()
		selected.append(weapon_pool[0])

	# 1 stat garantido
	if stat_pool.size() > 0:
		stat_pool.shuffle()
		selected.append(stat_pool[0])

	# Terceira opção aleatória
	var remaining_options: Array[String] = []
	for option in weapon_pool:
		if not selected.has(option):
			remaining_options.append(option)
	for option in stat_pool:
		if not selected.has(option):
			remaining_options.append(option)

	if remaining_options.size() > 0:
		remaining_options.shuffle()
		selected.append(remaining_options[0])

	return selected

static func select_specialized(weapon_pool: Array[String], stat_pool: Array[String]) -> Array[String]:
	var selected: Array[String] = []

	# Decidir se especializar em armas ou stats
	if weapon_pool.size() >= 3 and randf() > 0.5:
		# Especialização em armas
		weapon_pool.shuffle()
		for i in range(min(3, weapon_pool.size())):
			selected.append(weapon_pool[i])
	elif stat_pool.size() >= 3:
		# Especialização em stats
		stat_pool.shuffle()
		for i in range(min(3, stat_pool.size())):
			selected.append(stat_pool[i])
	else:
		# Fallback para balanceado
		selected = select_balanced_mix(weapon_pool, stat_pool)

	return selected

static func get_random_weapon_selection(_weapons: Array[WeaponData]) -> Array[String]:
	# Esta função não é mais usada, mantida para compatibilidade
	return get_weapon_availability_by_level(1)

static func find_weapon_by_name(weapons: Array[WeaponData], name: String) -> WeaponData:
	for weapon in weapons:
		if weapon.name == name:
			return weapon
	return null

static func create_weapon(weapon_type: String) -> WeaponData:
	match weapon_type:
		"Pistol":
			return PistolData.new()
		"Shotgun":
			return ShotgunData.new()
		"Laser":
			return LaserData.new()
		_:
			return null
