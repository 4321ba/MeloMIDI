extends HBoxContainer

onready var open_wave_file_dialog: FileDialog = $"../../open_wave_file_dialog"
onready var save_midi_file_dialog: FileDialog = $"../../save_midi_file_dialog"
onready var general_options_dialog: WindowDialog = $"../../general_options_dialog"
onready var conversion_options_dialog: WindowDialog = $"../../conversion_options_dialog"
onready var help_dialog: WindowDialog = $"../../help_dialog"

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
	var wave_bus: int = AudioServer.get_bus_index("Wave")
	var midi_bus: int = AudioServer.get_bus_index("Midi")
	AudioServer.set_bus_mute(wave_bus, false)
	AudioServer.set_bus_mute(midi_bus, false)
	var wave_panning: AudioEffectPanner = AudioServer.get_bus_effect(wave_bus, 0)
	var midi_panning: AudioEffectPanner = AudioServer.get_bus_effect(midi_bus, 0)
	wave_panning.pan = 0
	midi_panning.pan = 0
	match index:
		1:
			AudioServer.set_bus_mute(wave_bus, true)
		2:
			AudioServer.set_bus_mute(midi_bus, true)
		3:
			wave_panning.pan = 1
			midi_panning.pan = -1
		4:
			wave_panning.pan = -1
			midi_panning.pan = 1
