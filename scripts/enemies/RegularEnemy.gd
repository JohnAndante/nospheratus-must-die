extends "res://scripts/enemies/Enemy.gd"

func _ready() -> void:
	speed *= 1.0
	health *= 1.0
	damage *= 1.0
	attack_cooldown *= 1.0
	xp_value *= 1

func get_damage_color():
	return Color(1, 0.5, 0.5, 1)
