class_name WeaponData
extends Resource

@export var name: String
@export var damage: int
@export var fire_rate: float
@export var level: int = 1
@export var max_level: int = 5
@export var projectiles: int = 1
@export var speed_multiplier: float = 1.0

func can_upgrade() -> bool:
    return level < max_level

func upgrade():
    if can_upgrade():
        level += 1
        apply_upgrade_effects()

func apply_upgrade_effects():
    pass

func shoot(player, direction: Vector2, bullet_scene):
    pass

func get_upgrade_description() -> String:
    return "Melhora a arma" # Texto default
