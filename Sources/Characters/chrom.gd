extends CharacterBody2D

const FALL_MULTIPLIER = 3
const LOW_JUMP_MULTIPLIER = 3

@onready var BASE_GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var damage = 2
@export var health = 4

func _process(_delta: float) -> void:
	if health < 1:
		queue_free()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if velocity.y > 0.0:
			velocity.y += BASE_GRAVITY * FALL_MULTIPLIER * delta
		elif velocity.y < 0.0 and not Input.is_action_pressed("jump"):
			velocity.y += BASE_GRAVITY * LOW_JUMP_MULTIPLIER * delta
		else:
			velocity.y += BASE_GRAVITY * delta
	
	move_and_slide()
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(damage)

func hit_damage(playerdamage):
	health -= playerdamage
