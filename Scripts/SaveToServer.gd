extends Button

onready var level = get_node("/root/LevelEditor/Level")
# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the button's 'pressed' signal to the 'on_button_pressed' method.
	connect("pressed", self, "on_button_pressed")
	
func on_button_pressed():
	# Assuming 'level' is a variable pointing to the node you want to pack
	save_packed_scene(level)
	serialize_scene("res://saved_scene.tscn", "res://output_file.dat")

func save_packed_scene(level_node):
	var toSave : PackedScene = PackedScene.new()
	if toSave.pack(level_node) == OK:
		var scene_path = "res://saved_scene.tscn" # Or any other path you want
		ResourceSaver.save(scene_path, toSave)
		print("Packed scene saved successfully to", scene_path)
	else:
		print("Failed to pack the scene.")

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
