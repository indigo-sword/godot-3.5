extends TabContainer

onready var object_cursor = get_node("/root/LevelEditor/EditorObject")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if (!Global.filesystem_shown):
		if Input.is_action_just_pressed("toggle_editor"):
			Global.playing = !Global.playing
			visible = !Global.playing

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_TabContainer_mouse_entered():
	object_cursor.can_place = false
	object_cursor.hide()
	pass
	

func _on_TabContainer_mouse_exited():
	object_cursor.can_place = true
	object_cursor.show()
	pass
