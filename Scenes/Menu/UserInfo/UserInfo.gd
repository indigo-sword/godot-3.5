extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var usernameLabel = $UsernameLabel
	usernameLabel.text = Client.UNAME
	
	var emailLabel = $EmailLabel
	emailLabel.text = Client.EMAIL
	
	var bioText = $TextEditBg/TextEdit
	bioText.text = Client.BIO
	
	var saveButton = $SaveButton
	saveButton.connect("pressed", self, "_on_saveButton_pressed")
	
	var backButton= $BackButton
	backButton.connect("pressed", self, "_on_backArrow_pressed")
	
func _on_backArrow_pressed():
	get_tree().change_scene("res://Scenes/Menu/PlayerMain/PlayerMain.tscn")

func _on_saveButton_pressed():
	var bioText = $TextEditBg/TextEdit.text
	
	var err = Client.change_bio(bioText)
	if err: 
		print("client error: ", err)
		return
		
	var ret = yield(Client, "change_bio_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
		
	var bioLabel = $EditBio
	bioLabel.text = "Bio Updated."
	
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	$Timer.wait_time = 3
	$Timer.start()
	
func _on_Timer_timeout():
	var bioLabel = $EditBio
	bioLabel.text = "Edit Bio"
