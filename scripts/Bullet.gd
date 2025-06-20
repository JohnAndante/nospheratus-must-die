extends Area2D

@export var speed = 200.0
@export var damage = 20
@export var penetration = 0

var direction = Vector2.RIGHT
var initial_penetration = 0

func _ready():
	rotation = direction.angle()
	initial_penetration = penetration

func _physics_process(delta):
	position += direction * speed * delta

# Detecção de colisão
func _on_body_entered(body):
	if body.is_in_group("enemies"):

		if body.has_method("take_damage"):
			body.take_damage(damage)

		if penetration > 0:
			penetration -= 1
			return
		else:
			call_deferred("queue_free")

# Timeout para remover o objeto, referenciado do LifeTimer
func _on_life_timer_timeout():
	call_deferred("queue_free")

func set_penetration(value: int):
	penetration = value
	initial_penetration = value
