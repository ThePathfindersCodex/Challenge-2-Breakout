extends CharacterBody2D

#variables
var speed :int =600
var active :bool = false
var ballPool:Node
var wall_taps = 0
var bombScene:PackedScene = preload("res://Scenes/bomb.tscn")
var paddle

func _ready() -> void:
	ballPool = get_tree().get_first_node_in_group("ball pool")

	if(Global.powerup_powerball):
		enable_powerball()
	if(Global.powerup_phaseball):
		enable_phaseball()
	if(Global.powerup_doorbusterball):
		enable_powerup_doorbusterball()
	
	paddle = get_tree().get_first_node_in_group("paddle")
	
func launch(launchVector:Vector2):
	velocity = launchVector *speed
	active = true
	
func play_bounce():
	%AudioBallBounce.play()
	
func play_break():
	%AudioBrickBreak.play()

func play_paddle():
	%AudioPaddleHit.play()
	
func _process(delta):
	if(active):
		
		if(paddle.magnet_ball_active):
			# slightly adjust ball movement towards the first open door
			turn_towards_open_door(delta)

		var collision = move_and_collide(velocity*delta)
		if(collision):
			
			if(collision.get_collider().is_in_group("paddle")):
				play_paddle()
				wall_taps=0 # reset wallhits
			
			if(collision.get_collider().is_in_group("door")):
				wall_taps=0 # reset wallhits
				collision.get_collider().doorHit()
			
			# calculate bounce
			velocity = velocity.bounce(collision.get_normal())
			if(collision.get_collider().is_in_group("block")):
				wall_taps=0# reset wallhits
				collision.get_collider().blockHit(self)

			if(collision.get_collider().is_in_group("paddle") && paddle.magnet_ball_active):
				# stick newball to paddle and destroy original
				paddle.prepareBall()
				paddle.magnet_ball_active=false
				destroy()

			if(collision.get_collider().is_in_group("wall")):
				play_bounce()
				wall_taps +=1 
				if (wall_taps > 5): # num of wall hits before increase speed
					if velocity.length() < 1100: # max speed cutoff
						velocity *= 1.1
						wall_taps=0 # reset wallhits
						#print(velocity.length())

			#print(wall_taps)
			#print(velocity.length())

func destroy():
	queue_free()

func enable_powerball():
	$Sprite2DPowerBall.visible=true

func enable_phaseball():
	$Sprite2DPhaseBall.visible=true

func enable_powerup_doorbusterball():
	$Sprite2DDoorBusterBall.visible=true

func triple():
	if active:
		if ballPool.get_children().size() < 21:
			var offsetAngle = 15
			var currentVector = velocity.normalized()
			var leftBallVector = currentVector.rotated(deg_to_rad(-offsetAngle))
			var rightBallVector = currentVector.rotated(deg_to_rad(offsetAngle))
			createBall(leftBallVector)
			createBall(rightBallVector)
func createBall(direction):
	var newBall = self.duplicate()
	newBall.wall_taps = 0
	var newVelocity = direction
	newBall.launch(newVelocity)
	ballPool.add_child(newBall)
	
func activate_dropbomb():
	# balls drop timebomb
	if active:
		createTimeBomb(5.0)
func createTimeBomb(seconds:float):
	var newBomb = bombScene.instantiate()
	newBomb.countdown_time=seconds
	newBomb.global_position = global_position
	ballPool.owner.add_child(newBomb)

func activate_microball():
	# balls shrink to fit into tight spaces
	if active:
		var old_scale = microsize()
		await get_tree().create_timer(10).timeout
		revertsize(old_scale)
func microsize():
	var old_scale=scale
	scale *= .4
	scale.x=clamp(scale.x,0.25,2.0)
	scale.y=clamp(scale.y,0.25,2.0)
	return old_scale
func revertsize(original_scale):
	scale = original_scale
	
func activate_hyperball():
	# balls destroys most bricks in single hit + grows balls
	if active:
		var old_scale = macrosize()
		var old_speed = increase_speed()
		paddle.hyper_ball_active=true
		await get_tree().create_timer(5).timeout
		paddle.hyper_ball_active=false
		revertsize(old_scale)
		revertspeed(old_speed)
func macrosize():
	var old_scale=scale
	scale *= 1.5
	scale.x=clamp(scale.x,0.25,2.0)
	scale.y=clamp(scale.y,0.25,2.0)
	return old_scale
func increase_speed():
	var old_speed=velocity.length()
	velocity *= 2.0
	return old_speed
func revertspeed(original_speed):
	if original_speed != 0:
		velocity = velocity.normalized() * original_speed
	
func turn_towards_open_door(_delta):
	var doors = ballPool.owner.doorManager.get_children()
	var target_door
	for door in doors:
		if door.state == 3:
			target_door=door
			break
	if target_door != null:
		#print(velocity)
		var target_pos = target_door.position
		var direction_to_target = (target_pos - position).normalized()
		var turn_strength = 0.01
		var new_direction = velocity.normalized().lerp(direction_to_target, turn_strength).normalized()
		# Keep original speed magnitude
		var new_speed = velocity.length()
		velocity = new_direction * new_speed
		#print(velocity)
