extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	print(event)
	if (event is InputEventKey and event.scancode != 16777217) or (event is InputEventMouseButton) and event.is_pressed():
		get_tree().change_scene("res://Scenes/Menu/Main/Login.tscn")
