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
	paddle.hyper_ball_active=false
	paddle.tunnel_ball_active=false
	paddle.magnet_ball_active=false
		
func launch(launchVector:Vector2):
	velocity = launchVector *speed
	active = true
	
func _process(delta):
	if(active):
		var collision = move_and_collide(velocity*delta)
		if(collision):
			
			if(collision.get_collider().is_in_group("paddle")):
				wall_taps=0 # reset wallhits
			
			if(collision.get_collider().is_in_group("door")):
				wall_taps=0 # reset wallhits
				collision.get_collider().doorHit()
			
			# calculate bounce
			velocity = velocity.bounce(collision.get_normal())
			if(collision.get_collider().is_in_group("block")):
				wall_taps=0# reset wallhits
				collision.get_collider().blockHit()

			if(collision.get_collider().is_in_group("wall")):
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
		if ballPool.get_children().size() < 36:
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
	return old_scale
func increase_speed():
	var old_speed=velocity.length()
	velocity *= 2.0
	return old_speed
func revertspeed(original_speed):
	if original_speed != 0:
		velocity = velocity.normalized() * original_speed
	
