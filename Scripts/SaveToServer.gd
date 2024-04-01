extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the button's 'pressed' signal to the 'on_button_pressed' method.
	connect("pressed", self, "on_button_pressed")

# This method will be called when the button is pressed
func on_button_pressed():
	# Call the 'serialize_scene' method with the path of the scene to serialize and output file path
	serialize_scene("res://path_to_your_scene.tscn", "res://output_file.dat")

# Serializes the current scene with all its dependencies into a single file
func serialize_scene(scene_path: String, output_file: String):
	var scene = ResourceLoader.load(scene_path)
	var deps = ResourceLoader.get_dependencies(scene_path)
	var packed_data = {
		"scene": scene,
		"dependencies": []
	}

	for dep in deps:
		var res = ResourceLoader.load(dep)
		packed_data["dependencies"].append({"path": dep, "resource": res})

	var file = File.new()
	if file.open(output_file, File.WRITE) == OK:
		file.store_var(packed_data)
		file.close()
		print("Scene serialized successfully.")
	else:
		print("Failed to save serialized scene.")
