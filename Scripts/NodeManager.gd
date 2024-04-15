extends Node
# class that manage nodes

var player = preload("res://Objects/Player.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_saved_levels()
	
func play(node_id):
	var scene_path = "res://Scenes/SavedLevels/" + str(node_id) + ".tscn"
	get_tree().change_scene(scene_path)
	get_tree().root.add_child(player)
	#TODO
	
# open a scene 
func open_scene_in_editor(node_id):
	# Construct the path to the .tscn file
	get_tree().change_scene("res://Scenes/LevelEditor/LevelEditor.tscn")
	var scene_path = "res://Scenes/SavedLevels/" + str(node_id) + ".tscn"
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
	var scene_path = "res://Scenes/SavedLevels/" + str(node_id) + ".tscn"
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

func create_level(node_id):
	pass

func clear_saved_levels():
	var dir = Directory.new()
	var folder_path = "res://Scenes/SavedLevels"
	var err = dir.open(folder_path)
	
	if err != OK:
		print("Failed to open directory:", folder_path)
		return
	
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = folder_path + "/" + file_name
		var result = File.new()
		result.remove(file_path)
		file_name = dir.get_next()

	dir.list_dir_end()
