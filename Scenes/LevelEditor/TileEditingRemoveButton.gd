extends Button


# Declare member variables here. Examples:
onready var object_cursor = get_node("/root/LevelEditor/EditorObject")
onready var level = get_node("/root/LevelEditor/Level")
onready var editor = get_node("/root/LevelEditor/CamContainer")
onready var leveleditormenu = get_node("/root/LevelEditor/LevelEditorMenu")
onready var editor_cam = editor.get_node("Camera2D")

# Tilemaps
onready var grid: TileMap = level.get_node("Grid")
onready var ground_tm: TileMap = level.get_node("Ground")
onready var buildings_tm: TileMap = level.get_node("Buildings")
onready var decors_tm: TileMap = level.get_node("Decors")

var click_count = 0
var last_tile_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate = Color(1, 0, 0)
	self.connect("pressed", self, "_on_removeBtn_pressed")
	pass # Replace with function body.
	
func _on_removeBtn_pressed():
	click_count += 1
	if (click_count % 2):
		# Prepare to remove a tile on next click
		print("First click registered. Click again on a tile to remove.")
	elif !(click_count % 2):
		# Perform tile removal
		remove_tile()
		click_count = 0  # Reset click count for next operation
	

func _get_current_tm():
	# Match and return the correct tilemap to place (or remove) the current tile
	match (Global.current_tile_type):
		Global.LevelEditorItemType.GROUND:
			return ground_tm
		Global.LevelEditorItemType.BULDING:
			return buildings_tm
		Global.LevelEditorItemType.DECOR:
			return decors_tm
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func remove_tile():
	var tm = _get_current_tm()
	if (tm):
		var mousepos = tm.world_to_map(get_global_mouse_position() / tm.scale)
		tm.set_cell(mousepos.x, mousepos.y, -1)
		

