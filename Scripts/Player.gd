extends KinematicBody2D

var SPEED = 150
enum STATE {
	MOVE, ATTACK
}
var state = STATE.MOVE

onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var anim_tree = $AnimationTree

func _physics_process(delta):
	match state:
		STATE.MOVE:
			move(delta)
		STATE.ATTACK:
			on_attack_enter()

func move(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("d") - Input.get_action_strength("a")
	input_vector.y = Input.get_action_strength("s") - Input.get_action_strength("w")
	input_vector = input_vector.normalized()
	
	if (input_vector == Vector2.ZERO):
		anim_player.play("Idle")
	else:
		sprite.flip_h = true if input_vector.x < 0 else false
		anim_player.play("Run")
	
	move_and_collide(input_vector * delta * SPEED)
	
	if (Input.is_action_just_pressed("attack")):
		state = STATE.ATTACK
	
func on_attack_enter():
	anim_player.play("Attack")
	
func on_attack_exit():
	state = STATE.MOVE
