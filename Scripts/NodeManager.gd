extends Node
# class that manage nodes

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func play():
	pass
# open a scene 
func open_scene_in_editor(node_id):
	# Construct the path to the .tscn file
	get_tree().change_scene("res://Scenes/LevelEditor/LevelEditor.tscn")
	var scene_path = str(node_id) + ".tscn"
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
	var scene_path = str(node_id) + ".tscn"
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
