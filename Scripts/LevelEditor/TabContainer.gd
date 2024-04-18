extends TabContainer

onready var object_cursor = get_node("/root/LevelEditor/EditorObject")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", self, "_on_TabContainer_mouse_entered")
	connect("mouse_exited", self, "_on_TabContainer_mouse_exited")
	pass # Replace with function body.

func _process(delta):
	if (!Global.save_editor_shown):
		if Input.is_action_just_pressed("toggle_editor"):
			Global.playing = !Global.playing
			visible = !Global.playing

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_TabContainer_mouse_entered():
	print("mouse enters tab container")
	object_cursor.can_place = false
	object_cursor.hide()
	pass
	

func _on_TabContainer_mouse_exited():
	print("mouse exits tab container")
	object_cursor.can_place = true
	object_cursor.show()
	pass
