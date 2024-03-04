extends Node2D

var can_place = true
var current_item
onready var level = get_node("/root/LevelEditor/Level")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()

	if (current_item != null and can_place and Input.is_action_just_pressed("ui_left")):
		var new_item = current_item.instance()
		level.add_child(new_item)
		new_item.global_position = global_position
	pass
