extends Node
# class that manage nodes

var player = preload("res://Objects/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_saved_levels()
	
func play(node_id):
	var scene_path = "res://SavedLevels/" + str(node_id) + ".tscn"
	get_tree().change_scene(scene_path)
	get_tree().root.add_child(player.instance())
	#TODO
	
func play_test():
	get_tree().root.add_child(player.instance())
	
	
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
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return

func clear_saved_levels():
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
