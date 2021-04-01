extends FileDialog

onready var graph_scroll_container: ScrollContainer = $"../toolbar_separator/working_area/graph_scroll_container"

func _ready():
	var path: String = OS.get_system_dir(OS.SYSTEM_DIR_MUSIC) + "/"
	current_dir = path
	current_path = path

func _on_open_file_dialog_file_selected(path):
	spectrum_analyzer.file_path = path
	wave_player.load_file()
	graph_scroll_container.reset()
