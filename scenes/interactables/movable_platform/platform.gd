extends CharacterBody2D

@export var travel_distance := 50.0
@export var movement_speed := 180.0

var start_position := Vector2.ZERO
var rider: Player = null

func _ready() -> void:
	start_position = position

func _physics_process(delta: float) -> void:
	rider = _find_rider()

	var heart_delta := 0.0
	if rider != null:
		heart_delta = clampf(float(rider.hearts - Player.START_HEARTS), -1.0, 1.0)
	var target_position := start_position + Vector2.DOWN * heart_delta * travel_distance
	var previous_position := position
	position = position.move_toward(target_position, movement_speed * delta)

	if rider != null:
		rider.global_position += position - previous_positi

func _find_rider() -> Player:
	for body in $RiderDetector.get_overlapping_bodies():
		if body is Player and not body.is_dead and body.global_position.y < global_position.y:
			return body
	return null
