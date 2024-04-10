extends Node2D

var can_place = true
var is_planning = true
var current_item
export var cam_spd = 10
var do_save = false

onready var level = get_node("/root/LevelEditor/Level")
onready var editor = get_node("/root/LevelEditor/CamContainer")
onready var leveleditormenu = get_node("/root/LevelEditor/LevelEditorMenu")
onready var editor_cam = editor.get_node("Camera2D")

onready var tile_map : TileMap = level.get_node("TileMap")
onready var popup : FileDialog = get_node("/root/LevelEditor/ItemSelect/FileDialog")

onready var player_obj = preload("res://Objects/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	editor_cam.current = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()

	if !Global.place_tile:
		if (!Global.filesystem_shown):
			if (current_item != null and can_place and Input.is_action_just_pressed("mb_left")):
				var new_item = current_item.instance()
				level.add_child(new_item)
				new_item.owner = level
				new_item.global_position = global_position
	else:
		if (!Global.filesystem_shown):
			if (can_place):
				if Input.is_action_pressed("mb_left"):
					place_tile()
				if Input.is_action_pressed("mb_right"):
					remove_tile()
	
	move_editor()
	
	if Input.is_action_pressed("save"):
		Global.filesystem_shown = true
		do_save = true
		popup.mode = 4
		popup.show()
	if Input.is_action_pressed("load"):
		Global.filesystem_shown = true
		do_save = true
		popup.mode = 0
		popup.show()
		
	is_planning = Input.is_action_pressed("mb_middle")
	pass

func place_tile():
	var mousepos = tile_map.world_to_map(get_global_mouse_position())
	tile_map.set_cell(mousepos.x, mousepos.y, Global.current_tile)
	
func remove_tile():
	var mousepos = tile_map.world_to_map(get_global_mouse_position())
	tile_map.set_cell(mousepos.x, mousepos.y, -1)	
	
func move_editor():
	# FIXME: fix moving editor (currently compromising player movement)
	if (!Global.filesystem_shown):
		if Input.is_action_pressed("w"):
			editor.global_position.y -= cam_spd
		if Input.is_action_pressed("a"):
			editor.global_position.x -= cam_spd
		if Input.is_action_pressed("s"):
			editor.global_position.y += cam_spd
		if Input.is_action_pressed("d"):
			editor.global_position.x += cam_spd
	
func _unhandled_input(event):
	if (!Global.filesystem_shown):
		if (event.is_action_pressed("zoom_in")):
			editor_cam.zoom -= Vector2(0.1, 0.1)
		if (event.is_action_pressed("zoom_out")):
			editor_cam.zoom += Vector2(0.1, 0.1)
		if (event is InputEventMouseButton):
			if (event.is_pressed()):
				if (event.button_index == BUTTON_WHEEL_UP):
					editor_cam.zoom -= Vector2(0.1, 0.1)
				if (event.button_index == BUTTON_WHEEL_DOWN):
					editor_cam.zoom += Vector2(0.1, 0.1)	
		if (event is InputEventMouseMotion):
			if (is_planning):
				editor.global_position -= event.relative + editor_cam.zoom

func save_level():
	var toSave : PackedScene = PackedScene.new()
	tile_map.owner = level
	toSave.pack(level)
	ResourceSaver.save(popup.current_path + ".tscn", toSave)
	

func load_level():
	var toLoad : PackedScene = PackedScene.new()
	toLoad = ResourceLoader.load(popup.current_path)
	var this_level = toLoad.instance()
	get_parent().remove_child(level)
	level.queue_free()
	
	get_parent().add_child(this_level)
	# Add player to scene
	var player = player_obj.instance()
	this_level.add_child(player)
	# TODO Hide editor panel
	# Use player camera
	player.get_node("Camera2D").current = true
	# Update attributes
	tile_map = get_parent().get_node("Level/TileMap")
	level = this_level
	

func _on_FileDialog_confirmed():
	if popup.window_title == "Save a File":
		save_level()
	else:
		load_level()
	pass


func _on_FileDialog_hide():
	Global.filesystem_shown = false
	do_save = false
	pass 
