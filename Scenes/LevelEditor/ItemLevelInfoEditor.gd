extends Node2D


onready var saveBtn: Button = $SaveButton
onready var discardBtn: Button = $DiscardButton

onready var titleTextEdit		: TextEdit = $TextEditBgTitle/TextEditTitle
onready var descriptionTextEdit	: TextEdit= $TextEditBgDescription/TextEditDescription
onready var title		: String = titleTextEdit.text
onready var description	: String = descriptionTextEdit.text

# Called when the node enters the scene tree for the first time.
func _ready():
	saveBtn.connect("pressed", self, "_on_saveBtn_pressed")
	discardBtn.connect("pressed", self, "_on_discardBtn_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_saveBtn_pressed():
	print("Save button in Level Info Editor pressed")
	var is_initial	: bool = false
	var is_final		: bool = true
	var level		: Node2D = get_node("/root/LevelEditor/Level")
	# Pack scene and save
	var save_path	: String = "xxx.tscn"
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
	self.hide()


func _on_discardBtn_pressed():
	print("Discard button in Level Info Editor pressed")
	titleTextEdit.text = ""
	descriptionTextEdit.text = ""
	title = ""
	description = ""
	self.hide()
	
