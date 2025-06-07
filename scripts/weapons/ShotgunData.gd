class_name ShotgunData
extends WeaponData

func _init():
    name = "Shotgun"
    damage = 15
    fire_rate = 1.5
    max_level = 5
    projectiles = 3

func apply_upgrade_effects():
    damage += 5
    projectiles += 1

func shoot(player, direction: Vector2, bullet_scene):
    var spread_angle = PI / 6 # 30 graus
    for i in projectiles:
        var bullet = bullet_scene.instantiate()
        player.get_parent().add_child(bullet)
        bullet.global_position = player.global_position

        var angle_offset = (i - projectiles / 2.0) * (spread_angle / projectiles)
        var rotated_direction = direction.rotated(angle_offset)
        bullet.direction = rotated_direction
        bullet.damage = damage

func get_upgrade_description() -> String:
    return "Mais projéteis +1 e dano +5"
