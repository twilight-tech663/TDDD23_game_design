extends Area2D

@export var hint_path: NodePath
@onready var hint: CanvasLayer = get_node(hint_path)

var is_triggered := false

func _on_body_entered(body: Node2D) -> void:
	if is_triggered or not body is Player:
		return
	is_triggered = true
	hint.show_hint()
