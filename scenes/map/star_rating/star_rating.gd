extends CanvasLayer

func show_stars(count: int) -> void:
	var stars := $Board/Stars.get_children()
	for i in stars.size():
		stars[i].visible = i == count - 1
	visible = true
