extends Camera2D

onready var player = get_parent().get_node("Player")

func _ready():
	current = true
	zoom = Vector2(.5, .5)

func _process(delta):
	if is_instance_valid(player):
		global_position = player.global_position
