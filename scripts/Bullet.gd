extends Area2D

@export var speed = 400.0
@export var damage = 20

var direction = Vector2.RIGHT

func _ready():
	rotation = direction.angle()
	pass

func _physics_process(delta):
	position += direction * speed * delta

# Detecção de colisão
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		call_deferred("queue_free")

# Timeout para remover o objeto, referenciado do LifeTimer
func _on_life_timer_timeout():
	call_deferred("queue_free")
