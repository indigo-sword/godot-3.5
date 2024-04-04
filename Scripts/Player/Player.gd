extends KinematicBody2D

# Globals
export var MAX_SPEED = 200
export var ACCELERATION = 500
export var FRICTION = 500
enum STATE {
	MOVE, ATTACK
}
const DASH_SPEED = 500
const DASH_DURATION = 0.7
const DASH_COOLDOWN = 1

# Player params
var velocity = Vector2.ZERO
var state = STATE.MOVE
var is_dashing = false
var time_last_dashed = 0.0

# Tree nodes
onready var _anim_tree = $AnimationTree
onready var _anim_state = _anim_tree.get("parameters/playback")
onready var _timer = $Timer
onready var _sword_hitbox = $HitboxPivot/SwordHitbox

func _ready():
	$Camera2D.current = true
	_anim_tree.active = true

func _physics_process(delta):
	match state:
		STATE.MOVE:
			move(delta)
		STATE.ATTACK:
			on_attack_enter()

func move(delta):
	# elif (Input.is_action_just_pressed("dash")):
		# if (can_dash()):
		#	anim_player.play("Dash")
		#	timer.start_dash(DASH_DURATION)
		#	time_last_dashed = OS.get_ticks_msec()
	
	# speed = DASH_SPEED if timer.is_dashing() else NORM_SPEED
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("d") - Input.get_action_strength("a")
	input_vector.y = Input.get_action_strength("s") - Input.get_action_strength("w")
	input_vector = input_vector.normalized()
	
	# if !timer.is_dashing():
	if (input_vector != Vector2.ZERO):
		_sword_hitbox.knockback_vector = input_vector
		_anim_tree.set("parameters/Idle/blend_position", input_vector.x)
		_anim_tree.set("parameters/Walk/blend_position", input_vector.x)
		_anim_tree.set("parameters/Attack/blend_position", input_vector.x)
		_anim_state.travel("Walk")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		_anim_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
	
	if (Input.is_action_just_pressed("attack")):
		state = STATE.ATTACK
	
func on_attack_enter():
	velocity = Vector2.ZERO
	_anim_state.travel("Attack")
	
func on_attack_exit():
	state = STATE.MOVE

func can_dash():
	var current_time = OS.get_ticks_msec()
	var time_since_last_dash = current_time - time_last_dashed
	if (time_since_last_dash > DASH_COOLDOWN * 1000):
		return true
	else:
		return false
