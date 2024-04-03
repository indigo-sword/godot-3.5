extends KinematicBody2D

export var health: int = 500
export var attack: int = 50
export var speed : int = 50
export var is_moving: bool = true

onready var _mov_sprite:  Sprite = get_node("MoveSprite")
onready var _atk_sprite:  Sprite = get_node("AttackSprite")
onready var _anim_tree:   AnimationTree = get_node("AnimationTree")
onready var _anim_state:  AnimationNodeStateMachinePlayback = _anim_tree.get("parameters/playback")

enum STATE {
	PATROL,
	PURSUE,
	ATTACK
}
var state

var last_glb_pos: Vector2 = Vector2.ZERO
var curr_mov_vec: Vector2 = Vector2.ZERO

func _ready():
	# TODO add control for attacking
	state = STATE.PATROL
	is_moving = true
	_mov_sprite.visible = true
	_atk_sprite.visible = false

func _physics_process(delta):
	match state:
		STATE.PATROL:
			is_moving = true
			_on_walk()
		STATE.ATTACK:
			is_moving = false
			_on_attack_enter()

func _on_walk():
	curr_mov_vec = (self.global_position - last_glb_pos).normalized()
	last_glb_pos = self.global_position
	_anim_tree.set("parameters/Walk/blend_position", curr_mov_vec)
	_anim_tree.set("parameters/Attack/blend_position", curr_mov_vec)
	# FIXME
	if(Input.is_key_pressed(KEY_SPACE)):
		state = STATE.ATTACK

func _on_attack_enter():
	_mov_sprite.visible = false
	_atk_sprite.visible = true
	_anim_state.travel("Attack")

func _on_attack_exit():
	_mov_sprite.visible = true
	_atk_sprite.visible = false
	_anim_state.travel("Walk")
	state = STATE.PATROL

