extends KinematicBody2D

# Globals
export var MAX_SPEED = 80
export var ACCELERATION = 50
export var FRICTION = 300
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
onready var _idle_sprite = $IdleSprite
onready var _walk_sprite = $WalkSprite
onready var _attack_sprite = $AttackSprite
onready var _anim_player = $AnimationPlayer
onready var _timer = $Timer

func _ready():
	$Camera2D.current = true
	_idle_sprite.visible = true
	_walk_sprite.visible = false
	_attack_sprite.visible = false

func _physics_process(delta):
	match state:
		STATE.MOVE:
			move(delta)
		STATE.ATTACK:
			on_attack_enter()

func move(delta):
	if (Input.is_action_just_pressed("attack")):
		state = STATE.ATTACK
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
	
	if (input_vector != Vector2.ZERO):
		_idle_sprite.flip_h = true if input_vector.x > 0 else false
		_walk_sprite.flip_h = true if input_vector.x > 0 else false
		_attack_sprite.flip_h = true if input_vector.x > 0 else false
		velocity += input_vector * ACCELERATION * delta
		velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# if !timer.is_dashing():
	if (input_vector == Vector2.ZERO):
		play_anim("Idle")
	else:
		play_anim("Walk")
	
	move_and_collide(velocity)
	
func on_attack_enter():
	play_anim("Attack")
	
func on_attack_exit():
	state = STATE.MOVE

func can_dash():
	var current_time = OS.get_ticks_msec()
	var time_since_last_dash = current_time - time_last_dashed
	if (time_since_last_dash > DASH_COOLDOWN * 1000):
		return true
	else:
		return false

func play_anim(anim: String):
	_idle_sprite.visible = true if anim == "Idle" else false
	_walk_sprite.visible = true if anim == "Walk" else false
	_attack_sprite.visible = true if anim == "Attack" else false
	_anim_player.play(anim)
