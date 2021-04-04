extends "res://addons/midi/MidiPlayer.gd"

func play_note(note: int, velocity: int):
	#velocity = 0 for note off event
	var midi_event: InputEventMIDI = InputEventMIDI.new()
	#0x09 = note on, 0x08 = note off
	midi_event.message = 0x09 if velocity else 0x08
	midi_event.pitch = note # note number
	midi_event.velocity = velocity # velocity
	receive_raw_midi_message(midi_event)
