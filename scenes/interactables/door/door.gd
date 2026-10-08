extends StaticBody2D

signal victory

var has_triggered := false


func is_door() -> bool:
	return true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if has_triggered or not body is Player:
		return

	has_triggered = true
	# print("door collision", body.name)

	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(self):
		victory.emit()
