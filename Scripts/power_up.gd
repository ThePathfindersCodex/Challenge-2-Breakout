extends Area2D

#Variables
@export var PowerupType = Global.powerup_type.TRIPLE 
@onready var sprite_2d: Sprite2D = $Sprite2D
var speed:float = 150
var gameController:Node2D

func _ready() -> void:
	gameController = get_tree().current_scene
	connect("body_entered",_on_body_entered)
	sprite_2d.texture = load(Global.texturePaths[PowerupType])
	
func _physics_process(delta: float) -> void:
	global_position.y +=speed *delta
	
func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("paddle")):
		call_deferred("queue_free")
		match (PowerupType):
			Global.powerup_type.TRIPLE:
				call_deferred("triple")
			Global.powerup_type.GROW:
				grow()
			Global.powerup_type.SHRINK:
				shrink()
			Global.powerup_type.NEW_BALL:
				call_deferred("newBall")
			Global.powerup_type.SHIELD:
				shield()
			Global.powerup_type.CLOCK:
				clock()
			Global.powerup_type.BLOCKS:
				blocks()
			Global.powerup_type.POWERBALL:
				powerBall()
			Global.powerup_type.KEY:
				obtainKey()
			Global.powerup_type.PHASEBALL:
				phaseBall()
			Global.powerup_type.HEART:
				obtainHeart()
			Global.powerup_type.DOORBUSTER:
				doorBusterBall()
			Global.powerup_type.SPLITBALL:
				equipSplitball()
			Global.powerup_type.DROP_BOMB:
				equipDropBomb()
			Global.powerup_type.MICROBALL:
				equipMicroBall()
			Global.powerup_type.HYPERBALL:
				equipHyperBall()
			Global.powerup_type.TUNNELBALL:
				equipTunnelBall()
			Global.powerup_type.MAGNETBALL:
				equipMagnetBall()
				
func triple():
	get_tree().call_group("ball","triple")
	
func grow():
	get_tree().call_group("paddle","grow")
	
func shrink():
	get_tree().call_group("paddle","shrink")
	
func newBall():
	get_tree().call_group("paddle","prepareBall")
	
func shield():
	pass
	
func clock():
	pass
	
func blocks():
	pass

func cannot_equip():
	gameController.floatingRisingText("Cannot Equip Yet",Vector2(240,400),2.5,2)
	#print("NOPE - cant use it yet")

func equipSplitball():
	if Global.equip_slot1_enabled==true:
		Global.equip_slot1=Global.powerup_type.SPLITBALL
		get_tree().call_group("paddle","equip_splitball")
		gameController.call_deferred("updateSidebar")
		gameController.floatingRisingText("Item Equipped!\n\nSPLIT BALL",Vector2(180,400),3.5,3)
	else:
		cannot_equip()

func equipDropBomb():
	if Global.equip_slot1_enabled==true:
		Global.equip_slot1=Global.powerup_type.DROP_BOMB
		get_tree().call_group("paddle","equip_dropbomb")
		gameController.call_deferred("updateSidebar")
		gameController.floatingRisingText("Item Equipped!\n\nBOMB BALL",Vector2(180,400),3.5,3)
	else:
		cannot_equip()

func equipMicroBall():
	if Global.equip_slot1_enabled==true:
		Global.equip_slot1=Global.powerup_type.MICROBALL
		get_tree().call_group("paddle","equip_microball")
		gameController.call_deferred("updateSidebar")
		gameController.floatingRisingText("Item Equipped!\n\nSHRINK BALL",Vector2(180,400),3.5,3)
	else:
		cannot_equip()

func equipHyperBall():
	if Global.equip_slot1_enabled==true:
		Global.equip_slot1=Global.powerup_type.HYPERBALL
		get_tree().call_group("paddle","equip_hyperball")
		gameController.call_deferred("updateSidebar")
		gameController.floatingRisingText("Item Equipped!\n\nHYPER BALL",Vector2(180,400),3.5,3)
	else:
		cannot_equip()
		
func equipTunnelBall():
	if Global.equip_slot1_enabled==true:
		Global.equip_slot1=Global.powerup_type.TUNNELBALL
		get_tree().call_group("paddle","equip_tunnelball")
		gameController.call_deferred("updateSidebar")
		gameController.floatingRisingText("Item Equipped!\n\nTUNNEL BALL",Vector2(180,400),3.5,3)
	else:
		cannot_equip()
		
func equipMagnetBall():
	if Global.equip_slot1_enabled==true:
		Global.equip_slot1=Global.powerup_type.MAGNETBALL
		get_tree().call_group("paddle","equip_magnetball")
		gameController.call_deferred("updateSidebar")
		gameController.floatingRisingText("Item Equipped!\n\nMAGNET BALL",Vector2(180,400),3.5,3)
	else:
		cannot_equip()

func powerBall():
	Global.powerup_powerball=true
	get_tree().call_group("ball","enable_powerball")
	gameController.call_deferred("updateSidebar")
	gameController.floatingRisingText("Upgrade Installed!\n\nPOWER BALL",Vector2(180,400),3.5,3)
	
func doorBusterBall():
	Global.powerup_doorbusterball=true
	get_tree().call_group("ball","enable_powerup_doorbusterball")
	gameController.call_deferred("updateSidebar")
	gameController.floatingRisingText("Upgrade Installed!\n\nBUSTER BALL",Vector2(180,400),3.5,3)

func phaseBall():
	Global.powerup_phaseball=true
	get_tree().call_group("ball","enable_phaseball")
	gameController.call_deferred("checkBlockColliders")
	gameController.call_deferred("updateSidebar")
	gameController.floatingRisingText("Upgrade Installed!\n\nPHASE BALL",Vector2(180,400),3.5,3)

func obtainKey():
	Global.key_counter += 1
	get_tree().call_group("door","update_locks")
	gameController.call_deferred("updateSidebar")
	gameController.floatingRisingText("Key Obtained!",Vector2(180,400),3.5,3)
	
func obtainHeart():
	if Global.lives_remaining<3:
		Global.lives_remaining += 1
		gameController.floatingRisingText("Health Up!",Vector2(180,400),3.5,3)
	else:
		gameController.gainXP(1)
	gameController.call_deferred("updateSidebar")
	
