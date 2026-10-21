extends Coblin_Base_State

@onready var coblin: Coblin = get_parent().get_parent()
@onready var animated_sprite: AnimatedSprite2D = coblin.get_node("AnimatedSprite2D")

var has_attacked := false
var elapsed := 0.0
var attack_target: Node2D = null
var face_target = false

func enter() -> void:
	has_attacked = false
	elapsed = 0.0
	attack_target = coblin.find_attack_target()
	coblin.velocity = Vector2.ZERO
	_face_attack_target()
	animated_sprite.play("attack")

func do(delta: float) -> void:
	if !has_attacked and coblin.find_white_slime_contact():
		coblin.freeze()
		return

	coblin.velocity = Vector2.ZERO
	_face_attack_target()
	if has_attacked:
		elapsed += delta
		if elapsed >= coblin.ATTACK_DURATION:
			if face_target:
				coblin.reverse_direction()
				get_parent().change_state(0)
		return

	has_attacked = true
	coblin.attack_blocked_target = attack_target
	if is_instance_valid(attack_target) and attack_target.has_method("take_damage"):
		attack_target.take_damage(1)

func _face_attack_target() -> void:
	if is_instance_valid(attack_target):
		face_target = true
		animated_sprite.flip_h = attack_target.global_position.x > coblin.global_position.x
