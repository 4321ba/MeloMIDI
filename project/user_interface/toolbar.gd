extends HBoxContainer

onready var open_file_dialog: FileDialog = $"../../open_file_dialog"
onready var cursor_options: WindowDialog = $"../../cursor_options"
onready var fft_options: WindowDialog = $"../../fft_options"

func _on_load_file_pressed():
	open_file_dialog.popup_centered()

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

func _on_cursor_options_pressed():
	cursor_options.popup_centered()

func _on_fft_options_pressed():
	fft_options.popup_centered()
