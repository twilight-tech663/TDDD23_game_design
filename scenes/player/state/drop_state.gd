extends Base_State
@onready var player:Player = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const SPEED = 100.0

func enter() -> void:
	if player.is_adhere:
		player.detach_from_surface()
	player.velocity.y = max(player.velocity.y, SPEED)
	animated_sprite.play("drop")
	
func do(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		animated_sprite.flip_h = direction < 0

	player.velocity.x = direction * SPEED
	player.velocity.y += gravity * delta
	player.move_and_slide()

	if player.is_on_floor():
		if direction == 0:
			get_parent().change_state(0)
		else:
			get_parent().change_state(1)
		return

	if player.find_adhesion_surface():
		if direction == 0:
			get_parent().change_state(0)
		else:
			get_parent().change_state(1)
		return

func exit() -> void:
	player.velocity.y = 0
