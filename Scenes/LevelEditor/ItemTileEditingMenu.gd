extends CanvasLayer

export var cam_spd = 100
onready var tab_container: CanvasLayer = get_node("/root/LevelEditor/ItemSelect")
onready var editor_cam: Camera2D = get_node("/root/LevelEditor/CamContainer/Camera2D")
onready var editor = get_node("/root/LevelEditor/CamContainer")
onready var level_editor: Node2D = get_node("/root/LevelEditor/")
onready var level : Node2D = get_node("/root/LevelEditor/Level")
onready var tile_map : TileMap = level.get_node("Ground")  #FIXME
onready var title_popup: Node2D = get_node("/root/LevelEditor/LevelInfoCanvas/LevelInfoEditor")
onready var object_cursor: Node2D = get_node("/root/LevelEditor/EditorObject")
onready var grid_line: Node2D = get_node("/root/LevelEditor/BackgroundGrid")

onready var zoomInBtn: Button = $ZoomInButton
onready var zoomOutBtn: Button = $ZoomOutButton
onready var removeBtn: Button = $RemoveButton
onready var uBtn: Button = $UpButton
onready var rBtn: Button =$RightButton
onready var lBtn: Button =$LeftButton
onready var dBtn: Button =$DownButton

# Tilemap
onready var grid: TileMap = level.get_node("Grid")
onready var ground_tm: TileMap = level.get_node("Ground")
onready var buildings_tm: TileMap = level.get_node("Buildings")
onready var decors_tm: TileMap = level.get_node("Decors")

var click_count = 0
var last_tile_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	removeBtn.modulate = Color(1, 0, 0)
	removeBtn.connect("pressed", self, "_on_removeBtn_pressed")
	zoomInBtn.connect("pressed", self, "_on_ZoomInBtn_pressed")
	zoomOutBtn.connect("pressed", self, "_on_ZoomOutBtn_pressed")
	uBtn.connect("pressed", self, "_on_UpBtn_pressed")
	dBtn.connect("pressed", self, "_on_DownBtn_pressed")
	lBtn.connect("pressed", self, "_on_LeftBtn_pressed")
	rBtn.connect("pressed", self, "_on_RightBtn_pressed")
	
	
	
	pass # Replace with function body.
	
func _on_ZoomInBtn_pressed():
	if (!Global.save_editor_shown):
		editor_cam.zoom -= Vector2(0.1, 0.1)

func _on_ZoomOutBtn_pressed():
	if (!Global.save_editor_shown):
		editor_cam.zoom += Vector2(0.1, 0.1)
	
func _on_UpBtn_pressed():
	if (!Global.save_editor_shown):
		editor.global_position.y -= cam_spd
		
func _on_DownBtn_pressed():
	if (!Global.save_editor_shown):
		editor.global_position.y += cam_spd
	
func _on_RightBtn_pressed():
	if (!Global.save_editor_shown):
		editor.global_position.x += cam_spd
	
func _on_LeftBtn_pressed():
	if (!Global.save_editor_shown):
		editor.global_position.x -= cam_spd

func _on_removeBtn_pressed():
	click_count += 1
	if (click_count % 2):
		# Prepare to remove a tile on next click
		print("First click registered. Click again on a tile to remove.")
	elif !(click_count % 2):
		# Perform tile removal
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


