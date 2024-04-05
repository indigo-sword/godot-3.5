extends "res://Scripts/Control/Hitbox.gd"

var in_reach: bool = false

func is_in_reach():
	return in_reach

func _on_EnemySwordHitbox_area_entered(area):
	in_reach = true

func _on_EnemySwordHitbox_area_exited(area):
	in_reach = false
