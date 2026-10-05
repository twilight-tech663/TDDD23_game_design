extends CharacterBody2D

signal consumed

var is_consumed := false

func is_green_slime() -> bool:
	return true

func _ready() -> void:
	$AnimatedSprite2D.play("alive")

func consume() -> void:
	if is_consumed:
		return

	is_consumed = true
	consumed.emit()
	queue_free()
