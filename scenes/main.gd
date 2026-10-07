extends Node2D

func _on_action_scene_game_start() -> void:
	var scene = preload("res://scenes/map/game_map/map.tscn").instantiate()
	scene.connect("victory", Callable($ActionScene, "victory"))
	scene.connect("failed", Callable($ActionScene, "death"))
	add_child(scene)
