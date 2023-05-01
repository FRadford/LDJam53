extends PanelContainer

signal resume

func _on_resume_button_pressed():
	visible = false
	get_tree().paused = false
	emit_signal("resume")

func _on_quit_button_pressed():
	get_tree().quit()
