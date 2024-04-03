extends KinematicBody2D

export var health: int = 500
export var attack: int = 50
export var speed : int = 50

onready var _mov_sprite:  Sprite = get_node("MoveSprite")
onready var _atk_sprite:  Sprite = get_node("AttackSprite")
onready var _anim_tree:   AnimationTree = get_node("AnimationTree")

var last_glb_pos: Vector2 = Vector2.ZERO
var curr_mov_vec: Vector2 = Vector2.ZERO

func _ready():
	# TODO add control for attacking
	_mov_sprite.visible = true
	_atk_sprite.visible = false

func _physics_process(delta):
	curr_mov_vec = self.global_position - last_glb_pos
	last_glb_pos = self.global_position
	_anim_tree.set("parameters/Walk/blend_position", curr_mov_vec.normalized())
