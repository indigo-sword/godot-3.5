extends KinematicBody2D

# Globals
const NORM_SPEED = 150
enum STATE {
	MOVE, ATTACK
}
const DASH_SPEED = 450
const DASH_DURATION = 0.7
const DASH_COOLDOWN = 1

# Player params
var speed = NORM_SPEED
var state = STATE.MOVE
var is_dashing = false
var time_last_dashed = 0.0

# Tree nodes
onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var anim_tree = $AnimationTree
onready var timer = $Timer

func _physics_process(delta):
	match state:
		STATE.MOVE:
			move(delta)
		STATE.ATTACK:
			on_attack_enter()

func move(delta):
	if (Input.is_action_just_pressed("attack")):
		state = STATE.ATTACK
	elif (Input.is_action_just_pressed("dash")):
		if (can_dash()):
			anim_player.play("Dash")
			timer.start_dash(DASH_DURATION)
			time_last_dashed = OS.get_ticks_msec()
	
	speed = DASH_SPEED if timer.is_dashing() else NORM_SPEED
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("d") - Input.get_action_strength("a")
	input_vector.y = Input.get_action_strength("s") - Input.get_action_strength("w")
	input_vector = input_vector.normalized()
	
	if (input_vector != Vector2.ZERO):
		sprite.flip_h = true if input_vector.x < 0 else false
	
	if !timer.is_dashing():
		if (input_vector == Vector2.ZERO):
			anim_player.play("Idle")
		else:
			anim_player.play("Run")
	
	move_and_collide(input_vector * delta * speed)
	
func on_attack_enter():
	anim_player.play("Attack")
	
func on_attack_exit():
	state = STATE.MOVE

func can_dash():
	var current_time = OS.get_ticks_msec()
	var time_since_last_dash = current_time - time_last_dashed
	if (time_since_last_dash > DASH_COOLDOWN * 1000):
		return true
	else:
		return false
