@tool
extends StaticBody2D

#Variables
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_tunnel: Sprite2D = $Sprite2DTunnel
# 1-7 standard
# 0 invuln
# -1 strong block - need powerball - else invuln
# -2 phase block - ball passes through if player has phaseball - else invuln
# -3 bombonly block - need hit with bomb - else invuln
# -4 zombie block - acts like 1 health - respawns after 20 seconds
# -5 hyperclear block - need hyperball else invuln - on destroy, clears all other invuln(0 health)
@export_range(-5,7) var health = 1 :set = update
var colors = [Color.WHITE, Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN ,Color.BLUE, Color.INDIGO, Color.VIOLET]
var powerupSprite: Sprite2D
@export var upgradeType:Global.powerup_type = Global.powerup_type.NONE :set = updatePowerUp
var powerup:PackedScene = load("res://Scenes/powerup.tscn")

func _ready() -> void:
	update(health)
	updatePowerUp(upgradeType)
	
func update(newHealth):
	health = newHealth
	if(sprite_2d == null): return
	if(health >0):
		var newColor :Color= colors[health]
		newColor.s = 0.6
		sprite_2d.modulate = newColor
	elif(health==0):
		var newColor:Color = Color.BLACK
		newColor.v = 0.6
		sprite_2d.modulate = newColor
	elif(health==-1):
		var newColor:Color = Color.BLACK
		newColor.v = 0.4
		sprite_2d.modulate = newColor
	elif(health==-2):
		var newColor:Color = Color.BLUE
		newColor.v = 0.4
		sprite_2d.modulate = newColor
	elif(health==-3):
		var newColor:Color = Color.BLACK
		newColor.v = 0.9
		sprite_2d.modulate = newColor
	elif(health==-4):
		var newColor:Color = Color.GREEN
		newColor.v = 0.4
		sprite_2d.modulate = newColor
	elif(health==-5):
		var newColor:Color = Color.RED
		newColor.v = 0.4
		sprite_2d.modulate = newColor
		
func updatePowerUp(newPowerUp):
	upgradeType = newPowerUp
	powerupSprite = $"Powerup"
	if (upgradeType ==Global.powerup_type.NONE):
		powerupSprite.visible = false
	else:
		powerupSprite.visible = true
		powerupSprite.texture = load(Global.texturePaths[upgradeType])
		
func blockHit(collider):
	var paddle = get_tree().get_first_node_in_group("paddle")
	if(health >0):
		var dmg=1
		if paddle.hyper_ball_active:
			dmg=99
		if Global.xp_rank >= 1:
			dmg+=1
		if Global.powerup_powerball:
			dmg+=1
		update(health-dmg)
		if health<=0:
			if collider != null && collider.has_method("play_break"):
				collider.play_break()
			destroy()
		else:
			%AudioBrickDamage.play()
			
	# strong brick
	if (health==-1 && Global.powerup_powerball):
		update(1)

	# zombie brick
	if (health==-4):
		startRespawnTimer(20)

	#hyperclear brick
	if (health==-5 && paddle.hyper_ball_active):
		performHyperClear()

func startRespawnTimer(seconds):
	owner.call_deferred("startZombieBlockRespawnTimer",self,seconds)

func performHyperClear():
	owner.call_deferred("performBlockHyperClear",self)
	
func destroy():
	owner.gainXP(1)
	if(upgradeType !=Global.powerup_type.NONE):
		createPowerup()
	queue_free()

func createPowerup():
	var newPowerup = powerup.instantiate()
	newPowerup.PowerupType = upgradeType
	newPowerup.global_position = global_position
	get_tree().get_first_node_in_group("upgrade pool").add_child(newPowerup)
	
func enableCollider():
	$CollisionShape2D.disabled=false
func disableCollider():
	$CollisionShape2D.disabled=true
