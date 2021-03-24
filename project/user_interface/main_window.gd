extends Control

onready var file_dialog: FileDialog = $file_dialog
onready var graph_scroll_container: ScrollContainer = $toolbar_separator/working_area/graph_scroll_container

func _ready():
	var path: String = OS.get_system_dir(OS.SYSTEM_DIR_MUSIC) + "/"
	file_dialog.current_dir = path
	file_dialog.current_path = path

func _on_load_file_pressed():
	file_dialog.show()
	#we need to refresh so that it actually shows the files
	file_dialog.show_hidden_files = true
	file_dialog.show_hidden_files = false

func _on_file_dialog_file_selected(path):
	wave_player.replay_cursor_position_percent = 0
	wave_player.load_file(path)
	graph_scroll_container.reset(path)
