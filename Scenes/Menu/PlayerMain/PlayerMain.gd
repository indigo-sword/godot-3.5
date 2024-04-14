extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var configButton = $ConfigButton
	var userInfoButton = $UserInfoButton
	var logoutButton = $LogoutButton
	
	configButton.connect("pressed", self, "_on_configButton_pressed")
	userInfoButton.connect("pressed", self, "_on_userInfoButton_pressed")
	logoutButton.connect("pressed", self, "_on_logoutButton_pressed")
	
	# Discover
	var popularLevelsButton = $Levels/PopularLevelsButton
	var findLevelsButton = $Levels/FindLevelsButton
	var popularPathsButton = $Levels/PopularPathsButton
	var findPathsButton = $Levels/FindPathsButton
	
	popularLevelsButton.connect("pressed", self, "_on_popularLevelsButton_pressed")
	findLevelsButton.connect("pressed", self, "_on_findLevelsButton_pressed")
	popularPathsButton.connect("pressed", self, "_on_popularPathsButton_pressed")
	findPathsButton.connect("pressed", self, "_on_findPathsButton_pressed")

	# your stuff
	var createLevelButton = $YourStuff/CreateButton
	var manageButton = $YourStuff/ManageButton
	
	createLevelButton.connect("pressed", self, "_on_createLevelButton_pressed")
	manageButton.connect("pressed", self, "_on_manageButton_pressed")
	
	# followers
	var findUserButton = $Followers/FindUserButton
	var seeFollowersButton = $Followers/SeeFollowersButton

	findUserButton.connect("pressed", self, "_on_findUserButton_pressed")
	seeFollowersButton.connect("pressed", self, "_on_seeFollowersButton_pressed")

# Followers
func _on_findUserButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/Followers/FindUser.tscn")

func _on_seeFollowersButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/Followers/SeeFollowers.tscn")

# Your stuff
func _on_createLevelButton_pressed():
	get_tree().change_scene("res://Scenes/LevelEditor.tscn")

func _on_manageButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/MyStuff/Manage.tscn")

# Discover
func _on_findPathsButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/Discover/FindPaths.tscn")

func _on_popularPathsButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/Discover/PopularPaths.tscn")

func _on_findLevelsButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/Discover/FindLevels.tscn")

func _on_popularLevelsButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/Discover/PopularLevels.tscn")

# Rest
func _on_configButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/Config/Config.tscn")
	
func _on_userInfoButton_pressed():
	if not Client.LOGGED_IN: 
		print("error: not logged in")
		return
		
	get_tree().change_scene("res://Scenes/Menu/UserInfo/UserInfo.tscn")
	
func _on_logoutButton_pressed(): 
	var err = Client.logout()
	if err != "": 
		print("error: ", err)
		return
		
	var ret = yield(Client, "logout_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
		
	Configs.clear()
	get_tree().change_scene("res://Scenes/Menu/Main/Init.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
