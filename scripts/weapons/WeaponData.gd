class_name WeaponData
extends Resource

@export var name: String
@export var damage: int
@export var fire_rate: float
@export var level: int = 1
@export var max_level: int = 5
@export var projectiles: int = 1
@export var speed_multiplier: float = 1.0
@export var penetration: int = 0

var last_shot_time: float = 0.0

func can_upgrade() -> bool:
	return level < max_level

func upgrade():
	if can_upgrade():
		level += 1
		apply_upgrade_effects()

func apply_upgrade_effects():
	pass

func can_shoot(current_time: float) -> bool:
	return current_time - last_shot_time >= fire_rate

func shoot(player, direction: Vector2, bullet_scene):
	pass

func get_upgrade_description() -> String:
	return "Melhora a arma" # Texto default

func get_available_upgrade_types() -> Array[String]:
	return ["damage"]

func apply_specific_upgrade(upgrade_type: String):
	pass
