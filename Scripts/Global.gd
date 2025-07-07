@tool
extends Node
enum powerup_type {NONE,TRIPLE, GROW, SHRINK, NEW_BALL, SHIELD, CLOCK, BLOCKS, 
POWERBALL, KEY, PHASEBALL, HEART, DOORBUSTER, 
SPLITBALL, DROP_BOMB, MICROBALL, HYPERBALL, TUNNELBALL, MAGNETBALL}
var texturePaths: Array[String] = [
" ",
"res://Sprites/triple powerup.png",
"res://Sprites/grow powerup.png",
"res://Sprites/shrink powerup.png",
"res://Sprites/new ball powerup.png",
"res://Sprites/shield powerup.png",
"res://Sprites/time powerup.png",
"res://Sprites/blocks powerup.png",

"res://Sprites/powerball powerup.png",
"res://Sprites/key powerup.png",
"res://Sprites/phaseball powerup.png",
"res://Sprites/heart powerup.png",
"res://Sprites/buster powerup.png",

"res://Sprites/splitball powerup.png",
"res://Sprites/dropbomb powerup.png",

"res://Sprites/microball powerup.png",
"res://Sprites/hyperball powerup.png",
"res://Sprites/tunnelball powerup.png",
"res://Sprites/magnetball powerup.png",
]

# player stats - see also resetGlobalStats()
var playTime:float=0.0
var currentLevel:int=0
var powerup_powerball:bool=false
var powerup_phaseball:bool=false
var powerup_doorbusterball:bool=false
var key_counter:int=0
var lives_remaining:int=3
var rooms_visited:Array[int]= []
var xp_points:int=0
var xp_rank:int=0 
var equip_slot1_enabled=false
var equip_slot1=powerup_type.NONE

var xp_points_rank_1 = 100
var xp_points_rank_2 = 250
var xp_points_rank_3 = 2000
var xp_points_rank_4 = 5000

enum hint_type {REACH_DOOR,TOGGLE_DOORS,UNLOCK_DOORS,GET_KEYS,BLAST_DOOR,BOMB_DOOR,TUNNEL_DOOR,FINAL_ROOM}
var hintMessages: Array[String] = [
"Move to the next room using the door.\nSPACE to Launch\nA and D to Move Paddle",
"Use W key to open or close doors.",
"Destroy all bricks to unlock this door.",
"Collect 3 keys to unlock this door.",
"Not sure how to open this door.",
"How do I break these bricks?",
"Something is strange about the left wall.",
"FINAL ROOM!",
]
var level_hints = {
	"1": hint_type.REACH_DOOR,
	"2": hint_type.TOGGLE_DOORS,
	"3": hint_type.UNLOCK_DOORS,
	"8": hint_type.BLAST_DOOR,
	"10": hint_type.GET_KEYS,
	"19": hint_type.BLAST_DOOR,
	"31": hint_type.BOMB_DOOR,
	"25": hint_type.TUNNEL_DOOR,
	"37": hint_type.FINAL_ROOM,
}
var hints_revealed = []

# MAIN MAP (for shader)
var map_rooms = [
	[00,00,00,00,00,00,00,00,00,00,00,00],
	[00,00,00,00,00,00,00,00,00,00,00,00],
	[00,00,00,00,00,00,00,00,00,00,00,00],
	[00,00,00,37,00,00,00,00,00,00,00,00],
	[00,00,00,36,35,34,00,00,00,00,00,00],
	[00,00,00,00,00,33,00,00,00,00,00,00],
	[00,00,00,00,00,32,00,00,00,00,00,00],
	[00,00,00,00,00,31,00,00,00,00,00,00],
	[00,00,00,00,00,26,00,00,00,00,00,00],
	[00,00,00,00,38,25,24,00,00,00,00,00],
	[00,00,00,00,39,00,23,19,20,21,00,00],
	[00,00,00,29,28,00,22,18,00,00,00,00],
	[00,00,00,30,27,00,11,17,00,00,00,00],
	[00,00,00,00,08,07,09,10,00,00,00,00],
	[00,00,00,00,06,04,00,12,00,00,00,00],
	[00,00,00,00,05,03,00,13,16,00,00,00],
	[00,00,00,00,00,02,00,14,15,00,00,00],
	[00,00,00,00,00,01,00,00,00,00,00,00],
]

func resetGlobalStats():
	playTime=0.0
	lives_remaining=3
	powerup_powerball=false
	powerup_phaseball=false
	powerup_doorbusterball=false
	key_counter=0
	rooms_visited=[]
	lives_remaining=3
	xp_points=0
	xp_rank=0
	equip_slot1_enabled=false
	equip_slot1=powerup_type.NONE

func goToMainMenu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func goToLevel(levelID:String):
	currentLevel = levelID.to_int()
	if(currentLevel > getNumberOfLevels()):
		goToEndScreen()
		return
	var path = "res://Scenes/Levels/level_" + str(levelID) + ".tscn"
	get_tree().change_scene_to_file(path)

func goToEndScreen():
	get_tree().change_scene_to_file("res://Scenes/end screen.tscn")

func goToGameOverScreen():
	get_tree().change_scene_to_file("res://Scenes/game over screen.tscn")

func getNumberOfLevels()->int:
	var dir = DirAccess.open("res://Scenes/Levels/") 
	return dir.get_files().size()
	
