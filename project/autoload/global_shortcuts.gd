extends Node

onready var source_option_combobox: OptionButton = $"/root/main_window/toolbar_separator/toolbar/source_option_combobox"

#func _ready():
#	call_deferred("_deferred_ready")
#
#func _deferred_ready():
#	source_option_combobox = 

func _unhandled_key_input(event):
	var index: int
	if event.is_action_pressed("play_midi_and_wave"):
		index = options.PLAY_MIDI_AND_WAVE
	elif event.is_action_pressed("play_midi_only"):
		index = options.PLAY_MIDI_ONLY
	elif event.is_action_pressed("play_wave_only"):
		index = options.PLAY_WAVE_ONLY
	elif event.is_action_pressed("midi_left_wave_right"):
		index = options.MIDI_LEFT_WAVE_RIGHT
	elif event.is_action_pressed("midi_right_wave_left"):
		index = options.MIDI_RIGHT_WAVE_LEFT
	else:
		return
	options.options.general.sound_source_option = index
	options.update_sound_source_option()
	source_option_combobox.select(index)
