extends CharacterBody2D

@onready var upperanim: AnimationPlayer = $UpperBodyAnim
@onready var loweranim: AnimationPlayer = $LowerBodyAnim
@onready var uppersprite: Sprite2D = $UpperBody
@onready var lowersprite: Sprite2D = $LowerBody
@onready var walljumptimer: Timer = $WallJumpTimer
@onready var Camera: Camera2D = $Camera2D
@onready var BASE_GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var CameraZoom: Vector2 = Vector2(1, 1)
@export var WallJumps: int = 0
@export var Jumps: int = 1
@export var playerdamage: int = 4

const SPEED = 700
const DASH_SPEED = 1400
const JUMP_VELOCITY = -500
const WALL_SLIDE_SPEED = 2200
const WALL_JUMP_BOOST = 500
const FALL_MULTIPLIER = 3
const LOW_JUMP_MULTIPLIER = 3
const KNOCKBACK = 600

var health := 10
var attack := false
var hit := false
var Dash := false
var CanDash := true
var relic_dash := false
var jumps_made := 0
var walljumps_made := 0
var can_wall_jump := false

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")

	# Gravity and wall slide
	if is_on_wall_only() and (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		velocity.y = WALL_SLIDE_SPEED * delta
	elif not is_on_floor():
		if velocity.y > 0.0:
			velocity.y += BASE_GRAVITY * FALL_MULTIPLIER * delta
		elif velocity.y < 0.0 and not Input.is_action_pressed("jump"):
			velocity.y += BASE_GRAVITY * LOW_JUMP_MULTIPLIER * delta
		else:
			velocity.y += BASE_GRAVITY * delta
	else:
		jumps_made = 0
		walljumps_made = 0
		velocity.y = 0.0

	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_wall() and walljumps_made < WallJumps:
			velocity.y = JUMP_VELOCITY
			velocity.x = -direction * WALL_JUMP_BOOST
			can_wall_jump = true
			walljumps_made += 1
			walljumptimer.start()
		elif is_on_floor() or jumps_made < Jumps:
			velocity.y = JUMP_VELOCITY
			jumps_made += 1

	# Movement
	if not Dash:
		if direction and not can_wall_jump:
			velocity.x = direction * SPEED
		elif not can_wall_jump:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Dash
	if relic_dash and Input.is_action_just_pressed("dash") and CanDash:
		if velocity.x != 0:
			velocity.x = direction * DASH_SPEED
			velocity.y = JUMP_VELOCITY
		elif velocity.y < 0:
			velocity.y = -DASH_SPEED
		elif velocity.y > 0:
			velocity.y = DASH_SPEED
		else:
			return
		$DashTimer.start()
		$CanDash.start()
		CanDash = false
		Dash = true

	# Knockback — based on facing direction
	if hit:
		if uppersprite.flip_h:
			velocity.x = KNOCKBACK
		else:
			velocity.x = -KNOCKBACK
		velocity.y = JUMP_VELOCITY

	# Attack (disabled during wallslide)
	if Input.is_action_pressed("attack") and not is_on_wall():
		attack = true
		$Attack.start()

	move_and_slide()

func _process(_delta: float) -> void:
	if is_instance_valid($CanvasLayer/Control):
		$CanvasLayer/Control.player_stats(health)

	if health < 1:
		get_tree().reload_current_scene()

	var direction := Input.get_axis("left", "right")
	var moving := direction != 0
	var airborne := not is_on_floor()
	var walling := is_on_wall()

	# Flip sprites
	if moving:
		uppersprite.flip_h = direction < 0
		lowersprite.flip_h = direction < 0

	# PRIORITY: Hit overrides everything
	if hit:
		upperanim.play("Hit")
		loweranim.play("Hit")
		return

	# Upper body animation
	if attack:
		upperanim.play("Attack")
	elif Dash:
		upperanim.play("Dash")
	elif airborne:
		if walling:
			upperanim.play("Wallslide")
		else:
			upperanim.play("Jump")
	else:
		upperanim.play("Idle")

	# Lower body animation
	if airborne:
		if walling:
			loweranim.play("WallSlide")
		else:
			loweranim.play("Jump")
	elif moving:
		loweranim.play("Walk")
	else:
		loweranim.play("Idle")

	Camera.zoom = CameraZoom

	if is_instance_valid($CanvasLayer/Control):
		$CanvasLayer/Control.dash_button(CanDash)

# Timers
func _on_wall_jump_timet_timeout() -> void:
	can_wall_jump = false

func _on_dash_timer_timeout() -> void:
	Dash = false

func _on_can_dash_timeout() -> void:
	CanDash = true

func _on_hit_timer_timeout() -> void:
	hit = false

func _on_attack_timeout() -> void:
	attack = false

# Damage
func take_damage(damage: int) -> void:
	if hit:
		return
	health -= damage
	hit = true
	$HitTimer.start()

# Relics
func relic_jump(addjump: int) -> void:
	Jumps += addjump

func relic_walljump(addwalljump: int) -> void:
	WallJumps += addwalljump

func relic_adddash(adddash: bool) -> void:
	relic_dash = adddash

# Combat
func _on_attackbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.hit_damage(playerdamage)
