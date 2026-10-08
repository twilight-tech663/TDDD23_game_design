extends TileMapLayer

signal victory
signal failed

func _on_door_victory() -> void:
	emit_signal("victory")
	queue_free()

func _on_player_death() -> void:
	emit_signal("failed")
	queue_free()
