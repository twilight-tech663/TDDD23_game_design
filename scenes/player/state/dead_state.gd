extends Base_State
@onready var player:Player = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"


func enter() -> void:
	player.is_dead = true
	player.velocity = Vector2.ZERO
	animated_sprite.play("dead")
	await animated_sprite.animation_finished
	if is_instance_valid(player):
		player.emit_signal("death")
