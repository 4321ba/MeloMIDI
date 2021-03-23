extends AudioStreamPlayer

var replay_cursor_position_percent: float = 0

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("ui_select") and stream:
		if playing:
			stop()
		else:
			play(replay_cursor_position_percent * stream.get_length())

func load_file(filename: String):
	#source of GDScriptAudioImport.gd (audio_importer):
	#https://github.com/Gianclgar/GDScriptAudioImport
	stream = audio_importer.loadfile(filename)
	if stream is AudioStreamSample:
		stream.loop_mode = AudioStreamSample.LOOP_DISABLED
	else:
		stream.loop = false
