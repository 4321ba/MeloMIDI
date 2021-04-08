extends Node2D
#this script manages the horizontal stripes that resemble a piano
#and help distinguish between semitones

func _draw():
	var end: float = spectrum_analyzer.texture_size.x
	var one_seminote_gap := spectrum_analyzer.texture_size.y / 128.0
	var subdivision: int = options.options.fft.subdivision
	for note in 128:
		#if it's a black key
		if note % 12 in [1, 3, 6, 8, 10]:
			var height: float = (127 - note) * one_seminote_gap + subdivision / 2.0
			draw_line(Vector2(0, height), Vector2(end, height), Color(0, 0, 0, 0.2), subdivision)
		#if its a BC or EF, so we draw a line between them
		if note % 12 in [4, 11]:
			draw_line(Vector2(0, (127 - note) * one_seminote_gap), Vector2(end, (127 - note) * one_seminote_gap), Color(0, 0, 0, 0.2), 2)
