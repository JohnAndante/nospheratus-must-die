extends Area2D

@export var xp_value = 1
@export var attraction_speed = 150.0
@export var collection_speed = 300.0

var target: Node2D = null
var is_attracted = false

func _ready():
	# Adicionar ao grupo para o Player encontrar
	add_to_group("xp_orbs")

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

# Função chamada pelo Player para ativar a atração
func attract_to_player(player: Node2D):
	if not is_attracted:
		target = player
		is_attracted = true

func _on_collect_area_body_entered(_body):
	# Esta função pode ser mantida como backup, mas não é mais necessária
	pass

func collect():
	if target and target.has_method("gain_xp"):
		target.gain_xp(xp_value)

	# Efeito de coleta
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_callback(queue_free)
