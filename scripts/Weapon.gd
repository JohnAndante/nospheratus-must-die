extends Resource
class_name Weapon

@export var name: String
@export var damage: int
@export var fire_rate: float
@export var projectile_speed: float
@export var level: int = 1
@export var max_level: int = 5

func get_upgrade_description() -> String:
	match name:
		"Pistol":
			return "Aumenta dano em +10"
		"Shotgun":
			return "Aumenta número de projéteis"
		"Laser":
			return "Reduz tempo de recarga"
		_:
			return "Melhora a arma"

func upgrade():
	if level >= max_level:
		return false

	level += 1

	match name:
		"Pistol":
			damage += 10
		"Shotgun":
			damage += 5
		"Laser":
			fire_rate -= 0.1
			fire_rate = max(0.1, fire_rate)

	return true
