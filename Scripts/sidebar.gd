extends ColorRect

func _process(_delta):
	if Global.equip_slot1_enabled:
		%EquipmentSlot.material.set_shader_parameter("cooldown_progress", owner.paddle.equipslot1_cooldown_percent)

func updateSidebar():
	# update room number
	%RoomNumber.text = "Room # " + str(Global.currentLevel)
	
	# update life counter
	if (Global.lives_remaining==3):
		%Life1.visible=true
		%Life2.visible=true
		%Life3.visible=true
	elif (Global.lives_remaining==2):
		%Life1.visible=true
		%Life2.visible=true
		%Life3.visible=false
	elif (Global.lives_remaining==1):
		%Life1.visible=true
		%Life2.visible=false
		%Life3.visible=false
		
	# update key counter
	if (Global.key_counter==0):
		%HSeparator3.visible=false
		%LabelKeys.visible=false
		%Key1.visible=false
		%Key2.visible=false
		%Key3.visible=false
	if (Global.key_counter==1):
		%HSeparator3.visible=true
		%LabelKeys.visible=true
		%Key1.visible=true
		%Key2.visible=false
		%Key3.visible=false
	if (Global.key_counter==2):
		%HSeparator3.visible=true
		%LabelKeys.visible=true
		%Key1.visible=true
		%Key2.visible=true
		%Key3.visible=false
	if (Global.key_counter>2):
		%HSeparator3.visible=true
		%LabelKeys.visible=true
		%Key1.visible=true
		%Key2.visible=true
		%Key3.visible=true
	
	# update upgrades
	if (Global.powerup_powerball||Global.powerup_phaseball||Global.powerup_doorbusterball):
		%HSeparator4.visible=true
		%LabelUpgrades.visible=true
	else:
		%HSeparator4.visible=false
		%LabelUpgrades.visible=false
		
	if (Global.powerup_powerball):
		%UpgradePowerball.visible=true
	else:
		%UpgradePowerball.visible=false

	if (Global.powerup_phaseball):
		%UpgradePhaseball.visible=true
	else:
		%UpgradePhaseball.visible=false

	if (Global.powerup_doorbusterball):
		%UpgradeDoorBusterball.visible=true
	else:
		%UpgradeDoorBusterball.visible=false

	# update map
	# Flatten the 2D map_rooms array (array of arrays) into a single 1D array
	var flat_map = []
	var visited_flags = []
	for row in Global.map_rooms:
		for room_num in row:
			flat_map.append(room_num)
			visited_flags.append(1 if Global.rooms_visited.has(room_num) else 0)
	# Convert to PackedInt32Array
	var packed_map = PackedInt32Array(flat_map)
	var packed_visited = PackedInt32Array(visited_flags)
	# Set map shader params
	%Map.material.set_shader_parameter("map", packed_map)
	%Map.material.set_shader_parameter("visited", packed_visited)
	%Map.material.set_shader_parameter("rows", Global.map_rooms.size())
	%Map.material.set_shader_parameter("cols", Global.map_rooms[0].size())
	%Map.material.set_shader_parameter("currentLevel", Global.currentLevel)
		
	# update xp and rank
	%CurrentXP.text = "Rank "+str(Global.xp_rank)+"  XP: "+str(Global.xp_points)
	%XPRank.material.set_shader_parameter("current_xp", Global.xp_points)

	# update equipment activation slot
	if Global.equip_slot1_enabled:
		# TODO: might be able to handle this better
		if Global.equip_slot1 == Global.powerup_type.NONE:
			# TODO: need to handle clearing texture?
			#%EquipmentSlot.material.set_shader_parameter("custom_texture", Image.create_empty())
			%LabelActivateEquipment.visible=false
		else:
			# get texture for Global.equip_slot1 and send into shader
			var powerup_texture = load(Global.texturePaths[Global.equip_slot1])
			%EquipmentSlot.material.set_shader_parameter("custom_texture", powerup_texture)
			%LabelActivateEquipment.visible=true
			
		%EquipmentSlot.visible=true
	else:
		%EquipmentSlot.visible=false
		%LabelActivateEquipment.visible=false
