extends Control

onready var loginFailedLabel = $LoginRect/LoginFailedLabel

func _ready():
	loginFailedLabel.visible = false
	
	var loginButton = $LoginRect/LoginForm/Login
	loginButton.connect("pressed", self, "_on_login_button_pressed")
	
	var createUserButton = $CreateUserRect/CreateUserForm/CreateUser
	createUserButton.connect("pressed", self, "_on_createUser_button_pressed")
	
func _on_createUser_button_pressed(): 
	var uname = $CreateUserRect/CreateUserForm/Username/LineText
	var password = $CreateUserRect/CreateUserForm/Password/LineText
	var email = $CreateUserRect/CreateUserForm/Email/LineText
	
	var err = Client.create_user(uname.text, password.text, email.text)
	if err != "": 
		print("error: ", err)
		return
		
	var ret = yield(Client, "create_user_completed")
	if ret.get("code", "not found") != "201":
		print("server error: ", ret)
		return
	
	uname.text = ""
	uname.editable = false
	
	password.text = ""
	password.editable = false
	
	email.text = ""
	email.editable = false
	
	var createUser = $CreateUserRect/CreateUserTitle
	createUser.text = "User Created"
	
func _on_login_button_pressed():
	var uname = $LoginRect/LoginForm/Username/LineText
	var password = $LoginRect/LoginForm/Password/LineText
	
	var err = Client.login(uname.text, password.text)
	if err: 
		print("error: ", err)
		return
	
	var ret = yield(Client, "login_completed")
	if ret.get("code", "not found") != "200":
		loginFailedLabel.visible = true
		print("server error: ", ret)
		return
	
	err = Configs.open_configs(uname.text)
	if err:
		print("configs error: ", err)
		return
	
	uname.text = ""
	uname.editable = false
	
	password.text = ""
	password.editable = false

	get_tree().change_scene("res://Scenes/Menu/PlayerMain/PlayerMain.tscn")
