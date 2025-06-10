class_name LaserData
extends WeaponData

func _init():
    name = "Laser"
    damage = 15
    fire_rate = 2.0
    max_level = 10
    penetration = 0

func apply_upgrade_effects():
    match level:
        2, 6:      # Mais dano
            damage += 15
        3, 7:      # Mais penetração
            penetration += 1
        4, 8:      # Tiro mais rápido
            fire_rate = max(0.5, fire_rate - 0.3)
        5, 9, 10:  # Combo: dano + penetração
            damage += 10
            penetration += 1

func shoot(player, direction: Vector2, bullet_scene):
    var bullet = bullet_scene.instantiate()
    player.get_parent().add_child(bullet)
    bullet.global_position = player.global_position
    bullet.direction = direction
    bullet.damage = damage
    bullet.speed = 600
    bullet.penetration = penetration
    bullet.modulate = Color.CYAN

    # Atualizar tempo do último tiro
    last_shot_time = Time.get_unix_time_from_system()

func get_upgrade_description() -> String:
    match level + 1:
        2, 6:
            return "Dano +15"
        3, 7:
            return "Penetração +1"
        4, 8:
            return "Tiro mais rápido (-0.3s)"
        5, 9, 10:
            return "Dano +10 e penetração +1"
        _:
            return "Laser melhorado"

func get_available_upgrade_types() -> Array[String]:
    return ["damage", "penetration", "fire_rate", "combo"]
