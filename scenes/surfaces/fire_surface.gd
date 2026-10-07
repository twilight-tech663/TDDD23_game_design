extends StaticBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("fire")

func is_fire_surface() -> bool:
	return true
