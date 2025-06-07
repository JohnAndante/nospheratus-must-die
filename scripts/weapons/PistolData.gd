class_name PistolData
extends WeaponData

func _init():
    name = "Pistol"
    damage = 20
    fire_rate = 1.0
    max_level = 5

func apply_upgrade_effects():
    damage += 10

func shoot(player, direction: Vector2, bullet_scene):
    var bullet = bullet_scene.instantiate()
    player.get_parent().add_child(bullet)
    bullet.global_position = player.global_position
    bullet.direction = direction
    bullet.damage = damage

func get_upgrade_description() -> String:
    return "Aumenta dano +10"
