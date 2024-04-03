extends PathFollow2D

onready var body: KinematicBody2D = get_child(0)

func _physics_process(delta):
	self.offset += delta * body.speed
