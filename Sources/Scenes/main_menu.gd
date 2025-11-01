extends Control

@onready var anim = $AnimationPlayer

func _on_play_pressed() -> void:
	anim.play("Play")
	$PlayTimer.start()


func _on_quit_pressed() -> void:
	anim.play("Quit")
	$QuitTimer.start()


func _on_play_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Sources/Scenes/scene_1.tscn")


func _on_quit_timer_timeout() -> void:
	get_tree().quit()
