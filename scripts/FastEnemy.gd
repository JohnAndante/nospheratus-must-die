extends CharacterBody2D

signal died(enemy)

@export var speed = 150.0
@export var health = 15
@export var damage = 8

var target: CharacterBody2D
var attack_timer = 0.0
var attack_cooldown = 0.8
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
	tween.tween_property(self, "modulate", Color(1, 0.5, 0.5, 1), 0.1)

	if health <= 0:
		die()

func die():
	# Dropar XP orb usando call_deferred
	call_deferred("_spawn_xp_orb")
	died.emit(self)
	call_deferred("queue_free")

func _spawn_xp_orb():
	var xp_orb = xp_orb_scene.instantiate()
	get_parent().add_child(xp_orb)
	xp_orb.global_position = global_position
	xp_orb.xp_value = 8
