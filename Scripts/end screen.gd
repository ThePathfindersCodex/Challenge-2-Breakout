extends ColorRect

#Variables
@onready var main_menu:Button = $"VBoxContainer/Main Menu"
@onready var quit:Button = $VBoxContainer/Quit

func _ready():
	main_menu.pressed.connect(Global.goToMainMenu)
	quit.pressed.connect(quitGame)
	
	var total_seconds = int(Global.playTime)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	var time_string = "%02d:%02d:%02d" % [hours, minutes, seconds]
	#print("Current time: ", time_string)
	$VBoxContainer/ScoresLabel.text = "Time Played: "+time_string+"\nXP Earned: "+str(Global.xp_points)

func quitGame():
	get_tree().quit()
	
	
