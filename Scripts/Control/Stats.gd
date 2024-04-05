extends Node2D

export var max_health: int = 300
onready var health: int = max_health setget set_health

signal no_health

func set_health(value: int):
	health = value
	if (health <= 0):
		emit_signal("no_health")
