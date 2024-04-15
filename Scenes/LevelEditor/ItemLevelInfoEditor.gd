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
	var level		: Node2D = get_node("/root/LevelEditor/Level")
	NodeManager.create_level(title, description, level)
	self.hide()

func _on_discardBtn_pressed():
	Global.save_editor_shown = false
	print("Discard button in Level Info Editor pressed")
	titleTextEdit.text = ""
	descriptionTextEdit.text = ""
	title = ""
	description = ""
	self.hide()
	
