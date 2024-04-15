extends Control

var nodes = []

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
		
	var err = Client.query_nodes(inLine.text)
	if err != "":
		print("error: ", err)
		return
	
	var ret = yield(Client, "query_nodes_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
	
	nodes = ret.get("nodes", [])
	set_levels_table(nodes)

func set_levels_table(nodes: Array):
	var table = $ScrollContainer/VBoxContainer/MarginContainer3/Background/ScrollContainer/Table

	for child in table.get_children():
		child.queue_free()
		
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var title_row = HBoxContainer.new()
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	new_label("Title", title_row, Color(0, 1, 0), "title")
	new_label("User", title_row, Color(0, 1, 0), "user")
	new_label("Description", title_row, Color(0, 1, 0), "description")
	new_label("Playcount", title_row, Color(0, 1, 0), "playcount")
	new_label("Rating", title_row, Color(0, 1, 0), "rating")
	new_label("Is initial?", title_row, Color(0, 1, 0), "is_initial")
	new_label("Is final?", title_row, Color(0, 1, 0), "is_final")
	new_label(" ", title_row, Color(0, 1, 0), "play")
	new_label(" ", title_row, Color(0,1,0), "see more")
	
	table.add_child(title_row)
	
	var row_num = 1
	for node in nodes:
		var line = ColorRect.new()
		line.color = Color(1,1,1)
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.rect_min_size = Vector2(0, 2)
		
		table.add_child(line)
		
		var row_container = HBoxContainer.new()
		row_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_container.connect("mouse_entered", self, "_on_rowContainer_mouse_entered", [row_container])
		row_container.connect("mouse_exited", self, "_on_rowContainer_mouse_exited", [row_container])
		
		new_label(node.title, row_container, Color(1, 1, 1), "title")
		new_label(node.user_id, row_container, Color(1, 1, 1), "user")
		new_label(node.description, row_container, Color(1, 1, 1), "description")
		new_label(String(node.playcount), row_container, Color(1, 1, 1), "playcount")
		new_label(String(node.rating), row_container, Color(1, 1, 1), "rating")
		
		if node.is_initial:
			new_label("Yes", row_container, Color(1, 1, 1), "is_initial")
		else:
			new_label("No", row_container, Color(1, 1, 1), "is_initial")
			
		if node.is_final:
			new_label("Yes", row_container, Color(1, 1, 1), "is_final")
		else:
			new_label("No", row_container, Color(1, 1, 1), "is_final")
		
		var playButton = make_button("Play", "_on_playNodeButton_pressed", [row_num - 1])
		row_container.add_child(playButton)
		
		var seeMoreButton = make_button("See More", "_on_seeMoreButton_pressed", [row_num - 1])
		row_container.add_child(seeMoreButton)
		
		table.add_child(row_container)
		row_num += 1

func _on_playNodeButton_pressed(idx):
	var node_id: String = nodes[idx].id
	var error: String = Client.get_level(node_id)
	if error != "":
		print("Error in getting level " + node_id)
		return
	var ret = yield(Client, "get_level_completed")
	if ret.get("message", "error") != "level":
		print("Error in getting level " + node_id)
		return
	NodeManager.play(node_id)
	
func _on_seeMoreButton_pressed(idx):
	print(nodes[idx])

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
	b.connect("pressed", self, function, arr)
	
	var sb = load("res://Assets/GuiComponents/buttonStyle.tres")
	b.add_stylebox_override("normal", sb)
	
	var dynfont = DynamicFont.new()
	dynfont.font_data = load("res://Assets/Fonts/Audiowide-en4g.ttf")
	dynfont.size = 25
	
	b.add_font_override("font", dynfont)
	b.add_color_override("font_color", Color(0,0,0))

	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	return b

