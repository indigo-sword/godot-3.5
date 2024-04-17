extends TextureRect

export (PackedScene) var this_scene

onready var object_cursor = get_node("/root/LevelEditor/EditorObject")
onready var cursor_sprite = object_cursor.get_node("Sprite")

var tile_id
var tile_type


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("gui_input",self,"_item_clicked")
	pass 

func _item_clicked(event):
	# Only operate on mouse pressed events
	if (event is InputEvent and event.is_action_pressed("mb_left")):
		Global.current_tile = tile_id
		Global.current_tile_type = tile_type
		cursor_sprite.texture = texture
