extends CanvasLayer

const LEVEL_DIR: String = "res://SavedLevels/"
onready var tab_container: CanvasLayer = get_node("/root/LevelEditor/ItemSelect")
onready var editor_cam: Camera2D = get_node("/root/LevelEditor/CamContainer/Camera2D")
onready var level_editor: Node2D = get_node("/root/LevelEditor/")
onready var level : Node2D = get_node("/root/LevelEditor/Level")
onready var tile_map : TileMap = level.get_node("Ground")  #FIXME
onready var title_popup: Node2D = get_node("/root/LevelEditor/LevelInfoCanvas/LevelInfoEditor")
onready var object_cursor: Node2D = get_node("/root/LevelEditor/EditorObject")
onready var grid_line: Node2D = get_node("/root/LevelEditor/BackgroundGrid")

onready var visBtn: Button = $VisibilityButton
onready var saveBtn: Button = $SaveButton
onready var loadBtn: Button = $LoadButton
onready var exitBtn: Button = $ExitButton


# Called when the node enters the scene tree for the first time.
func _ready():
	visBtn.connect("pressed", self, "_on_visBtn_pressed")
	saveBtn.connect("pressed", self, "_on_saveBtn_pressed")
	loadBtn.connect("pressed", self, "_on_loadBtn_pressed")
	exitBtn.connect("pressed", self, "_on_exitBtn_pressed")
	visBtn.connect("mouse_entered", self, "_mouse_enter")
	saveBtn.connect("mouse_entered", self, "_mouse_enter")
	loadBtn.connect("mouse_entered", self, "_mouse_enter")
	exitBtn.connect("mouse_entered", self, "_mouse_enter")
	visBtn.connect("mouse_exited", self, "_mouse_leave")
	saveBtn.connect("mouse_exited", self, "_mouse_leave")
	loadBtn.connect("mouse_exited", self, "_mouse_leave")
	exitBtn.connect("mouse_exited", self, "_mouse_leave")
	
	title_popup.hide()


func _on_visBtn_pressed():
	print("Visibility button pressed")
	if (!Global.save_editor_shown):
			Global.playing = !Global.playing
			tab_container.visible = !Global.playing
			grid_line.visible = !Global.playing
			
	if (Global.playing):
		NodeManager.play_test()
		editor_cam.current = false
	else:
		NodeManager.end_play_test()
		editor_cam.current = true

func _on_saveBtn_pressed():
	print("Save button pressed")
	Global.save_editor_shown = true
	title_popup.show()

func _on_loadBtn_pressed():
	print("Load button pressed")
	get_tree().change_scene("res://Scenes/Menu/Discover/FindLevels.tscn")
	return
	var title		: String = ""
	var description	: String = ""
	var is_initial	: bool = false
	var is_final		: bool = true
	# Pack scene and save
	var load_path	: String = ""
	var toLoad 		: PackedScene = PackedScene.new()
	var err = "";
	var ret = "";
	# TODO: add an interface to show all the nodes stored in the server
	# load scenes from the server
	Client.get_level("My awesome level")
	if (err != ""):
		print("Error in saving the level.")
	
	toLoad = ResourceLoader.load(load_path)
	var this_level = toLoad.instance()
	level_editor.remove_child(level)
	level.queue_free()
	
	level_editor.add_child(this_level)
	# Update attributes
	tile_map = level_editor.get_node("Level/TileMap")
	level = this_level

	var node_id: String = ""
	assert(Client.get_level(node_id) == "")
	ret = yield(Client, "get_level_completed")
	assert(ret.get("message", "error") == "level")
		
	# add it to current scene
	# https://forum.godotengine.org/t/how-to-load-a-scene-from-a-filepath/9953/2
	var level_path: String = "res://SavedLevels/" + node_id + ".tscn"
	var loaded_level: PackedScene = load(level_path)
	if loaded_level == null:
		print("Error in loading level " + level_path)
	else:
		get_tree().root.add_child(loaded_level.instance())


func _on_exitBtn_pressed():
	print("Exit button pressed")
	if (Global.playing):
		Global.playing = !Global.playing
		NodeManager.end_play_test()
	# connect to the main menu
	get_tree().change_scene("res://Scenes/Menu/PlayerMain/PlayerMain.tscn")
	
func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Failed to load level from server: ", response_code)
		return

	var packed_scene = PackedScene.new()
	var error = packed_scene.pack(body)
	if error != OK:
		print("Failed to load PackedScene: ", error)
		return

	var scene = packed_scene.instance()
	if scene:
		get_tree().change_scene_to(packed_scene)
	else:
		print("Failed to instance scene.")
		
		
func _mouse_enter():
	object_cursor.can_place = false
	object_cursor.hide()
	
func _mouse_leave():
	object_cursor.can_place = true
	object_cursor.show()
	
