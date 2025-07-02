extends ColorRect
#Variables
var levelButton = preload("res://Scenes/level button.tscn")
var buttonGroup:ButtonGroup = preload("res://Sources/Level button group.tres")
@onready var gridContainer:GridContainer = $VBoxContainer/GridContainer

var numberOfLevels: int
func _ready() -> void:
	getNumberOfLevels()
	createButtons()
	
func getNumberOfLevels():
	var dir = DirAccess.open("res://Scenes/Levels/") 
	numberOfLevels = dir.get_files().size()
	
func createButtons():
	for i in range (numberOfLevels):
		createButton(i)
		
func createButton(number:int):
	var newButton = levelButton.instantiate()
	newButton.button_group = buttonGroup
	newButton.text = str(number +1)
	newButton.connect("pressed", changeScene)
	gridContainer.add_child(newButton)
	
func changeScene():
	var levelID =1 + buttonGroup.get_buttons().find(buttonGroup.get_pressed_button())
	Global.goToLevel(str(levelID))
