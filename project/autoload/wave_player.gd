extends AudioStreamPlayer

var replay_cursor_position_percent: float = 0

func _input(event):
	if event.is_action_pressed("ui_select") and stream:
		if playing:
			stop()
		else:
			play(replay_cursor_position_percent * stream.get_length())
		get_tree().set_input_as_handled()

func load_file():
	replay_cursor_position_percent = 0
	#source of GDScriptAudioImport.gd (audio_importer):
	#https://github.com/Gianclgar/GDScriptAudioImport
	stream = audio_importer.loadfile(options.options.misc.file_path)
	if stream is AudioStreamSample:
		stream.loop_mode = AudioStreamSample.LOOP_DISABLED
	else:
		stream.loop = false
