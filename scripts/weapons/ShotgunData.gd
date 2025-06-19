class_name ShotgunData
extends WeaponData

func _init():
    name = "Shotgun"
    damage = 12.0
    fire_rate = 1.5
    max_level = 5
    projectiles = 2

func apply_upgrade_effects():
    match level:
        2, 6, 10:  # Mais projéteis
            projectiles += 1
        3, 7:      # Mais dano
            damage += damage * 0.15
        4, 8:      # Tiro mais rápido
            fire_rate = max(0.8, fire_rate - 0.2)
        5, 9:      # Combo: dano + projétil
            damage += damage * 0.10
            projectiles += 1

func get_angle_offset() -> float:
    # O ângulo de dispersão é aleatório, entre -15 e 15 graus
    return randf_range(-PI / 12, PI / 12)

func shoot(player, direction: Vector2, bullet_scene):

    for i in projectiles:
        var bullet = bullet_scene.instantiate()
        player.get_parent().add_child(bullet)
        bullet.global_position = player.global_position

        var angle_offset = (i - projectiles / 2.0) * get_angle_offset()
        var rotated_direction = direction.rotated(angle_offset)
        bullet.direction = rotated_direction
        bullet.damage = damage
        bullet.modulate = Color.ORANGE

    # Atualizar tempo do último tiro
    last_shot_time = Time.get_unix_time_from_system()

func get_upgrade_description() -> String:
    match level + 1:
        2, 6, 10:
            return "Mais projéteis +1"
        3, 7:
            return "Dano +15%"
        4, 8:
            return "Tiro mais rápido (-0.2s)"
        5, 9:
            return "Dano +10% e mais projéteis +1"
        _:
            return "Shotgun melhorada"

func get_available_upgrade_types() -> Array[String]:
    return ["projectiles", "damage", "fire_rate", "combo"]
