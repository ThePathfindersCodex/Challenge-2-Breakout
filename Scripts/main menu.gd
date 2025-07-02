extends ColorRect

#Variables
@onready var startGame:Button = $"VBoxContainer/Start Game"
@onready var quit:Button = $VBoxContainer/Quit

func _ready():
	resetGlobalsNewGame()
	startGame.pressed.connect(Global.goToLevel.bind("1"))
	quit.pressed.connect(quitGame)

func quitGame():
	get_tree().quit()
	
func resetGlobalsNewGame():
	Global.resetGlobalStats()
	
