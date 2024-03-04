extends Node2D

var can_place = true
var is_planning = true
var current_item
export var cam_spd = 10

onready var level = get_node("/root/LevelEditor/Level")
onready var editor = get_node("/root/LevelEditor/CamContainer")
onready var editor_cam = editor.get_node("Camera2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	editor_cam.current = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()

	if (current_item != null and can_place and Input.is_action_just_pressed("ui_left")):
		var new_item = current_item.instance()
		level.add_child(new_item)
		new_item.global_position = global_position
	
	move_editor()
	is_planning = Input.is_action_pressed("mb_middle")
	pass
	
func move_editor():
	if Input.is_action_pressed("w"):
		editor.global_position.y -= cam_spd
	if Input.is_action_pressed("a"):
		editor.global_position.x -= cam_spd
	if Input.is_action_pressed("s"):
		editor.global_position.y += cam_spd
	if Input.is_action_pressed("d"):
		editor.global_position.x += cam_spd
	pass
	
func _unhandled_input(event):
	if (event.is_action_pressed("zoom_in")):
		editor_cam.zoom -= Vector2(0.1, 0.1)
	if (event.is_action_pressed("zoom_out")):
		editor_cam.zoom += Vector2(0.1, 0.1)
	if (event is InputEventMouseButton):
		if (event.is_pressed()):
			if (event.button_index == BUTTON_WHEEL_UP):
				editor_cam.zoom -= Vector2(0.1, 0.1)
			if (event.button_index == BUTTON_WHEEL_DOWN):
				editor_cam.zoom += Vector2(0.1, 0.1)	
	if (event is InputEventMouseMotion):
		if (is_planning):
			editor.global_position -= event.relative + editor_cam.zoom

