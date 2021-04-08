extends WindowDialog

func _unhandled_key_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false

func _on_playback_option_toggled(button_pressed):
	options.triangle_follows_cursor = button_pressed

func _on_follow_option_item_selected(index):
	options.screen_follows_cursor = index
