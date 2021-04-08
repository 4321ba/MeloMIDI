extends FileDialog

onready var notes: Node2D = $"../toolbar_separator/working_area/graph_scroll_container/graph_spacer/graph_area/notes"

func _ready():
	var path: String = OS.get_system_dir(OS.SYSTEM_DIR_MUSIC) + "/"
	current_dir = path
	current_path = path

func _on_save_midi_file_dialog_file_selected(path):
	midi_saver.save_midi(notes.get_notes(), path)
