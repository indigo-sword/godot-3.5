extends Button

const LEVEL_DIR: String = "res://SavedLevels/"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the button's 'pressed' signal to the 'on_button_pressed' method.
	connect("pressed", self, "on_button_pressed")

# This method will be called when the button is pressed
func on_button_pressed():
	var title		: String = "My awesome level"
	var description	: String = "Welcome to my awesome level"
	var is_initial	: bool = false
	var is_final		: bool = true
	var level		: Node2D = get_node("/root/LevelEditor/Level")
	# Pack scene and save
	var save_path	: String = LEVEL_DIR + title + ".tscn"
	var toSave 		: PackedScene = PackedScene.new()
	toSave.pack(level)
	ResourceSaver.save(save_path, toSave)
	# Request to save to server
	var err = "";
	var ret = "";
	# FIXME remove after adding main menu for user to log in
	if (!Client.LOGGED_IN):
		err = Client.login("LsZCFWRNMl", "PASS")
		# TODO add visual error handling
		assert(err == "")
		# ret = yield(Client, "login_completed")
		# print(ret.get("code", "not found"))
	# err = Client.create_node(title, description, is_initial, is_final, save_path)
	# TODO add visual error handling
	# print(err)
