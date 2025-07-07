extends CharacterBody2D

#Variables
var speed:int =600
@onready var sprite_2d:Sprite2D = $Sprite2D

var ballScene:PackedScene = preload("res://Scenes/ball.tscn")
var heldBall:CharacterBody2D
@onready var aiming_line:Line2D = $"Aiming Line"
var ballPool :Node

var sidebarWidth = 139.0

var equipslot1_cooldown_percent = 100 # 100 is ready to use, set to 0 on activate
var hyper_ball_active = false
var tunnel_ball_active = false
var magnet_ball_active = false

#When the paddle is loaded into the game, on the main scene starting this code will run.
func _ready():
	ballPool = get_tree().get_first_node_in_group("ball pool")
	reset()
	
func prepareBall():
	heldBall = ballScene.instantiate()
	var height_of_ball = heldBall.find_child("Sprite2D").texture.get_height()
	var ballOrigin = Vector2(0,-height_of_ball)
	heldBall.global_position = ballOrigin 
	add_child(heldBall)
	
	#reset Aiming Line
	aiming_line.global_position = global_position + ballOrigin
	aiming_line.get_child(0).play("aiming")
	aiming_line.visible = true
	

func launchBall():
	var launchAngle = aiming_line.rotation_degrees 
	var launchVector = Vector2.UP.rotated(deg_to_rad(launchAngle))
	
	heldBall.launch(launchVector)
	heldBall.reparent(ballPool,true)
	heldBall= null
	aiming_line.visible = false
	aiming_line.get_child(0).stop()
	
func _process(delta):
	if(Input.is_action_pressed("left")):
		global_position.x -= speed *delta
		
	if(Input.is_action_pressed("right")):
		global_position.x += speed *delta
	
	if(heldBall !=null and Input.is_action_just_pressed("launch")):
		launchBall()
	
	var paddleWidth = 80 * scale.x
	global_position.x = clamp(global_position.x, paddleWidth, get_viewport_rect().size.x - paddleWidth - sidebarWidth)
	
func reset():
	var paddleWidth = 80 * scale.x
	global_position.x = (get_viewport_rect().size.x/2) - sidebarWidth + paddleWidth
	aiming_line.visible = false
	hyper_ball_active = false
	tunnel_ball_active = false
	magnet_ball_active = false

func grow():
	scale *=1.1
	scale.x=clamp(scale.x,0.5,2.0)
	scale.y=clamp(scale.y,0.5,2.0)
	
func shrink():
	scale *=0.9
	scale.x=clamp(scale.x,0.5,2.0)
	scale.y=clamp(scale.y,0.5,2.0)

func equip_splitball():
	# if needed for graphics adjustments
	pass
func equip_dropbomb():
	# if needed for graphics adjustments
	pass
func equip_microball():
	# if needed for graphics adjustments
	pass
func equip_hyperball():
	# if needed for graphics adjustments
	pass
func equip_tunnelball():
	# if needed for graphics adjustments
	pass
func equip_magnetball():
	# if needed for graphics adjustments
	pass

func attempt_activate_equipslot1():
	if Global.equip_slot1 != Global.powerup_type.NONE:
		if equipslot1_cooldown_percent == 100:
			equipslot1_cooldown_percent = 0 # start cooldown
			var cooldown_timer = 20 # base cooldown
			
			# XP RANK cooldown reduction
			if Global.xp_rank == 3:
				cooldown_timer -=  5
			elif Global.xp_rank == 4:
				cooldown_timer -=  10

			#cooldown_timer=10 # hardcode for testing

			var tween := create_tween()
			tween.tween_property(self, "equipslot1_cooldown_percent", 100, cooldown_timer)  
			
			#print("PEW PEW")
			if Global.equip_slot1 == Global.powerup_type.SPLITBALL:
				get_tree().call_group("ball","triple")
			if Global.equip_slot1 == Global.powerup_type.DROP_BOMB:
				get_tree().call_group("ball","activate_dropbomb")
			if Global.equip_slot1 == Global.powerup_type.MICROBALL:
				get_tree().call_group("ball","activate_microball")
			if Global.equip_slot1 == Global.powerup_type.HYPERBALL:
				get_tree().call_group("ball","activate_hyperball")
			if Global.equip_slot1 == Global.powerup_type.TUNNELBALL:
				activate_tunnelball()
			if Global.equip_slot1 == Global.powerup_type.MAGNETBALL:
				activate_magnetball()

func activate_tunnelball():
	# balls phase through all non-special bricks for x seconds - no damage, passes through
	tunnel_ball_active=true
	var blocks = owner.blockManager.get_children()
	for block in blocks:
		if block.health > 0:
			block.disableCollider()
			block.sprite_2d_tunnel.visible=true
	
	#show tunneldoors whle active
	var doors = owner.doorManager.get_children()
	for door in doors:
		if door.unlock_type == 5:
			door.visible=true

	await get_tree().create_timer(1.5).timeout
	tunnel_ball_active=false
	for block in blocks:
		if block != null && block.health > 0:
			block.enableCollider()
			block.sprite_2d_tunnel.visible=false
			
	#hide tunneldoors while inactive
	for door in doors:
		if door.unlock_type == 5:
			door.visible=false
			
func activate_magnetball():
	# 1 ball sticks to paddle, ready to relaunch - similar to NEW_BALL powerup - ball also turns toward open doors
	magnet_ball_active=true
	await get_tree().create_timer(5).timeout
	magnet_ball_active=false
	pass
