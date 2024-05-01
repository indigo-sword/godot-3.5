extends Node
# class that manage nodes

var player = preload("res://Objects/Player.tscn")

var currPlayer: Node2D = null

signal load_level_failed(msg)

# Called when the node enters the scene tree for the first time.
func _ready():
	ensureDirectoryExists("res://SavedLevels/")
	_clear_saved_levels()
	
func play(node_id):
	var scene_path = "res://SavedLevels/" + str(node_id) + ".tscn"
	if ResourceLoader.exists(scene_path):
		var err = get_tree().change_scene(scene_path)
		if err == OK:
			_add_player_unique()
		else:
			emit_signal("load_level_failed", "Error in loading saved level " + scene_path)
	else:
		emit_signal("load_level_failed","Scene file not found: " + scene_path)
	
func play_test():
	_add_player_unique()

func end_play_test():
	_del_player()
	
# open a scene 
func open_scene_in_editor(node_id):
	# Construct the path to the .tscn file
	get_tree().change_scene("res://Scenes/LevelEditor/LevelEditor.tscn")
	var scene_path = "res://SavedLevels/" + str(node_id) + ".tscn"
	# Check if the scene file exists
	if ResourceLoader.exists(scene_path):
		# Load the scene
		var scene = load(scene_path)
		# Ensure it's a valid PackedScene resource
		if scene is PackedScene:
			get_tree().root.add_child(scene.instance())
		else:
			print("The specified file is not a valid scene.")
	else:
		print("Scene file not found: " + scene_path)
	
func _save_level():
	var toSave : PackedScene = PackedScene.new()
	var level = get_node("/root/LevelEditor/Level")
	var ground_tm: TileMap = level.get_node("Ground")
	var buildings_tm: TileMap = level.get_node("Buildings")
	var decors_tm: TileMap = level.get_node("Decors")
	ground_tm.owner = level
	buildings_tm.owner = level
	decors_tm.owner = level
	toSave.pack(level)
	return toSave
	
func _load_level(scene_path: String):
	var toLoad : PackedScene = PackedScene.new()
	toLoad = ResourceLoader.load(scene_path)
	var this_level = toLoad.instance()
	var level = get_node("/root/LevelEditor/Level")
	get_parent().remove_child(level)
	get_parent().add_child(this_level)
	
func edit_level(node_id):
	# Construct the path to the .tscn file
	get_tree().change_scene("res://Scenes/LevelEditor/LevelEditor.tscn")
	var scene_path = "res://SavedLevels/" + str(node_id) + ".tscn"
	# Check if the scene file exists
	if ResourceLoader.exists(scene_path):
		# Load the scene
		_load_level(scene_path)
	else:
		print("Scene file not found: " + scene_path)

func create_level(level: Node2D, title: String, description: String, is_initial: bool, is_final: bool):
	# Pack scene and save
	var save_path	: String = "res://SavedLevels/temp.tscn"
	var toSave 		: PackedScene = _save_level()
	toSave.pack(level)
	ResourceSaver.save(save_path, toSave)
	# Request to save to server
	var err = "";
	var ret = "";
	
	err = Client.create_node(title, description, is_initial, is_final, save_path)
	if err != "":
		print("error: ", err)
		return
	
	ret = yield(Client, "create_node_completed")
	if ret.get("code", "not found") != "201":
		print("server error: ", ret)
		return
	
	# rename temp.tscn to [node_id].tscn
	var node_id = ret["node_id"]
	var new_save_path = "res://SavedLevels/" + node_id + ".tscn"
	
	ResourceSaver.save(new_save_path, toSave)
	

func _clear_saved_levels():
	return
	var dir = Directory.new()
	var folder_path = "res://SavedLevels"
	var err = dir.open(folder_path)
	
	if err != OK:
		print("Failed to open directory:", folder_path)
		return
	
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = folder_path + "/" + file_name
		dir.remove(file_path)
		file_name = dir.get_next()

	dir.list_dir_end()

func _add_player_unique():
	if (!currPlayer):
		currPlayer = player.instance()
		var currCam = getCurrentCamera2D()
		if (currCam):
			currPlayer.global_position = getCurrentCamera2D().global_position
		get_tree().root.add_child(currPlayer)

func _del_player():
	if (currPlayer):
		currPlayer.queue_free()
		currPlayer = null

func getCurrentCamera2D():
	var viewport = get_viewport()
	if not viewport:
		return null
	var camerasGroupName = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)
	for camera in cameras:
		if camera is Camera2D and camera.current:
			return camera
	return null

func ensureDirectoryExists(dir_path: String):
	var dir = Directory.new()
	
	# Check if the directory exists
	if not dir.dir_exists(dir_path):
		# Directory doesn't exist, create it
		var result = dir.make_dir(dir_path)
		if result == OK:
			print("Directory created:", dir_path)
		else:
			print("Failed to create directory:", dir_path)
	else:
		print("Directory already exists:", dir_path)
