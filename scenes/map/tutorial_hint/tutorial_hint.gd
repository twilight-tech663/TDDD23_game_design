extends CanvasLayer

@export var text: String

func show_hint() -> void:
	$Panel/Label.text = text
	visible = true
	$Timer.start()

func _on_timer_timeout() -> void:
	visible = false
