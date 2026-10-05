extends Coblin_Base_State

@onready var coblin: Coblin = get_parent().get_parent()
@onready var animated_sprite: AnimatedSprite2D = coblin.get_node("AnimatedSprite2D")

func enter() -> void:
	animated_sprite.play("walk")

func do(_delta: float) -> void:
	var target := coblin.find_attack_target()
	if target != null:
		get_parent().change_state(1)
		return
	
	coblin.velocity.x = coblin.direction * coblin.SPEED
	animated_sprite.flip_h = coblin.direction > 0.0
	coblin.move_and_slide()
	if coblin.is_on_wall() or not coblin.has_floor_ahead():
		coblin.direction *= -1.0
	
