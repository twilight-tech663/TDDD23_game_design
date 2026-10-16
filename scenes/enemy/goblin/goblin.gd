class_name Coblin
extends CharacterBody2D

const SPEED := 35.0
const ATTACK_DURATION := 0.75
const DEATH_DURATION := 0.75
const FREEZE_DURATION := 5.0

var direction := -1.0
var is_dead := false
var attack_blocked_target: Node2D = null
var is_frozen := false
var freeze_time_left := 0.0

func _ready() -> void:
	$FSM.set_physics_process(true)

func _physics_process(delta: float) -> void:
	if !is_frozen:
		return

	freeze_time_left -= delta
	if freeze_time_left <= 0.0:
		is_frozen = false
		$AnimatedSprite2D.play()
		$FSM.set_physics_process(true)

func freeze(duration: float = FREEZE_DURATION) -> void:
	if is_dead:
		return

	for body in $Area2D.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):
			attack_blocked_target = body as Node2D
	$FSM.change_state(0)

	is_frozen = true
	freeze_time_left = max(freeze_time_left, duration)
	velocity = Vector2.ZERO
	$FSM.set_physics_process(false)
	$AnimatedSprite2D.pause()

func has_floor_ahead() -> bool:
	var raycast: RayCast2D = $RightRayCast if direction > 0.0 else $LeftRayCast
	raycast.force_raycast_update()
	return raycast.is_colliding()

func find_attack_target() -> Node2D:
	var blocked_target_is_inside := false
	for body in $Area2D.get_overlapping_bodies():
		if body == attack_blocked_target:
			blocked_target_is_inside = true
			continue
		if body != self and body.has_method("take_damage"):
			if body is Player and body.current_slime_type == Player.slime_type.RED:
				continue
			return body as Node2D
	if not blocked_target_is_inside:
		attack_blocked_target = null
	return null

func reverse_direction() -> void:
	direction *= -1.0

func take_damage(_amount: int = 1) -> void:
	if is_dead:
		return
	is_dead = true
	#print(is_dead)
	$FSM.change_state(2)
