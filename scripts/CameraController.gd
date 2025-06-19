extends Camera2D

@onready var target: CharacterBody2D
@export var follow_speed: float = 3.0
@export var offset_distance: float = 0.0

func _ready():
	print(target)
	if target == null:
		target = get_parent().get_node("Player")

func _physics_process(delta: float) -> void:
	if target == null:
		return

	var target_position = target.global_position

	# Interpolação suave para a posição do target
	global_position = global_position.lerp(target_position, follow_speed * delta)
