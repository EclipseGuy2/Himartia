extends CollisionShape2D

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("left"):
		$"../AnimationPlayer".play("Left")
	elif Input.is_action_pressed("right"):
		$"../AnimationPlayer".play("Right")
	
