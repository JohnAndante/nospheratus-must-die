extends "res://scripts/enemies/Enemy.gd"

func _ready() -> void:
	speed *= 0.6
	health *= 2.0
	damage *= 2.0
	attack_cooldown *= 1.5
	xp_value *= 1

func get_damage_color():
	return Color(1, 0.5, 0.5, 1)

func _spawn_xp_orb():
	for i in 3:
		var xp_orb = xp_orb_scene.instantiate()
		get_parent().add_child(xp_orb)
		xp_orb.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		xp_orb.xp_value = xp_value
