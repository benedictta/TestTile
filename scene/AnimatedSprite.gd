extends AnimatedSprite
export (int) var speed
export (String) var scene_to_load
export (String) var current_scene
var velocity = Vector2()
var timer = 20
onready var ray = $RayCast2D
var tile_size = 64
var target_position = Vector2()
var last_position = Vector2()
func _ready():
	position = position.snapped(Vector2(tile_size, tile_size))
	last_position = position
	target_position = position
	$HUD/GameOver.hide()
	$HUD/TimeLabel.hide()
	if !$play.playing:
		$play.play()

func get_input():
	velocity = Vector2()
	var LEFT = Input.is_action_pressed("ui_left")
	var RIGHT = Input.is_action_pressed("ui_right")
	var UP = Input.is_action_pressed("ui_up")
	var DOWN = Input.is_action_pressed("ui_down")
	if(LEFT || UP):
		self.flip_h = true
	elif(RIGHT || DOWN):
		self.flip_h = false
	
	velocity.x = -int(LEFT) + int(RIGHT)
	velocity.y = -int(UP) + int(DOWN)
	
	if velocity.x != 0 && velocity.y != 0:
		velocity = Vector2.ZERO
	if velocity != Vector2.ZERO:
		ray.cast_to = velocity * tile_size / 2

func _process(delta):
	var tile = get_parent().get_parent().get_node("TileMap").get_cellv(get_parent().get_parent().get_node("TileMap").world_to_map(position))
	print(tile)
	#Movement
	if ray.is_colliding():
		position = last_position
		target_position = last_position
	else:
		position += velocity * delta * speed
	
	if position.distance_to(last_position) >= tile_size - speed * delta: 
			position = target_position
	
	#idle
	if position == target_position:
		get_input()
		last_position = position
		target_position += velocity * tile_size
		if tile == 1 || tile == 2:
			if $play.playing || $intense.playing:
				$play.stop()
				$intense.stop()
			$pain.play()
			gameover()
			yield(get_tree().create_timer(1),"timeout")
			$gameover.play()
		elif tile == 6:
			 get_tree().change_scene(scene_to_load)
		else:
			if tile == 4:
				$play.stop()
				if !$intense.playing:
					$intense.play()
				if $SuddenTimer.is_stopped():
					$HUD/TimeLabel.show()
					$SuddenTimer.start()
					$HUD.update_timer(timer)
			if velocity.length() > 0:
				self.animation = "walk"
			else:
				self.animation = "idle"

func _on_SuddenTimer_timeout():
	timer -= 1
	$HUD.update_timer(timer)
	if timer <= 0:
		gameover()
func gameover():
	self.flip_h = false
	self.flip_v = true
	$SuddenTimer.stop()
	self.animation = "die"
	set_process(false)
	$HUD/GameOver.show()

func _on_Retry_pressed():
	get_tree().change_scene(current_scene)


func _on_Quit_pressed():
	get_tree().change_scene("res://scene/TitleScreen.tscn")
