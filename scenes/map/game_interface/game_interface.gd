extends TextureRect

signal game_start

func victory():
	$CenterContainer/VBoxContainer/Label.text("You win!")
	show()
	
func death():
	$CenterContainer/VBoxContainer/Label.text("Try again")
	show()

func _on_start_pressed():
	hide()
	emit_signal("game_start")
	
func on_exit_pressed():
	get_tree().quit()
