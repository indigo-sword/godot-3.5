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
	Global.save_editor_shown = false
	print("Save button in Level Info Editor pressed")
	var is_initial	: bool = false
	var is_final		: bool = true
	var level		: Node2D = get_node("/root/LevelEditor/Level")
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
	print(ret)
		
	self.hide()
	


func _on_discardBtn_pressed():
	Global.save_editor_shown = false
	print("Discard button in Level Info Editor pressed")
	titleTextEdit.text = ""
	descriptionTextEdit.text = ""
	title = ""
	description = ""
	self.hide()
	
