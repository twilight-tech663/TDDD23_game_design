extends Base_State
@onready var player:Player = $"../.."
@onready var animated_sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"

func enter() -> void:
	animated_sprite.play("idle")
	
func do(_delta: float) -> void:
	# if player.is_adhere and !player.find_adhesion_surface():
	# 	player.detach_from_surface()
	# 	get_parent().change_state(2)
	# 	return

	if !player.is_adhere and !player.is_on_floor():
		get_parent().change_state(2)
		return
	
	var vec:Vector2 = Vector2.ZERO
	vec.x = Input.get_axis("move_left", "move_right")
	if vec.x != 0:
		get_parent().change_state(1)
		return
	elif Input.is_action_just_pressed("drop"):
		player.detach_from_surface()
		get_parent().change_state(2)
		return
		
	player.velocity = Vector2.ZERO
	player.move_and_slide()
