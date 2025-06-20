extends CharacterBody2D

signal died(enemy)

@export var speed: float = 50.0
@export var health: float = 60
@export var damage: float = 10
@export var attack_cooldown: float = 1.0
@export var xp_value: int = 1

var target: CharacterBody2D
var attack_timer: float = 0.0
var player_in_range: bool = false
var xp_orb_scene = preload("res://scenes/XPOrb.tscn")
var damage_number_scene = preload("res://scenes/DamageNumber.tscn")

# Sprite do inimigo
@onready var sprite = $Sprite2D

func _physics_process(delta):
	if target == null or not is_instance_valid(target) or target.health <= 0:
		return

	var direction = (target.global_position - global_position).normalized()
	var motion = direction * speed * delta

	if direction.x != 0:
		sprite.flip_h = direction.x > 0

	var collision = move_and_collide(motion)

	attack_timer += delta

	if collision and collision.get_collider().is_in_group("player"):
		if attack_timer >= attack_cooldown:
			attack_timer = 0.0
			if collision.get_collider().has_method("take_damage"):
				collision.get_collider().take_damage(damage)

func _on_area_2d_body_entered(body):
	if body == target:
		player_in_range = true

func _on_area_2d_body_exited(body):
	if body == target:
		player_in_range = false

func take_damage(damage_amount):
	health -= damage_amount

	# Mostrar número de dano
	var damage_number = damage_number_scene.instantiate()
	get_parent().add_child(damage_number)
	damage_number.setup(damage_amount, global_position)

	# Efeito visual de dano
	modulate = Color.WHITE
	var tween = create_tween()
	tween.tween_property(self, "modulate", get_damage_color(), 0.1)

	if health <= 0:
		die()

func get_damage_color():
	return Color(1, 1, 1, 1) # Sobrescreva nos filhos se quiser cor diferente

func die():
	player_in_range = false
	target = null
	call_deferred("_spawn_xp_orb")
	died.emit(self)
	call_deferred("queue_free")

func _spawn_xp_orb():
	var xp_orb = xp_orb_scene.instantiate()
	get_parent().add_child(xp_orb)
	xp_orb.global_position = global_position
	xp_orb.xp_value = xp_value
