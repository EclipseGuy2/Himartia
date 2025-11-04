extends Control

@export var Buttons: Control
@export var PauseMenu: Panel

@onready var anim = $AnimationPlayer
var is_paused := false
	
func player_stats(health):
	$Buttons/PlayerBar/VBoxContainer/Health.text = "• Health: " + str(health)

func toggle_visibility(object):
	var animation_type : String
	if is_paused:
		animation_type = "close_"
	else:
		animation_type = "open_"
	anim.play(animation_type + str(object.name))
	is_paused = !is_paused

func _on_menu_pressed() -> void:
	toggle_visibility(PauseMenu)

func _on_menubutton_pressed() -> void:
	anim.play("Menu")
	$MenuTimer.start()
		
		
func dash_button(CanDash: bool) -> void:
	$Buttons/dash.modulate = Color(1, 1, 1) if CanDash else Color(0.5, 0.5, 0.5)


func _on_menu_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Sources/Scenes/main_menu.tscn")
