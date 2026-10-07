extends Base_State
@onready var player:Player = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"


func enter() -> void:
	player.is_dead = true
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.get_node("CollisionShape2D").set_deferred("disabled", true)
	player.get_node("EatArea2D/CollisionShape2D").set_deferred("disabled", true)
	animated_sprite.play("dead")
	await get_tree().create_timer(5)
	player.emit_signal("death")
	
func do(_delta: float) -> void:
	pass
