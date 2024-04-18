extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var step = 48  # Distance between grid lines
	var color = Color(0.8, 0.8, 0.8, 0.3)  # Grid line color

	for i in range(-4800, 4800, step):
		draw_line(Vector2(i, -4800), Vector2(i, 4800), color, 0.1)
		draw_line(Vector2(-4800, i), Vector2(4800, i), color, 0.1)

