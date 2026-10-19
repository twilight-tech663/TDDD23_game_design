extends TileMapLayer

signal victory
signal failed

const LOSE_DISPLAY_TIME := 3.0
const WIN_DISPLAY_TIME := 3.0

func _on_door_victory() -> void:
	$YouWinLayer.visible = true
	await get_tree().create_timer(WIN_DISPLAY_TIME).timeout
	emit_signal("victory")
	queue_free()

func _on_player_death() -> void:
	$YouLoseLayer.visible = true
	await get_tree().create_timer(LOSE_DISPLAY_TIME).timeout
	emit_signal("failed")
	queue_free()
