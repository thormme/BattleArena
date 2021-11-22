extends Label

func _on_CheckButton_toggled(button_pressed):
	if button_pressed:
		text = "Unready"
		get_parent().rect_position.y += 4
	else:
		text = "Ready"
		get_parent().rect_position.y -= 4
