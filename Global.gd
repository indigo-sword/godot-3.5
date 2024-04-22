extends Node

var playing = false
var current_tile = 0
var current_tile_type = 0

var save_editor_shown = false

var uname = ""

enum LevelEditorItemType {
	GROUND,
	BULDING,
	DECOR,
	CHARACTER
}
