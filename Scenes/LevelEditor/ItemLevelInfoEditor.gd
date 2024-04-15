extends Node2D


onready var saveBtn: Button = $SaveButton
onready var discardBtn: Button = $DiscardButton

onready var titleInput: LineEdit       = $Title/TitleEdit/LineText
onready var descriptionInput: TextEdit = $Description/DescriptionEdit/LineText
onready var initialToggle: Button      = $IsInitial/InitialToggle
onready var finalToggle: Button        = $IsFinal/FinalToggle

# Called when the node enters the scene tree for the first time.
func _ready():
	saveBtn.connect("pressed", self, "_on_saveBtn_pressed")
	discardBtn.connect("pressed", self, "_on_discardBtn_pressed")
	initialToggle.connect("toggled", self, "_on_initialBtn_toggled")
	finalToggle.connect("toggled", self, "_on_finalBtn_toggled")

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_saveBtn_pressed():
	var title = titleInput.text
	if title == "":
		return "no title"
		
	var description = descriptionInput.text
	
	Global.save_editor_shown = false
	print("Save button in Level Info Editor pressed")
	var level		: Node2D = get_node("/root/LevelEditor/Level")
	NodeManager.create_level(level, title, description, initialToggle.pressed, finalToggle.pressed)
	self.hide()

func _on_discardBtn_pressed():
	Global.save_editor_shown = false
	print("Discard button in Level Info Editor pressed")
	titleInput.text = ""
	descriptionInput.text = ""
	self.hide()

func _on_initialBtn_toggled(toggled_on: bool):
	_update_hover_style(initialToggle, toggled_on)
	
func _on_finalBtn_toggled(toggled_on: bool):
	_update_hover_style(finalToggle, toggled_on)

func _update_hover_style(btn: Button, toggled_on: bool):
	var hoverStyle = btn.get_stylebox("pressed") if toggled_on else btn.get_stylebox("normal")
	btn.add_stylebox_override("hover", hoverStyle)
