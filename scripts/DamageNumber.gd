extends Label

var is_setup_complete = false

func _ready():
	# Configuração inicial apenas se setup ainda não foi chamado
	if not is_setup_complete:
		scale = Vector2.ZERO
		modulate = Color.WHITE

func setup(damage_value: int, pos: Vector2):
	text = str(damage_value)
	global_position = pos
	scale = Vector2.ZERO
	is_setup_complete = true

	# Cor baseada no dano
	var damage_color: Color
	if damage_value >= 50:
		damage_color = Color.RED
	elif damage_value >= 30:
		damage_color = Color.ORANGE
	else:
		damage_color = Color.YELLOW

	modulate = damage_color

	# Animação completa em uma única sequência
	var tween = create_tween()

	# Fase 1: Aparecer e crescer (0.0 - 0.2s)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.1)

	# Fase 2: Movimento para cima durante toda a animação (0.0 - 0.8s)
	tween.parallel().tween_property(self, "global_position", global_position + Vector2(0, -25), 0.4)

	# Fase 4: Fade out (0.5 - 0.8s)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)

	# Fase 5: Cleanup
	tween.tween_callback(queue_free)
