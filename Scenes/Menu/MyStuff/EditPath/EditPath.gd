extends Control

var path = {}

func _ready():
	path = MenuVariables.MenuVariables.get("selected_path", {})
	MenuVariables.clear()
	
	if path == {}:
		get_tree().change_scene("res://Scenes/Menu/MyStuff/Manage.tscn")

	set_go_back_button()
	set_title_label()
	set_description_label()
	make_nodes()
	
func set_go_back_button():
	var goBackButton = $ScrollContainer/VBoxContainer/GoBackRowMargin/GoBackColumn/GoBackButton
	goBackButton.connect("pressed", self, "_on_goBackButton_pressed")

func _on_goBackButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/MyStuff/Manage.tscn")
	
func set_title_label():
	var titleEditLine = $ScrollContainer/VBoxContainer/PathInfoMargin/PathInfoContainer/TitleContainer/TitleEditContainer/TitleEditLine
	titleEditLine.text = path.title
	titleEditLine.connect("text_entered", self, "_on_path_title_changed", [titleEditLine])
	
	var titleEditButton = $ScrollContainer/VBoxContainer/PathInfoMargin/PathInfoContainer/TitleContainer/TitleEditContainer/TitleEditButton
	titleEditButton.connect("pressed", self, "_on_path_title_changed", ["", titleEditLine])
		
	var descriptionEditBox = $ScrollContainer/VBoxContainer/PathInfoMargin/PathInfoContainer/DescriptionContainer/DescriptionEditBox
	descriptionEditBox.text = path.description

func _on_path_title_changed(text, titleEditLine):
	var err = Client.update_path_title(path.path_id, titleEditLine.text)

	if err != "":
		print("error: ", err)
		return
	
	var ret = yield(Client, "update_path_title_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return
		
	
func set_description_label():
	var descriptionEditBox = $ScrollContainer/VBoxContainer/PathInfoMargin/PathInfoContainer/DescriptionContainer/DescriptionEditBox
	descriptionEditBox.text = path.description
	
	var descriptionEditButton = $ScrollContainer/VBoxContainer/PathInfoMargin/PathInfoContainer/DescriptionContainer/DescriptionEditButton
	descriptionEditButton.connect("pressed", self, "_on_path_description_changed", [descriptionEditBox])
	
func _on_path_description_changed(descriptionEditBox):
	var err = Client.update_path_description(path.path_id, descriptionEditBox.text)

	if err != "":
		print("error: ", err)
		return
	
	var ret = yield(Client, "update_path_description_completed")
	if ret.get("code", "not found") != "200":
		print("server error: ", ret)
		return

func new_label(prop: String, row_container, color, prop_name: String):
	var lbl = Label.new()
	lbl.name = prop_name + "Label"
	lbl.text = prop
	
	lbl.autowrap = true
	
	var dynfont = DynamicFont.new()
	dynfont.font_data = load("res://Assets/Fonts/Audiowide-en4g.ttf")
	dynfont.size = 25
	
	lbl.add_font_override("font", dynfont)
	lbl.modulate = color
	
	row_container.add_child(lbl)

class NodeSorter:
	static func sort_descending(a,b):
		return a["position"] > b["position"]

func make_nodes():
	var nodes = path["node_sequence"]
	var max_row = nodes[nodes.size() - 1]["position"]
	
	var nodeContainer = $ScrollContainer/VBoxContainer/PathInfoMargin/PathInfoContainer/NodeContainer
	nodeContainer.add_constant_override("separation", 30)
	for i in range(max_row + 2):
		var row = new_row(String(i))
		if i != max_row + 1:
			new_label(String(i), row, Color(1, 1, 1), "rownum")
		nodeContainer.add_child(row)
	
	for node in nodes:
		var nodeBox = new_node_box(node["node"])
		nodeContainer.get_child(node["position"]).add_child(nodeBox)
		
		print(node)
		print(node["position"])
		
	for i in range(1, max_row + 2):
		var b = make_button("Add", "_on_addButton_pressed", i)
		nodeContainer.get_child(i).add_child(b)
		
func _on_addButton_pressed(index: int):
	print(index)

func make_button(text, function, idx):
	var b = Button.new()
	b.text = text
	b.connect("pressed", self, function, [idx])
	
	var sb = load("res://Assets/GuiComponents/buttonStyle.tres")
	b.add_stylebox_override("normal", sb)
	
	var dynfont = DynamicFont.new()
	dynfont.font_data = load("res://Assets/Fonts/Audiowide-en4g.ttf")
	dynfont.size = 25
	
	b.add_font_override("font", dynfont)
	b.add_color_override("font_color", Color(0,0,0))

	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	b.rect_min_size = Vector2(100, 30)
	
	return b

func new_node_box(node):
	var nodeBox = Control.new()
	nodeBox.rect_min_size = Vector2(200, 100)
	
	var colorRect = ColorRect.new()
	colorRect.color = Color(0.5, 1, 0.5)
	colorRect.rect_min_size = Vector2(200, 100)
	nodeBox.add_child(colorRect)
	
	var lbl = Label.new()
	lbl.text = node["title"]
	
	print(node["title"])
	
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lbl.valign = Label.VALIGN_CENTER
	lbl.align = Label.ALIGN_CENTER
	
	var dynfont = DynamicFont.new()
	dynfont.font_data = load("res://Assets/Fonts/Audiowide-en4g.ttf")
	dynfont.size = 25
	
	lbl.add_font_override("font", dynfont)
	lbl.modulate = Color(0, 0, 0)
	
	colorRect.add_child(lbl)
	
	return nodeBox
	
func new_row(i: String):
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGN_CENTER
	row.name = "row_" + i

	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.rect_min_size = Vector2(500, 120)
	
	row.add_constant_override("separation", 40)
	
	return row
