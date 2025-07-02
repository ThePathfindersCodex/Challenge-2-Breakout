extends Area2D

#Variables
@export var countdown_time:float = 5.0
@export var flash_frequency_start: float = 0.5 #slow
@export var flash_frequency_max: float = 8.0 #fast
@export var flash_strength: float = 1.0
var gameController:Node2D
var base_color: Color = Color.WHITE
var flash_timer := 0.0

func _ready() -> void:
	gameController = get_tree().current_scene
	base_color = modulate
	flash_timer = 0.0
	await get_tree().create_timer(countdown_time).timeout
	start_explode()
	
func _process(delta: float):
	flash_timer += delta
	var t = clamp(flash_timer / countdown_time, 0.0, 1.0)
	var frequency = lerp(flash_frequency_start, flash_frequency_max, t)
	var time = flash_timer
	var pulse = (sin(time * frequency * TAU) + 1.0) * 0.5
	modulate = base_color.lerp(Color.RED, pulse * flash_strength)

func start_explode():
	# start growing scale up to x2 - over 1 second - then explode:
	var tween := create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(2, 2), 0.5) # grow time
	tween.tween_callback(Callable(self, "explode"))

func explode():
	#print("BOOM")
	var checks = get_overlapping_bodies()
	for obj in checks:
		if obj.is_in_group("block"):
			if obj.health>0: # standard block
				obj.blockHit()
			elif obj.health==-3: # bomb-only block
				obj.destroy()
	queue_free()
