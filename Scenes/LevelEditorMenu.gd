extends Node2D

const LEVEL_DIR: String = "res://SavedLevels/"
onready var tab_container: TabContainer = get_node("/root/LevelEditor/ItemSelect")

onready var visBtn: Button = $VisibilityButton
onready var saveBtn: Button = $SaveButton
onready var loadBtn: Button = $LoadButton
onready var exitBtn: Button = $ExitButton


# Called when the node enters the scene tree for the first time.
func _ready():
	visBtn.connect("pressed", self, "_on_visBtn_pressed")
	saveBtn.connect("pressed", self, "_on_saveBtn_pressed")
	loadBtn.connect("pressed", self, "_on_loadBtn_pressed")
	exitBtn.connect("pressed", self, "_on_exitBtn_pressed")

func _on_visBtn_pressed():
	print("Visibility button pressed")
	if (!Global.filesystem_shown):
			Global.playing = !Global.playing
			tab_container.visible = !Global.playing
	# Your existing or new logic here...

func _on_saveBtn_pressed():
	print("Save button pressed")
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
		ret = yield(Client, "login_completed")
		print(ret.get("code", "not found"))
		# TODO add visual error handling
		if (err != "" or ret.get("code", "not found") != "200"):
			print("Error in logging in.")
		
	err = Client.create_node(title, description, is_initial, is_final, save_path)
	# TODO add visual error handling
	if (err != ""):
		print("Error in saving the level.")

func _on_loadBtn_pressed():
	print("Load button pressed")
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
		ret = yield(Client, "login_completed")
		print(ret.get("code", "not found"))
		# TODO add visual error handling
		if (err != "" or ret.get("code", "not found") != "200"):
			print("Error in logging in.")
		
	err = Client.create_node(title, description, is_initial, is_final, save_path)
	# TODO add visual error handling
	if (err != ""):
		print("Error in saving the level.")

func _on_exitBtn_pressed():
	print("Exit button pressed")
	# Your existing or new logic here...
