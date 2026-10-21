extends Node2D

const LEVEL_PATHS := [
	"res://scenes/map/game_map/level_1.tscn",
	"res://scenes/map/game_map/level_2.tscn",
	"res://scenes/map/game_map/level_3.tscn",
]

var current_level := 0

func _on_action_scene_game_start() -> void:
	current_level = 0
	_load_level(current_level)

func _load_level(index: int) -> void:
	var scene = load(LEVEL_PATHS[index]).instantiate()
	scene.is_last_level = index == LEVEL_PATHS.size() - 1
	scene.connect("victory", Callable($ActionScene, "victory"))
	scene.connect("failed", Callable($ActionScene, "death"))
	scene.connect("level_completed", _on_level_completed)
	add_child(scene)

func _on_level_completed() -> void:
	current_level += 1
	_load_level(current_level)
