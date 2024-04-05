extends KinematicBody2D

export var MAX_SPEED:    int = 50
export var ACCELERATION: int = 100
export var FRICTION:     int = 400

onready var _anim_tree:   AnimationTree = get_node("AnimationTree")
onready var _anim_state:  AnimationNodeStateMachinePlayback = _anim_tree.get("parameters/playback")
onready var _stats:       Node2D = get_node("Stats")
onready var _player_detection_box: Area2D = get_node("PlayerDetectionBox")
onready var _enemy_reach_box:      Area2D = get_node("EnemyReachBox")

enum STATE {
	PATROL,
	PURSUE,
	ATTACK,
	DEAD
}
var state

var last_glb_pos: Vector2 = Vector2.ZERO
var curr_mov_vec: Vector2 = Vector2.ZERO
var velocity:  Vector2 = Vector2.ZERO
var knockback: Vector2 = Vector2.ZERO

func _ready():
	# TODO add control for attacking
	_anim_tree.active = true
	state = STATE.PATROL

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	if velocity != Vector2.ZERO:
		_anim_tree.set("parameters/Walk/blend_position", velocity)
		_anim_tree.set("parameters/Attack/blend_position", velocity)
	
	match state:
		STATE.PATROL:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			if _player_detection_box.can_see_player():
				state = STATE.PURSUE
		STATE.PURSUE:
			var player = _player_detection_box.player
			if player == null:
				state = STATE.PATROL
			else:
				var direction = player.get_node("Hurtbox/CollisionShape2D").global_position - get_node("Hitbox/CollisionShape2D").global_position
				if _enemy_reach_box.is_in_reach():
					state = STATE.ATTACK
				else:
					velocity = velocity.move_toward(direction.normalized() * MAX_SPEED, ACCELERATION * delta)
		STATE.ATTACK:
			velocity = Vector2.ZERO
			_anim_state.travel("Attack")
		STATE.DEAD:
			velocity = Vector2.ZERO

	velocity = move_and_slide(velocity)

func _on_attack_exit():
	_anim_state.travel("Walk")
	state = STATE.PATROL

func _on_die():
	queue_free()

func _on_Hurtbox_area_entered(area):
	_stats.health -= area.damage
	knockback = area.knockback_vector * 200

func _on_Stats_no_health():
	_anim_state.travel("Die")
	state = STATE.DEAD

