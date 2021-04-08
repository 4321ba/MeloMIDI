extends Node
#this script manages all options, so in case we later
#want to save it, it's all available here

enum {JUMP_IF_PLAYING_OFFSCREEN, DONT_FOLLOW_PLAYBACK, CURSOR_ALWAYS_LEFT, CURSOR_ALWAYS_MIDDLE}
enum {PLAY_MIDI_AND_WAVE, PLAY_MIDI_ONLY, PLAY_WAVE_ONLY, MIDI_LEFT_WAVE_RIGHT, MIDI_RIGHT_WAVE_LEFT}

var options = {
	fft = {
		use_2_ffts = true,
		fft_size_low = 16384,
		low_high_exponent_low = 0.6,
		overamplification_multiplier_low = 2.0,
		fft_size_high = 4096,
		low_high_exponent_high = 0.6,
		overamplification_multiplier_high = 2.0,
		hop_size = 1024,
		subdivision = 9,
		tuning = 440.0,
	},
	note_recognition = {
		note_on_threshold = 0.1,
		note_off_threshold = 0.05,
		octave_removal_multiplier = 0.2,
		minimum_length = 4,
		volume_multiplier = 2.0,
		percussion_removal = 1.0,
	},
	general = {
		triangle_follows_cursor = false,
		screen_follows_cursor = JUMP_IF_PLAYING_OFFSCREEN,
		sound_source_option = PLAY_MIDI_AND_WAVE,
		hide_notes = false,
	},
	misc = {
		file_path = "",
	},
}

func update_sound_source_option():
	var wave_bus: int = AudioServer.get_bus_index("Wave")
	var midi_bus: int = AudioServer.get_bus_index("Midi")
	AudioServer.set_bus_mute(wave_bus, false)
	AudioServer.set_bus_mute(midi_bus, false)
	var wave_panning: AudioEffectPanner = AudioServer.get_bus_effect(wave_bus, 0)
	var midi_panning: AudioEffectPanner = AudioServer.get_bus_effect(midi_bus, 0)
	wave_panning.pan = 0
	midi_panning.pan = 0
	match options.general.sound_source_option:
		PLAY_MIDI_ONLY:
			AudioServer.set_bus_mute(wave_bus, true)
		PLAY_WAVE_ONLY:
			AudioServer.set_bus_mute(midi_bus, true)
		MIDI_LEFT_WAVE_RIGHT:
			wave_panning.pan = 1
			midi_panning.pan = -1
		MIDI_RIGHT_WAVE_LEFT:
			wave_panning.pan = -1
			midi_panning.pan = 1
