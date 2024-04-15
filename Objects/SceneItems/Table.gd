extends Area2D

var start_pos = Vector2(0,0)
var init = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if !init:
		start_pos = global_position
		init = true
	return
	if(Global.playing):
		global_position.x += 0.3
	else:
		global_position = start_pos
	pass
