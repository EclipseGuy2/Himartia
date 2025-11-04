extends CharacterBody2D

@onready var upperanim = $UpperBodyAnim
@onready var loweranim = $LowerBodyAnim
@onready var uppersprite = $UpperBody
@onready var lowersprite = $LowerBody
@onready var walljumptimer = $WallJumpTimer
@onready var BASE_GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var Camera = $Camera2D

@export var CameraZoom: Vector2 = Vector2(1, 1)
@export var WallJumps = 0
@export var Jumps = 1
@export var playerdamage = 4

const knockback = 200
const SPEED = 700
const DashSPEED = 1400
const JUMP_VELOCITY = -500
const WALL_SLIDE_SPEED = 2200
const WALL_JUMP_BOOST = 500
const FALL_MULTIPLIER = 3
const LOW_JUMP_MULTIPLIER = 3

var attack = false
var hit = false
var relic_dash = false
var CanDash = true
var Dash = false
var health = 10
var jumps_made = 0
var walljumps_made = 0
var can_wall_jump = false

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	
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
	
	if not Dash:
		if direction and not can_wall_jump:
			velocity.x = direction * SPEED
		elif not can_wall_jump:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if relic_dash:
		if Input.is_action_just_pressed("dash") and CanDash:
			if velocity.x != 0:
				velocity.x = direction * DashSPEED
				velocity.y = JUMP_VELOCITY
			elif velocity.y < 0:
				velocity.y = -DashSPEED
			elif velocity.y > 0:
				velocity.y = DashSPEED
			else:
				return
			$DashTimer.start()
			$CanDash.start()
			CanDash = false
			Dash = true
			
	
	if hit:
		velocity.x = direction * knockback
		velocity.y = JUMP_VELOCITY
		
	
	if Input.is_action_pressed("attack"):
		attack = true
		$Attack.start()

	move_and_slide()
	

func _process(_delta: float) -> void:
	if is_instance_valid($CanvasLayer/Control):
		$CanvasLayer/Control.player_stats(health)
		
	
	
	if health < 1:
		get_tree().reload_current_scene()
		
	
	var direction := Input.get_axis("left", "right")

	if direction != 0:
		uppersprite.flip_h = direction < 0
		lowersprite.flip_h = direction < 0
	
	if attack:
		upperanim.play("Attack")
	
	elif hit:
		upperanim.play("Hit")
		loweranim.play("Hit")
	
	elif Dash:
		upperanim.play("Dash")
		
	
	elif not is_on_floor():
		if is_on_wall():
			upperanim.play("Wallslide")
			loweranim.play("WallSlide")
		else:
			upperanim.play("Jump")
			loweranim.play("Jump")
	
	elif direction != 0:
		loweranim.play("Walk")
		
	else:
		upperanim.play("Idle")
		loweranim.play("Idle")
		
	Camera.zoom = CameraZoom
	
	if CanDash:
		if is_instance_valid($CanvasLayer/Control):
			$CanvasLayer/Control.dash_button(CanDash)
	else:
		if is_instance_valid($CanvasLayer/Control):
			$CanvasLayer/Control.dash_button(CanDash)
	
#movement
func _on_wall_jump_timet_timeout() -> void:
	can_wall_jump = false

func _on_dash_timer_timeout() -> void:
	Dash = false

func take_damage(damage):
	if hit:
		return
	else:
		health -= damage
		hit = true
	$HitTimer.start()

func _on_can_dash_timeout() -> void:
	CanDash = true


#relics
func relic_jump(addjump):
	Jumps += addjump
	
func relic_walljump(addwalljump):
	WallJumps += addwalljump
	
func relic_adddash(adddash):
	relic_dash = adddash


func _on_hit_timer_timeout() -> void:
	hit = false


func _on_attackbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.hit_damage(playerdamage)


func _on_attack_timeout() -> void:
	attack = false
