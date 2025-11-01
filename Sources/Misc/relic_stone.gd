extends Area2D

@onready var anim = $AnimationPlayer

@export var type: String

var picked_up = false

func _process(_delta: float) -> void:
	if type == "Jump":
		$Sprite2D.frame = 1
		$Label.text = "DOUBLE JUMP"
	elif type == "WallJump":
		$Sprite2D.frame = 2
		$Label.text = "WALL JUMP"
	elif type == "Dash":
		$Sprite2D.frame = 3
		$Label.text = "DASH ABILITY"
	else:
		queue_free()
	
	if picked_up:
		anim.play("Pick_up")
	else:
		anim.play("Idle")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if type == "Jump":
			if body.has_method("relic_jump"):
				var addjump = 1
				picked_up = true
				body.relic_jump(addjump)
				$CollisionShape2D.queue_free()
				$Destroy.start()
		elif type == "WallJump":
			if body.has_method("relic_walljump"):
				var addwalljump = 1
				picked_up = true
				body.relic_walljump(addwalljump)
				$CollisionShape2D.queue_free()
				$Destroy.start()
		elif type == "Dash":
			if body.has_method("relic_adddash"):
				var adddash = true
				picked_up = true
				body.relic_adddash(adddash)
				$CollisionShape2D.queue_free()
				$Destroy.start()
		else:
			return
			
	


func _on_destroy_timeout() -> void:
	queue_free()
