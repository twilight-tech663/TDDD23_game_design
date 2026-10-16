extends CharacterBody2D

@export var travel_distance := 100.0
@export var movement_speed := 180.0
@export var reference_weight := 1.0

var start_position := Vector2.ZERO
var rider: Player = null

func _ready() -> void:
	start_position = position

func _physics_process(delta: float) -> void:
	var detected_rider := _find_rider()
	if detected_rider != null:
		rider = detected_rider
	else:
		rider = null

	var weight := rider.get_weight() if rider != null else reference_weight
	var target_offset := clampf((weight - reference_weight) * travel_distance, -travel_distance, travel_distance)
	var target_position := start_position + Vector2.DOWN * target_offset
	var previous_position := position
	position = position.move_toward(target_position, movement_speed * delta)

	if rider != null and rider.is_adhere and rider.current_surface_collider == self:
		rider.global_position += position - previous_position

func _find_rider() -> Player:
	for body in $RiderDetector.get_overlapping_bodies():
		if body is Player and body.is_adhere and body.current_surface_collider == self:
			return body
	return null
