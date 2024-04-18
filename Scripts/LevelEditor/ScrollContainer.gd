extends ScrollContainer

var ITEM_PER_ROW = 4
var MARGIN = 20

onready var object_cursor = get_node("/root/LevelEditor/EditorObject")
onready var row_container = get_node("VBoxContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", self, "_mouse_enter")
	connect("mouse_exited", self, "_mouse_leave")
	# Put all tiles in tab container once they are all initialized
	self.scroll_horizontal_enabled = true
	self.scroll_vertical_enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _mouse_enter():
	object_cursor.can_place = false
	object_cursor.hide()
	
func _mouse_leave():
	object_cursor.can_place = true
	object_cursor.show()

func scale_textures():
	if row_container == null:
		row_container = get_node("VBoxContainer")
	var container_width: int = self.rect_size.x - MARGIN
	var item_size: Vector2 = Vector2(container_width / ITEM_PER_ROW, container_width / ITEM_PER_ROW)
	var n_items: int = row_container.get_child_count()
	var all_items = row_container.get_children()
	var item_row: Array = []
	for i in range(n_items):
		var item = all_items[i]
		item.expand = true
		item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item.rect_min_size = item_size
		# Group items by row
		if i > 0 and i % ITEM_PER_ROW == 0:
			group_item_row(item_row)
			item_row = []
		item_row.append(item)
	if item_row:
		group_item_row(item_row)

func group_item_row(item_row: Array):
	var h_container = HBoxContainer.new()
	for item in item_row:
		row_container.remove_child(item)
		h_container.add_child(item)
	row_container.add_child(h_container)
