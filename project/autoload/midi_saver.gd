extends Node

var smf_script = SMF.new()

func save_midi(notes: PoolVector3Array, save_path):
	#notes come from notes.gd's get_notes function
	#and have the structure Vector3(time, pitch/note, volume/velocity)
	#where for note off events' volume is 0
	
	var pixel_per_second: float = spectrum_analyzer.sample_rate / options.options.fft.hop_size
	var smf_data: Dictionary = {
		"format_type": 1,
		"track_count": 1,
		#this is number of clock pulses per quarter note if I know correctly,
		#which we don't know, but we'll set it to 120bpm:
		"timebase": round(pixel_per_second / 2),
		"tracks": [{
			"track_number": 1,
			"events": [{
				"time": 0,
				"channel_number": 0,
				"event": {
					"type": smf_script.MIDIEventType.system_event,
					"args": {
						"type": smf_script.MIDISystemEventType.set_tempo,
						"bpm": 500000,
					}
				}
			}]
		}]
	}
	
	for note in notes:
		var event_chunk: Dictionary = {
			"time": note[0],
			"channel_number": 0,
			"event": {
				"type": smf_script.MIDIEventType.note_off if note[2] == 0 else smf_script.MIDIEventType.note_on,
				"note": note[1],
				"velocity": note[2],
			}
		}
		smf_data["tracks"][0]["events"].append(event_chunk)
	
	var end_track_event: Dictionary = {
		"time": spectrum_analyzer.texture_size.x,
		"channel_number": 0,
		"event": {
			"type": smf_script.MIDIEventType.system_event,
			"args": {
				"type": smf_script.MIDISystemEventType.end_of_track,
			}
		}
	}
	smf_data["tracks"][0]["events"].append(end_track_event)
	
	var bytes: PoolByteArray = smf_script.write(smf_data)
	
	print("Saving midi file ", save_path)
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_buffer(bytes)
	file.close()
