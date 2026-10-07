extends StaticBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("ice")

func is_ice_surface() -> bool:
	return true
