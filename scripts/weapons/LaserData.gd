class_name LaserData
extends WeaponData

func _init():
    name = "Laser"
    damage = 10
    fire_rate = 10.5
    max_level = 5

func apply_upgrade_effects():
    damage += 10
    fire_rate = max(0.1, fire_rate - 0.05)

func shoot(player, direction: Vector2, bullet_scene):
    var bullet = bullet_scene.instantiate()
    player.get_parent().add_child(bullet)
    bullet.global_position = player.global_position
    bullet.direction = direction
    bullet.damage = damage
    bullet.speed = 600 # Laser mais rápido
    bullet.modulate = Color.CYAN

func get_upgrade_description() -> String:
    return "Dano +10 e disparo mais rápido"
