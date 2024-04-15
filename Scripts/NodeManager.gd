extends Node
# class that manage nodes

var player = preload("res://Objects/Player.tscn")
var currPlayer: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_clear_saved_levels()
	
func play(node_id):
	var scene_path = "res://SavedLevels/" + str(node_id) + ".tscn"
	get_tree().change_scene(scene_path)
	_add_player_unique()
	
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
	
		
func edit_level(node_id):
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


func create_level(title: String, description: String, level: Node2D):
	var is_initial	: bool = false
	var is_final		: bool = true
	# Pack scene and save
	var save_path	: String = "res://SavedLevels/temp.tscn"
	var toSave 		: PackedScene = PackedScene.new()
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
