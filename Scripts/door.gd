@tool
extends StaticBody2D

#Variables
@onready var sprite_2d: Sprite2D = $Sprite2D

#{
  #0"exists": ,          # Does a neighboring room even exist?
  #1"locked": ,          # Is this door currently locked?
  #2"closed": ,          # Is this door currently closed? (but not locked)
  #3"open":              # Can the ball pass through right now?
#}
@export_range(0,3) var state = 1 :set = update
#{
  #0"destroyallblocks": ,# Simply smash all blocks on current level
  #1"manual": , # some other function or event will unlock the door
  #2"collect3keys": , # collecting the third key will unlock this
  #3"blastdoor": , # use DoorBuster upgrade to hit the door 3 times to unlock
  #4"zombie": , # all zombie blocks must be destroyed to unlock
  #5"tunnel": , # door is only visible while tunnelball is active
#}
@export_range(0,5) var unlock_type = 0 :set = update_unlock_type

@export var destination_level :int= 0

var blastdoor_hits = 0 # store hit counter for blastdoors

func _ready() -> void:
	update(state)
	update_unlock_type(unlock_type)
	
func update(newState):
	state = newState
	if(sprite_2d == null): return
	sprite_2d.material.set_shader_parameter("state", newState)
	
	$CollisionShape2D.disabled=false
	if state == 0:
		$CollisionShape2D.disabled=true

func update_unlock_type(newUnlockType):
	unlock_type = newUnlockType
	if(sprite_2d == null): return

	var locks = [$Sprite2DLock1,$Sprite2DLock2,$Sprite2DLock3]
	
	if newUnlockType == 0:
		for lock in locks:
			lock.visible = false
	elif newUnlockType == 1:
		for lock in locks:
			lock.visible = false
	elif newUnlockType == 2:
		$Sprite2DLock1.material.set_shader_parameter("lock_color", Color.RED)
		$Sprite2DLock2.material.set_shader_parameter("lock_color", Color.RED)
		$Sprite2DLock3.material.set_shader_parameter("lock_color", Color.RED)
		for lock in locks:
			lock.visible = true
	elif newUnlockType == 3:
		$Sprite2DLock1.material.set_shader_parameter("lock_color", Color.BLUE)
		$Sprite2DLock2.material.set_shader_parameter("lock_color", Color.BLUE)
		$Sprite2DLock3.material.set_shader_parameter("lock_color", Color.BLUE)
		for lock in locks:
			lock.visible = true
	elif newUnlockType == 4:
		$Sprite2DLock1.material.set_shader_parameter("lock_color", Color.TRANSPARENT)
		$Sprite2DLock2.material.set_shader_parameter("lock_color", Color.DARK_GREEN)
		$Sprite2DLock3.material.set_shader_parameter("lock_color", Color.TRANSPARENT)
		$Sprite2DLock1.visible=false
		$Sprite2DLock2.visible=true
		$Sprite2DLock3.visible=false
	elif newUnlockType == 5:
		for lock in locks:
			lock.visible = false
			
	update_locks()
	
func update_locks():
	var locks = [$Sprite2DLock1,$Sprite2DLock2,$Sprite2DLock3]
	
	if unlock_type==2:
		if Global.key_counter < 1:
			for lock in locks:
				lock.material.set_shader_parameter("active", false)
		if Global.key_counter == 1:
			locks.pop_front().material.set_shader_parameter("active", true)
			locks.pop_front().material.set_shader_parameter("active", false)
			locks.pop_front().material.set_shader_parameter("active", false)
		if Global.key_counter == 2:
			locks.pop_front().material.set_shader_parameter("active", true)
			locks.pop_front().material.set_shader_parameter("active", true)
			locks.pop_front().material.set_shader_parameter("active", false)
		if Global.key_counter >= 3:
			for lock in locks:
				lock.visible = false
	elif unlock_type==3:
		if blastdoor_hits==0:
			for lock in locks:
				lock.material.set_shader_parameter("active", false)
		if blastdoor_hits==1:
			locks.pop_front().material.set_shader_parameter("active", true)
			locks.pop_front().material.set_shader_parameter("active", false)
			locks.pop_front().material.set_shader_parameter("active", false)
		if blastdoor_hits==2:
			locks.pop_front().material.set_shader_parameter("active", true)
			locks.pop_front().material.set_shader_parameter("active", true)
			locks.pop_front().material.set_shader_parameter("active", false)
		if blastdoor_hits==3:
			for lock in locks:
				lock.visible = false
		
func doorHit():
	%AudioBallBounce.play()
	
	if unlock_type==5 and visible:
		Global.call_deferred("goToLevel",str(destination_level))
	else:
		if state==1 && unlock_type==3 && Global.powerup_doorbusterball:
			blastdoor_hits += 1
			#print(blastdoor_hits)
			update_locks()

		if (state<3):
			return
		
		Global.call_deferred("goToLevel",str(destination_level))
