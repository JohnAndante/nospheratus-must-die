extends CharacterBody2D

signal died(enemy)

@export var speed = 40.0
@export var health = 80
@export var damage = 25

var target: CharacterBody2D
var attack_timer = 0.0
var attack_cooldown = 1.5
var xp_orb_scene = preload("res://scenes/XPOrb.tscn")
var damage_number_scene = preload("res://scenes/DamageNumber.tscn")

func _physics_process(delta):
	if target == null:
		return

	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	attack_timer += delta

func _on_area_2d_body_entered(body):
	if body == target and attack_timer >= attack_cooldown:
		attack_timer = 0.0
		if body.has_method("take_damage"):
			body.take_damage(damage)

func take_damage(damage_amount):
	health -= damage_amount

	# Mostrar número de dano
	var damage_number = damage_number_scene.instantiate()
	get_parent().add_child(damage_number)
	damage_number.setup(damage_amount, global_position)

	# Efeito visual de dano
	modulate = Color.WHITE
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.4, 0.2, 0.8, 1), 0.1)

	if health <= 0:
		die()

func die():
	# Dropar múltiplos XP orbs (tank enemies dão mais XP)
	for i in 3:
		var xp_orb = xp_orb_scene.instantiate()
		get_parent().add_child(xp_orb)
		xp_orb.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		xp_orb.xp_value = 15

	died.emit(self)
	# Usar call_deferred para evitar problemas durante consultas de física
	call_deferred("queue_free")
