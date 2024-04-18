extends Tabs


# Declare member variables here. Examples:
onready var object_cursor = get_node("/root/LevelEditor/EditorObject")


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", self, "_mouse_enter")
	connect("mouse_exited", self, "_mouse_leave")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _mouse_enter():
	object_cursor.can_place = false
	object_cursor.hide()
	pass
	
func _mouse_leave():
	object_cursor.can_place = true
	object_cursor.show()
	pass
