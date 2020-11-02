extends Control
func _ready():
	$title.play()
func _on_newgame_pressed():
	$title.stop()
	get_tree().change_scene("res://scene/level1.tscn")


func _on_quit_pressed():
	get_tree().quit()
