extends HBoxContainer

onready var open_wave_file_dialog: FileDialog = $"../../open_wave_file_dialog"
onready var save_midi_file_dialog: FileDialog = $"../../save_midi_file_dialog"
onready var general_options_dialog: WindowDialog = $"../../general_options_dialog"
onready var conversion_options_dialog: WindowDialog = $"../../conversion_options_dialog"
onready var help_dialog: WindowDialog = $"../../help_dialog"
onready var notes: Node2D = $"../working_area/graph_scroll_container/graph_spacer/graph_area/notes"

func _on_open_wave_file_button_pressed():
	open_wave_file_dialog.popup_centered()

func _on_save_midi_file_button_pressed():
	save_midi_file_dialog.popup_centered()

func _on_general_options_button_pressed():
	general_options_dialog.popup_centered()

func _on_conversion_options_button_pressed():
	conversion_options_dialog.popup_centered()

func _on_help_button_pressed():
	help_dialog.popup_centered()

func _on_source_option_item_selected(index):
	#note: this can also be changed from global_shortcuts.gd with the shortcut
	options.options.general.sound_source_option = index
	options.update_sound_source_option()

func _on_hide_notes_button_toggled(button_pressed):
	options.options.general.hide_notes = button_pressed
	notes.visible = not button_pressed
