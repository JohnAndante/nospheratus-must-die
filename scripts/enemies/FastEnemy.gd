extends "res://scripts/enemies/Enemy.gd"

func _ready() -> void:
	speed *= 2
	health *= 0.5
	damage *= 0.5
	attack_cooldown *= 1.5
	xp_value *= 1

func get_damage_color():
	return Color(1, 0.5, 0.5, 1)
