extends Button

onready var tab_container: TabContainer = get_node("res://Scenes/LevelEditor/ItemSelect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("hello from ready")
	connect("pressed", self, "_on_TextureButton_pressed")


func _on_TextureButton_pressed():
	print("hello from pressed")
	if (!Global.filesystem_shown):
			Global.playing = !Global.playing
			tab_container.visible = !Global.playing

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
