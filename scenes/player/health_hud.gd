class_name HealthHUD
extends CanvasLayer

const EMPTY_HEART_COLOR := Color(0.25, 0.25, 0.25, 0.6)

@export var slime_hearts: Array[Texture2D]
@onready var heart_icons: Array[Node] = $Hearts.get_children()

func set_slime_type(slime_type: int) -> void:
	for heart in heart_icons:
		heart.texture = slime_hearts[slime_type]

func set_hearts(hearts: int) -> void:
	for i in heart_icons.size():
		heart_icons[i].modulate = Color.WHITE if i < hearts else EMPTY_HEART_COLOR
