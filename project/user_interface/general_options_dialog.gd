extends WindowDialog

func _on_playback_option_toggled(button_pressed):
	options.options.general.triangle_follows_cursor = button_pressed

func _on_follow_option_item_selected(index):
	options.options.general.screen_follows_cursor = index
