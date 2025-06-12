class_name PistolData
extends WeaponData

func _init():
    name = "Pistol"
    damage = 15.0
    fire_rate = 0.8
    max_level = 5

func apply_upgrade_effects():
    # Alternando de forma não linear entre os upgrades
    match level:
        2, 5, 8: # Melhorias de dano
            damage += damage * 0.20
        3, 6, 9: # Melhorias de velocidade de tiro
            fire_rate = max(0.2, fire_rate - 0.1)
        4, 7, 10: # Níveis especiais, melhora dano e velocidade (em menor grau)
            damage += damage * 0.12
            fire_rate = max(0.2, fire_rate - 0.05)

func shoot(player, direction: Vector2, bullet_scene):
    var bullet = bullet_scene.instantiate()
    player.get_parent().add_child(bullet)
    bullet.global_position = player.global_position
    bullet.direction = direction
    bullet.damage = damage
    bullet.modulate = Color.YELLOW

    # Atualizar tempo do último tiro
    last_shot_time = Time.get_unix_time_from_system()

func get_upgrade_description() -> String:
    # Estudar sobre detalhar esses upgrades ou manter simples
    match level + 1:
        2, 5, 8:
            return "Dano +20%"
        3, 6, 9:
            return "Tiro mais rápido"
        4, 7, 10:
            return "Dano +12% e tiro mais rápido"
        _:
            return "Pistola melhorada"

func get_available_upgrade_types() -> Array[String]:
    return ["damage", "fire_rate", "combo"]
