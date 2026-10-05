extends Coblin_Base_State

@onready var coblin: Coblin = get_parent().get_parent()
@onready var animated_sprite: AnimatedSprite2D = coblin.get_node("AnimatedSprite2D")

var elapsed := 0.0

func enter() -> void:
	elapsed = 0.0
	coblin.velocity = Vector2.ZERO
	coblin.set_physics_process(false)
	coblin.get_node("CollisionShape2D").set_deferred("disabled", true)
	coblin.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
	animated_sprite.play("dead")

func do(delta: float) -> void:
	elapsed += delta
	if elapsed >= coblin.DEATH_DURATION:
		coblin.queue_free()
