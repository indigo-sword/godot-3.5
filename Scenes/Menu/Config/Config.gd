extends Control


func _ready():
	var goBackButton = $ScrollContainer/VBoxContainer/MarginContainer/HBoxContainer2/GoBackButton
	goBackButton.connect("pressed", self, "_on_goBackButton_pressed")

func _on_goBackButton_pressed():
	get_tree().change_scene("res://Scenes/Menu/PlayerMain/PlayerMain.tscn")
	
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

