extends Area2D

@export var xp_value = 10
@export var attraction_speed = 150.0
@export var collection_speed = 300.0

var target: Node2D = null
var is_attracted = false

func _ready():
	# Animação de spawn
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(self, "rotation", TAU, 0.3)

func _physics_process(delta):
	if target and is_attracted:
		var direction = (target.global_position - global_position).normalized()
		var speed = collection_speed if global_position.distance_to(target.global_position) < 50 else attraction_speed
		global_position += direction * speed * delta

		# Coletar se muito próximo
		if global_position.distance_to(target.global_position) < 20:
			collect()

func _on_collect_area_body_entered(body):
	if body.has_method("gain_xp") and not is_attracted:
		target = body
		is_attracted = true

func collect():
	if target and target.has_method("gain_xp"):
		target.gain_xp(xp_value)

	# Efeito de coleta
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_callback(queue_free)
