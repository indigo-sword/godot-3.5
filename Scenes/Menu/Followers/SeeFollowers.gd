extends Control


var followers = []
var following = []

func _ready():
	var goBackButton = $ScrollContainer/VBoxContainer/MarginContainer6/HBoxContainer2/GoBackButton
	goBackButton.connect("pressed", self, "_on_goBackButton_pressed")
	
	goBackButton = $ScrollContainer/VBoxContainer/MarginContainer/HBoxContainer2/GoBackButton
	goBackButton.connect("pressed", self, "_on_goBackButton_pressed")
	
	var err = Client.get_follows(Client.UNAME)
	if err != "":
		print("error: ", err)
		return
	
	var ret = yield(Client, "get_follows_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
	
	followers = ret.get("followed", [])
	following = ret.get("following", [])
	
	set_followers_table(followers)
	set_following_table(following)

func _on_goBackButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/PlayerMain/PlayerMain.tscn")

func set_following_table(following):
	var table = $ScrollContainer/VBoxContainer/MarginContainer4/Background/ScrollContainer/Table
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var title_row = HBoxContainer.new()
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	new_label("Row", title_row, Color(0, 1, 0), "row")
	new_label("User", title_row, Color(0, 1, 0), "user")
	new_label(" ", title_row, Color(0, 1, 0), "user") # see more
	new_label(" ", title_row, Color(0, 1, 0), "user") # unfollow
	
	table.add_child(title_row)
	
	var row_num = 1
	
	for followed in following:
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
		new_label(followed, row_container, Color(1, 1, 1), "follower")
		
		var seeMoreButton = make_button("See more", "_on_seeMoreButtonFollowing_pressed", [row_num - 1])
		row_container.add_child(seeMoreButton)
		
		var unfollowButton = make_button("Unfollow", "_on_unfollowButtonFollowing_pressed", [row_num - 1, row_container, line])
		row_container.add_child(unfollowButton)
		
		table.add_child(row_container)
		row_num += 1

func _on_seeMoreButtonFollowing_pressed(idx):
	print(following[idx])
	
func _on_unfollowButtonFollowing_pressed(idx, row_container, line):
	var err = Client.unfollow_user(following[idx])
	if err != "":
		print("error: ", err)
		return
	
	var ret = yield(Client, "unfollow_user_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
	
	print(ret)
	
	line.queue_free()
	row_container.queue_free()
	
func make_button(text, function, arr):
	var b = Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.connect("pressed", self, function, arr)
	
	var sb = load("res://Assets/GuiComponents/buttonStyle.tres")
	b.add_stylebox_override("normal", sb)
	
	var dynfont = DynamicFont.new()
	dynfont.font_data = load("res://Assets/Fonts/menufont.ttf")
	dynfont.size = 25
	
	b.add_font_override("font", dynfont)
	b.add_color_override("font_color", Color(0,0,0))

	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	return b

func set_followers_table(followers):
	var table = $ScrollContainer/VBoxContainer/MarginContainer3/Background/ScrollContainer/Table
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var title_row = HBoxContainer.new()
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	new_label("Row", title_row, Color(0, 1, 0), "row")
	new_label("User", title_row, Color(0, 1, 0), "user")
	
	table.add_child(title_row)
	
	var row_num = 1
	
	for follower in followers:
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
		new_label(follower, row_container, Color(1, 1, 1), "follower")
		
		table.add_child(row_container)
		row_num += 1
		
		
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
	dynfont.font_data = load("res://Assets/Fonts/menufont.ttf")
	dynfont.size = 25
	
	lbl.add_font_override("font", dynfont)
	lbl.modulate = color
	
	row_container.add_child(lbl)
