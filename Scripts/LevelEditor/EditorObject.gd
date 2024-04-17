extends Node2D

var can_place = true
var is_planning = true
export var cam_spd = 10
var do_save = false

onready var level = get_node("/root/LevelEditor/Level")
onready var editor = get_node("/root/LevelEditor/CamContainer")
onready var leveleditormenu = get_node("/root/LevelEditor/LevelEditorMenu")
onready var editor_cam = editor.get_node("Camera2D")

# Tilemaps
onready var grid: TileMap = level.get_node("Grid")
onready var ground_tm: TileMap = level.get_node("Ground")
onready var buildings_tm: TileMap = level.get_node("Buildings")
onready var decors_tm: TileMap = level.get_node("Decors")

# Item menu containers
onready var ground_container: ScrollContainer = get_node("/root/LevelEditor/ItemSelect/TabContainer/Tiles/ScrollContainer")
onready var buildings_container: ScrollContainer = get_node("/root/LevelEditor/ItemSelect/TabContainer/Buildings/ScrollContainer")
onready var decors_container: ScrollContainer = get_node("/root/LevelEditor/ItemSelect/TabContainer/Items/ScrollContainer")
onready var item_texture_rect_script: Resource = preload("res://Scripts/LevelEditor/ItemTexture.gd")

onready var popup : FileDialog = get_node("/root/LevelEditor/ItemSelect/FileDialog")
onready var save_popup = get_node("/root/LevelEditor/LevelInfoCanvas/LevelInfoEditor")

onready var player_obj = preload("res://Objects/Player.tscn")

# Emits when all tiles in all tile maps 
signal all_tiles_added_to_tree

# Called when the node enters the scene tree for the first time.
func _ready():
	editor_cam.current = true
	# Initialize tile nodes
	_init_tiles_tree_from_tm(ground_tm, ground_container, Global.LevelEditorItemType.GROUND)
	_init_tiles_tree_from_tm(buildings_tm, buildings_container, Global.LevelEditorItemType.BULDING)
	_init_tiles_tree_from_tm(decors_tm, decors_container, Global.LevelEditorItemType.DECOR)
	# Evoke container function to scale textures
	self.connect("all_tiles_added_to_tree", ground_container, "scale_textures")
	self.connect("all_tiles_added_to_tree", buildings_container, "scale_textures")
	self.connect("all_tiles_added_to_tree", decors_container, "scale_textures")
	emit_signal("all_tiles_added_to_tree")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()
	if (!Global.save_editor_shown):
		if (can_place):
			if Input.is_action_pressed("mb_left") and $Sprite.texture != null:
				place_tile()
			if Input.is_action_pressed("mb_right") and $Sprite.texture == null:
				remove_tile()
	
	move_editor()
	
	if Input.is_action_pressed("save"):
		Global.save_editor_shown = true
		do_save = true
		popup.mode = 4
		popup.show()
	if Input.is_action_pressed("load"):
		Global.save_editor_shown = true
		do_save = true
		popup.mode = 0
		popup.show()
		
	is_planning = Input.is_action_pressed("mb_middle")
	
	if $Sprite.texture != null:
		var sprite_pos = grid.world_to_map(get_global_mouse_position() / grid.scale)
		sprite_pos = sprite_pos * grid.cell_size * grid.scale
		$Sprite.global_position = sprite_pos

func place_tile():
	var tm = _get_current_tm()
	if (tm):
		var mousepos = tm.world_to_map(get_global_mouse_position() / tm.scale)
		tm.set_cell(mousepos.x, mousepos.y, Global.current_tile)
		# Allow zooping for ground tiles
		if Global.current_tile_type != Global.LevelEditorItemType.GROUND:
			$Sprite.texture = null
	
func remove_tile():
	var tm = _get_current_tm()
	if (tm):
		var mousepos = tm.world_to_map(get_global_mouse_position() / tm.scale)
		tm.set_cell(mousepos.x, mousepos.y, -1)
	
func move_editor():
	# FIXME: fix moving editor (currently compromising player movement)
	if (!Global.save_editor_shown):
		if Input.is_action_pressed("w"):
			editor.global_position.y -= cam_spd
		if Input.is_action_pressed("a"):
			editor.global_position.x -= cam_spd
		if Input.is_action_pressed("s"):
			editor.global_position.y += cam_spd
		if Input.is_action_pressed("d"):
			editor.global_position.x += cam_spd
	
func _unhandled_input(event):
	if (!Global.save_editor_shown):
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
	ground_tm.owner = level
	buildings_tm.owner = level
	decors_tm.owner = level
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
	ground_tm = get_parent().get_node("Level/Ground")
	buildings_tm = get_parent().get_node("Level/Buildings")
	decors_tm = get_parent().get_node("Level/Decors")
	level = this_level
	

func _on_FileDialog_confirmed():
	if popup.window_title == "Save a File":
		save_level()
	else:
		load_level()
	pass


func _on_FileDialog_hide():
	Global.save_editor_shown = false
	do_save = false
	pass 

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

func _init_tiles_tree_from_tm(tm: TileMap, c: ScrollContainer, type: int):
	var all_tile_ids = tm.tile_set.get_tiles_ids()
	for tile_id in all_tile_ids:
		var tile_texture = tm.tile_set.tile_get_texture(tile_id)
		var tile_subregion: Rect2 = tm.tile_set.tile_get_region(tile_id)
		var tile_texture_rect: TextureRect = TextureRect.new()
		tile_texture_rect.texture = AtlasTexture.new()
		tile_texture_rect.texture.atlas = tile_texture
		tile_texture_rect.texture.region = tile_subregion
		tile_texture_rect.set_script(item_texture_rect_script)
		tile_texture_rect.tile_id = tile_id
		tile_texture_rect.tile_type = type
		# All other attributes will be handled by the corresponding container
		c.get_node("VBoxContainer").add_child(tile_texture_rect)
