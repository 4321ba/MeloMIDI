extends Control

onready var file_dialog: FileDialog = $file_dialog_canvas/center_container/file_dialog
onready var graph_area: HBoxContainer = $toolbar_separator/working_area/scroll_container/graph_area

func _on_load_file_pressed():
	file_dialog.show()

func _on_file_dialog_file_selected(path):
	var spectrum_texture: SpectrumTexture = spectrum_analyzer.analyze_spectrum(path)
	graph_area.add_child(spectrum_texture)
