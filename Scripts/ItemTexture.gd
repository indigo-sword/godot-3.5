extends TextureRect

export (PackedScene) var this_scene

onready var object_cursor = get_node("/root/LevelEditor/EditorObject")
onready var cursor_sprite = object_cursor.get_node("Sprite")

export (bool) var tile = false
export var tile_id = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("gui_input",self,"_item_clicked")
	pass 

func _item_clicked(event):
	# Only operate on mouse pressed events
	if (event is InputEvent):
		if (!tile):
			if(event.is_action_pressed("ui_left")):
				object_cursor.current_item = this_scene
				cursor_sprite.texture = texture
				Global.place_tile = false
		else:
			if (event.is_action_pressed("ui_left")):
				Global.place_tile = true
				Global.current_tile = tile_id
				cursor_sprite.texture = null
	pass
