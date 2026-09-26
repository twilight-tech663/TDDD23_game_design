extends Base_State
@onready var player:Player = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"

const SPEED = 100.0

func enter() -> void:
	animated_sprite.play("move")
	
func do(_delta: float) -> void:
	if Input.is_action_just_pressed("drop"):
		player.detach_from_surface()
		get_parent().change_state(2)
		return
	if !player.is_adhere and !player.is_on_floor():
		get_parent().change_state(2)
		return
	
	var vec:Vector2 = Vector2.ZERO
	vec.x = Input.get_axis("move_left", "move_right")
	if vec.x == 0:
		get_parent().change_state(0)
		return

	animated_sprite.flip_h = vec.x < 0
	if player.is_adhere:
		player.move_on_surface(vec.x)
	else:
		player.velocity.x = vec.x * SPEED
		player.velocity.y = 0
		player.move_and_slide()
		player.find_adhesion_surface()
	
	
