class_name WeaponManager
extends Resource

static func get_all_weapon_types() -> Array[String]:
    return ["Pistol", "Shotgun", "Laser"]

static func get_available_upgrades(weapons: Array[WeaponData]) -> Array[String]:
    var upgrades = []
    var weapon_descriptions = {
        "Pistol": "Arma básica",
        "Shotgun": "Múltiplos projéteis",
        "Laser": "Tiro rápido e preciso"
    }

    for weapon_type in get_all_weapon_types():
        var weapon = find_weapon_by_name(weapons, weapon_type)
        if weapon != null:
            if weapon.can_upgrade():
                upgrades.append(weapon_type + ": " + weapon.get_upgrade_description())
        else:
            upgrades.append(weapon_type + ": " + weapon_descriptions[weapon_type])

    # Adicionar upgrades de player
    upgrades.append("health: +20 vida máxima")
    upgrades.append("speed: +10 velocidade")

    return upgrades

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
