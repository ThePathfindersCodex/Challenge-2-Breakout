extends Area2D

#variables
var gameController:Node2D

func _ready() -> void:
	gameController = owner
	connect("area_entered",_on_area_entered)
	connect("body_entered",_on_body_entered)
	
func _on_area_entered(area):
	if(area.is_in_group("power up")):
		area.destroy()
	
func _on_body_entered(body):
	if(body.is_in_group("ball")):
		body.destroy()
		gameController.call_deferred("respawnBall")
		
