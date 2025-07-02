@tool
extends Node
var block:PackedScene = preload("res://Scenes/block.tscn")
@export_category("Block Settings")
@export var xPadding:float = 10
@export var yPadding:float = 10
@export var numberOfCollumns:int =5
@export var numberOfRows:int =5
@export_range(-5,7) var startingHealth:int =1
var blocks :Array

@export_tool_button("Delete all blocks") 
var deleteBlocksAction = deleteAllBlocks

@export_tool_button("Create blank blocks") 
var createBlocksAction = createBlankBlocks

var sidebarWidth = 139.0

func deleteAllBlocks():
	blocks = get_children()
	for single_block in blocks:
		single_block.queue_free()
	blocks.clear()

func createBlock(x:float, y:float, scaleValue:float):
	var newBlock = block.instantiate()
	newBlock.global_position = Vector2(x,y)
	newBlock.name = "Block" + str(blocks.size())
	newBlock.scale = Vector2.ONE * scaleValue
	blocks.append(newBlock)
	add_child(newBlock)
	newBlock.update(startingHealth)
	newBlock.owner = get_tree().edited_scene_root
	
func createBlankBlocks():
	deleteAllBlocks()
	var screenSize = Vector2.ZERO
	screenSize.x = ProjectSettings.get_setting("display/window/size/viewport_width")
	screenSize.x -= sidebarWidth
	screenSize.y = ProjectSettings.get_setting("display/window/size/viewport_height")
	#get size of the standard block	
	var tempBlock = block.instantiate()
	var blockSprite:Sprite2D = tempBlock.find_child("Sprite2D")
	var blockSize = blockSprite.texture.get_size()
	tempBlock.queue_free()
	
	var widthOfCollumn = blockSize.x + xPadding
	var totalWidthOfCollumns = (widthOfCollumn * numberOfCollumns) - xPadding
	var scaleValue = screenSize.x/ totalWidthOfCollumns

	for x in range(numberOfCollumns):
		for y in range(numberOfRows):
			var newBlockX = (x* (widthOfCollumn*scaleValue)) + (blockSize.x/2 * scaleValue)
			var newBlockY = y * ((blockSize.y+ yPadding) * scaleValue) +(blockSize.y /2 +yPadding*scaleValue) + yPadding/2
			createBlock(newBlockX,newBlockY, scaleValue)
