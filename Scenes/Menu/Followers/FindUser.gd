extends Control

var users = []
var following = []
var followers = []

func _ready():
	var inLine = $ScrollContainer/VBoxContainer/MarginContainer8/HBoxContainer2/LineEdit
	inLine.connect("text_entered", self, "_on_inLine_text_entered")
	
	var searchButton = $ScrollContainer/VBoxContainer/MarginContainer8/HBoxContainer2/SearchButton
	searchButton.connect("pressed", self, "_on_inLine_text_entered", [inLine.text])
	
	var goBackButton = $ScrollContainer/VBoxContainer/MarginContainer/HBoxContainer2/GoBackButton
	goBackButton.connect("pressed", self, "_on_goBackButton_pressed")

func _on_goBackButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/PlayerMain/PlayerMain.tscn")
	
func _on_inLine_text_entered(text):
	var inLine = $ScrollContainer/VBoxContainer/MarginContainer8/HBoxContainer2/LineEdit

	if inLine.text == "": 
		return
		
	var err = Client.query_users(inLine.text)
	if err != "":
		print("error: ", err)
		return
	
	var ret = yield(Client, "query_users_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
	
	users = ret.get("users", [])
	
	err = Client.get_follows(Client.UNAME)
	if err != "":
		print("error: ", err)
		return
	
	ret = yield(Client, "get_follows_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
	
	followers = ret.get("followed", [])
	following = ret.get("following", [])
	
	set_users_table(users, followers, following)

func set_users_table(users: Array, followers: Array, following: Array):
	var table = $ScrollContainer/VBoxContainer/MarginContainer3/Background/ScrollContainer/Table

	for child in table.get_children():
		child.queue_free()
		
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var title_row = HBoxContainer.new()
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	new_label("Row", title_row, Color(0, 1, 0), "row")
	new_label("User", title_row, Color(0, 1, 0), "user")
	new_label(" ", title_row, Color(0, 1, 0), "follows_you")
	new_label(" ", title_row, Color(0, 1, 0), "follow_or_unfollow")
	table.add_child(title_row)
	
	var row_num = 1
	for user in users:
		var line = ColorRect.new()
		line.color = Color(1,1,1)
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.rect_min_size = Vector2(0, 2)
		
		table.add_child(line)
		
		var row_container = HBoxContainer.new()
		row_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_container.connect("mouse_entered", self, "_on_rowContainer_mouse_entered", [row_container])
		row_container.connect("mouse_exited", self, "_on_rowContainer_mouse_exited", [row_container])
		
		new_label(String(row_num), row_container, Color(1, 1, 1), "row")
		new_label(user.username, row_container, Color(1, 1, 1), "user")
		if user.username in followers:
			new_label("Follows you", row_container, Color(1, 1, 1), "follows_you")
		else: 
			new_label(" ", row_container, Color(1, 1, 1), "follows_you")
		
		if user.username in following:
			var unfollowButton = make_button("Unfollow", "_on_unfollowButton_pressed", [row_num - 1])
			row_container.add_child(unfollowButton)
			
		else:
			var followButton = make_button("Follow", "_on_followButton_pressed", [row_num - 1])
			row_container.add_child(followButton)
		
		table.add_child(row_container)
		row_num += 1
		
func _on_followButton_pressed(idx, button):
	var uname = users[idx].username
	var err = Client.follow_user(uname)
	if err != "":
		print("error: ", err)
		return
	
	var ret = yield(Client, "follow_user_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
		
	button.text = "Unfollow"
	button.disconnect("pressed", self, "_on_followButton_pressed")
	button.connect("pressed", self, "_on_unfollowButton_pressed", [idx, self])
	
func _on_unfollowButton_pressed(idx, button):
	var uname = users[idx].username
	var err = Client.unfollow_user(uname)
	if err != "":
		print("error: ", err)
		return
	
	var ret = yield(Client, "unfollow_user_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
		
	button.text = "Follow"
	button.disconnect("pressed", self, "_on_unfollowButton_pressed")
	button.connect("pressed", self, "_on_followButton_pressed", [idx, self])
		
func _on_rowContainer_mouse_entered(row_container):
	row_container.modulate = Color(0, 1, 0)
	
func _on_rowContainer_mouse_exited(row_container):
	row_container.modulate = Color(1, 1, 1)
	
func new_label(prop: String, row_container, color, prop_name: String):
	var lbl = Label.new()
	lbl.name = prop_name + "Label"
	lbl.text = prop
	
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.autowrap = true
	
	var dynfont = DynamicFont.new()
	dynfont.font_data = load("res://Assets/Fonts/Audiowide-en4g.ttf")
	dynfont.size = 25
	
	lbl.add_font_override("font", dynfont)
	lbl.modulate = color
	
	row_container.add_child(lbl)
	
func make_button(text, function, arr):
	var b = Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.connect("pressed", self, function, arr + [b])
	
	var sb = load("res://Assets/GuiComponents/buttonStyle.tres")
	b.add_stylebox_override("normal", sb)
	
	var dynfont = DynamicFont.new()
	dynfont.font_data = load("res://Assets/Fonts/Audiowide-en4g.ttf")
	dynfont.size = 25
	
	b.add_font_override("font", dynfont)
	b.add_color_override("font_color", Color(0,0,0))

	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	return b

