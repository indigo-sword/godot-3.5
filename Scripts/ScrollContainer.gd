extends ScrollContainer

var ITEM_PER_ROW = 5

onready var object_cursor = get_node("/root/LevelEditor/EditorObject")
onready var row_container = get_node("VBoxContainer")
onready var item_container = get_node("VBoxContainer/HBoxContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", self, "mouse_enter")
	connect("mouse_exited", self, "mouse_leave")
	self.scroll_horizontal_enabled = true
	self.scroll_vertical_enabled = true
	scale_textures()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func mouse_enter():
	object_cursor.can_place = false
	object_cursor.hide()
	pass
	
func mouse_leave():
	object_cursor.can_place = true
	object_cursor.show()
	pass

func scale_textures():
	var container_width: int = self.rect_min_size.x
	var item_size: Vector2 = Vector2(container_width / ITEM_PER_ROW, container_width / ITEM_PER_ROW)
	for item in item_container.get_children():
		item.expand = true
		item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item.rect_min_size = item_size
