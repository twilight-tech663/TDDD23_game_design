class_name HealthHUD
extends CanvasLayer

const EMPTY_HEART_COLOR := Color(0.25, 0.25, 0.25, 0.6)

@onready var heart_icons: Array[Node] = $Hearts.get_children()

func set_hearts(hearts: int) -> void:
	for i in heart_icons.size():
		heart_icons[i].modulate = Color.WHITE if i < hearts else EMPTY_HEART_COLOR
