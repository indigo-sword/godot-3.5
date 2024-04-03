extends PathFollow2D

onready var body: KinematicBody2D = get_child(0)

func _physics_process(delta):
	if (body.is_moving):
		self.offset += delta * body.speed
