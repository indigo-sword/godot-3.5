extends Node2D

export var max_health: int = 300
export var attack:     int = 50
export var speed:      int = 50
var health: int = max_health setget set_health

signal no_health

func set_health(value: int):
	health = value
	if (health <= 0):
		emit_signal("no_health")
