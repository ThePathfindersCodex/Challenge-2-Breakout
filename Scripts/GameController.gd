extends Node2D

#variables
var paddle:CharacterBody2D
var ballPool:Node
var numberOfWallBlocks:int =0
var numberOfZombieWallBlocks:int =0
var sidebar:Node
var blockManager:Node
var doorManager:Node

func _ready():
	ballPool = get_tree().get_first_node_in_group("ball pool")
	paddle = get_tree().get_first_node_in_group("paddle")
	sidebar = $Sidebar
	blockManager = $"Block Manager"
	doorManager = $"Door Manager"
	startGame()

func countWallBlocks():
	numberOfWallBlocks =0
	var blocks = blockManager.get_children()
	for block in blocks:
		if block.health > 0:
			numberOfWallBlocks +=1

func countZombieWallBlocks():
	numberOfZombieWallBlocks =0
	var blocks = blockManager.get_children()
	for block in blocks:
		if block.health == -4:
			numberOfZombieWallBlocks +=1

func _process(delta):
	Global.playTime += delta
	checkDebug()
	checkDoors()
	checkEquipSlotActivation()

func checkDebug():
	if(Input.is_action_just_pressed("debug_clear")):
		get_tree().call_group("block","destroy")
	if(Input.is_action_just_pressed("debug_full_life")):
		Global.lives_remaining=3
		gainXP(999)
		gainXP(999)
		gainXP(999)
		gainXP(999)
		#Global.equip_slot1=Global.powerup_type.HYPERBALL
		Global.equip_slot1=Global.powerup_type.SPLITBALL
		updateSidebar()
	
func checkDoors():
	if(Input.is_action_just_pressed("toggle_doors")):
		checkToggleDoors()
		
	var doors = doorManager.get_children()
	for door in doors:
		if door.state == 1 && door.unlock_type==0:
			countWallBlocks()
			if(numberOfWallBlocks <=0):
				door.state = 2   
		elif door.state == 1 && door.unlock_type==2 && Global.key_counter==3:
			door.state = 2   
		elif door.state == 1 && door.unlock_type==3 && door.blastdoor_hits>=3:
			door.state = 2 
		elif door.state == 2 && door.unlock_type==4:
			countZombieWallBlocks()
			if(numberOfZombieWallBlocks >0):
				door.state = 1
		elif door.state == 1 && door.unlock_type==4:
			countZombieWallBlocks()
			if(numberOfZombieWallBlocks ==0):
				door.state = 2
		elif door.unlock_type==5:
			if !paddle.tunnel_ball_active:
				door.visible=false
				door.disableCollider()
				

func checkToggleDoors():
	var doors = doorManager.get_children()
	#0"exists": true/false,          # Does a neighboring room even exist?
	#1"locked": true/false,          # Is this door currently locked?
	#2"closed": true/false,          # Is this door currently closed? (but not locked)
	#3"open": true/false       
	
	var unlocked_doors = []
	var currently_open_index = -1
	
	for door in doors:
		if door.state >= 2:
			unlocked_doors.append(door)

	for i in range(unlocked_doors.size()):
		if unlocked_doors[i].state == 3:
			currently_open_index = i
			break

	for door in unlocked_doors:
		door.state = 2

	if currently_open_index < unlocked_doors.size() - 1:
		unlocked_doors[currently_open_index + 1].state = 3
	else:
		if currently_open_index == -1 and unlocked_doors.size() > 0:
			unlocked_doors[0].state = 3

func checkEquipSlotActivation():
	if(Input.is_action_just_pressed("activate_slot1")):
		paddle.attempt_activate_equipslot1()
	
func startGame():
	paddle.reset()
	paddle.prepareBall()
	countWallBlocks()
	countZombieWallBlocks()
	mark_room_visited(Global.currentLevel)
	updateSidebar()
	showHints()
	checkBlockColliders()

func mark_room_visited(room_number):
	if Global.rooms_visited.find(room_number)==-1:
		Global.rooms_visited.append(room_number)
	
