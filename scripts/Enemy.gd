extends CharacterBody2D

signal died(enemy)

@export var speed = 80.0
@export var health = 60
@export var damage = 10

var target: CharacterBody2D
var attack_timer = 0.0
var attack_cooldown = 1.0
var player_in_range = false
var xp_orb_scene = preload("res://scenes/XPOrb.tscn")
var damage_number_scene = preload("res://scenes/DamageNumber.tscn")

func _physics_process(delta):
	if target == null:
		return

	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	attack_timer += delta
		# Atacar continuamente se o player estiver no alcance
	if player_in_range and attack_timer >= attack_cooldown:
		attack_timer = 0.0
		if target.has_method("take_damage"):
			target.take_damage(damage)
			print("Enemy atacou player com ", damage, " de dano")

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
	tween.tween_property(self, "modulate", Color(0.8, 0.2, 0.2, 1), 0.1)

	if health <= 0:
		die()

func die():
	player_in_range = false
	call_deferred("_spawn_xp_orb")
	died.emit(self)
	call_deferred("queue_free")

func _spawn_xp_orb():
	var xp_orb = xp_orb_scene.instantiate()
	get_parent().add_child(xp_orb)
	xp_orb.global_position = global_position
