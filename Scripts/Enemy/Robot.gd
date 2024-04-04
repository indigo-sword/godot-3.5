extends KinematicBody2D

onready var _anim_tree:   AnimationTree = get_node("AnimationTree")
onready var _anim_state:  AnimationNodeStateMachinePlayback = _anim_tree.get("parameters/playback")
onready var _stats:       Node2D = get_node("Stats")

enum STATE {
	PATROL,
	PURSUE,
	ATTACK,
	DEAD
}
var state

var last_glb_pos: Vector2 = Vector2.ZERO
var curr_mov_vec: Vector2 = Vector2.ZERO
var knockback: Vector2 = Vector2.ZERO

func _ready():
	# TODO add control for attacking
	_anim_tree.active = true
	state = STATE.PATROL

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 400 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		STATE.PATROL:
			_on_walk()
		STATE.PURSUE:
			pass
		STATE.ATTACK:
			_on_attack_enter()
		STATE.DEAD:
			pass

func _on_walk():
	# Movement is controlled by parent PathFollow2D
	curr_mov_vec = (self.global_position - last_glb_pos).normalized()
	last_glb_pos = self.global_position
	_anim_tree.set("parameters/Walk/blend_position", curr_mov_vec)
	_anim_tree.set("parameters/Attack/blend_position", curr_mov_vec)
	# FIXME
	if(Input.is_key_pressed(KEY_SPACE)):
		state = STATE.ATTACK

func _on_attack_enter():
	_anim_state.travel("Attack")

func _on_attack_exit():
	_anim_state.travel("Walk")
	state = STATE.PATROL

func _on_Hurtbox_area_entered(area):
	_stats.health -= area.damage
	knockback = area.knockback_vector * 200

func _on_die():
	queue_free()

func _on_Stats_no_health():
	_anim_state.travel("Die")
	state = STATE.DEAD