func showHints():
	if (Global.level_hints.has(str(Global.currentLevel))) && (!Global.hints_revealed.has(str(Global.currentLevel))):
		displayHintMessage(Global.level_hints[str(Global.currentLevel)])
	else:
		hideHintMessage()
	
func respawnBall():
	if(get_tree().get_nodes_in_group("ball").size() <=1):
		Global.lives_remaining -= 1
		if(Global.lives_remaining < 1):
			Global.goToGameOverScreen()
		updateSidebar()
		paddle.prepareBall()

func updateSidebar():
	sidebar.updateSidebar()

func displayHintMessage(hint_type:int):
	$LabelHint.modulate.a = 0
	$LabelHint.text=Global.hintMessages[hint_type]
	await get_tree().create_timer(3).timeout
	var tween := create_tween()
	tween.tween_property($LabelHint, "modulate", Color($LabelHint.modulate.r, $LabelHint.modulate.g, $LabelHint.modulate.b, 1), 3.0)
	
	Global.hints_revealed.append(str(Global.currentLevel))
	
	await get_tree().create_timer(5).timeout
	var tween2 := create_tween()
	tween2.tween_property($LabelHint, "modulate", Color($LabelHint.modulate.r, $LabelHint.modulate.g, $LabelHint.modulate.b, 0), 2.0)
	
func hideHintMessage():
	$LabelHint.modulate.a = 0

func floatingRisingText(msg,pos,speed,custom_scale:float):
	var label = Label.new()
	label.scale = Vector2(custom_scale,custom_scale)
	label.text = msg
	label.position = pos
	label.z_index=1
	add_child(label)

	var duration=speed
	var tween : Tween = self.create_tween()
	tween.set_parallel()
	tween.tween_property(label, "modulate:a", 0.0, duration)
	tween.tween_property(label, 'position:y', pos.y - 30, duration)
	await tween.finished
	remove_child(label)
	
func checkBlockColliders():
	var blocks = blockManager.get_children()
	for block in blocks:
		if block.health == -2 && Global.powerup_phaseball:
			block.disableCollider()

func gainXP(amt:int):
	floatingRisingText("+"+str(amt)+" XP",Vector2(674.0,100),1.5,1)
	# level up effects	
		#- rank 1 - deal 1 extra damage per hits
		#- rank 2 - equipment slot activated
		#- rank 3 - reduce equipment cooldown - 5 seconds
		#- rank 4 - reduce equipment cooldown - 5 seconds
	Global.xp_points += amt
	
	# hardcode for test
	#Global.equip_slot1_enabled = true

	if Global.xp_points >= Global.xp_points_rank_4:
		if (Global.xp_rank<4):
			floatingRisingText("RANK UP!\nCooldown Reduced\nMore",Vector2(70,400),4.0,4)
			Global.xp_rank = 4
	elif Global.xp_points >= Global.xp_points_rank_3:
		if (Global.xp_rank<3):
			floatingRisingText("RANK UP!\nCooldown Reduced",Vector2(70,400),4.0,4)
			Global.xp_rank = 3
	elif Global.xp_points >= Global.xp_points_rank_2:
		if (Global.xp_rank<2):
			floatingRisingText("RANK UP!\nItem Slot Activated",Vector2(70,400),4.0,4)
			Global.xp_rank = 2
			Global.equip_slot1_enabled = true
	elif Global.xp_points >= Global.xp_points_rank_1:
		if (Global.xp_rank<1):
			floatingRisingText("RANK UP!\n+1 Damage",Vector2(200,400),4.0,4)
			Global.xp_rank = 1
	
	updateSidebar()

func startZombieBlockRespawnTimer(block,seconds):
	blockManager.remove_child(block)
	await get_tree().create_timer(seconds).timeout
	blockManager.add_child(block)
	block.owner = self

func performBlockHyperClear(trigger_block):
	trigger_block.destroy()
	var blocks = blockManager.get_children()
	for block in blocks:
		if block.health == 0:
			block.destroy()
