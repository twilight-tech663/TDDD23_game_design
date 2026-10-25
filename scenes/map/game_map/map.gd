extends TileMapLayer

signal victory
signal failed
signal level_completed

const LOSE_DISPLAY_TIME := 3.0
const WIN_DISPLAY_TIME := 3.0
const STAR_DISPLAY_TIME := 3.0

@export var is_last_level := true

func _on_door_victory() -> void:
	$StarRating.show_stars($Player.hearts)
	await get_tree().create_timer(STAR_DISPLAY_TIME).timeout
	$StarRating.visible = false
	if not is_last_level:
		emit_signal("level_completed")
		queue_free()
		return
	$YouWinLayer.visible = true
	await get_tree().create_timer(WIN_DISPLAY_TIME).timeout
	emit_signal("victory")
	queue_free()

func _on_player_death() -> void:
	$YouLoseLayer.visible = true
	await get_tree().create_timer(LOSE_DISPLAY_TIME).timeout
	emit_signal("failed")
	queue_free()
