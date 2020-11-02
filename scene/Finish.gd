extends Node

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_SPACE:
			get_tree().change_scene("res://scene/TitleScreen.tscn")
