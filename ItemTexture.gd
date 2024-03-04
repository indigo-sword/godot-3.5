extends TextureRect

export (PackedScene) var this_scene

onready var object_cursor = get_node("/root/LevelEditor/EditorObject")
onready var cursor_sprite = object_cursor.get_node("Sprite")


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("gui_input",self,"_item_clicked")
	pass 

func _item_clicked(event):
	# Only operate on mouse pressed events
	if (event is InputEvent):
		if(event.is_action_pressed("ui_left")):
			object_cursor.current_item = this_scene
			cursor_sprite.texture = texture
	pass
