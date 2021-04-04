extends Control
#this script is responsible for drawing the piano on the left

var note_playing: int

func _draw():
	if rect_size.y == 0:
		return
	var font: Font = get_font("font", "Label")
	var one_key_height: float = rect_size.y / 128.0
	draw_rect(Rect2(Vector2.ZERO, rect_size), Color.white)
	for note in 128:
		var begin := Vector2(0, one_key_height * (127 - note))
		var end := Vector2(rect_size.x, one_key_height * (127 - note))
		var offset := Vector2(0, one_key_height * 0.5)
		#if it's a black key
		if note % 12 in [1, 3, 6, 8, 10]:
			draw_line(begin + offset, (end + offset) * Vector2(0.75, 1), Color.black, one_key_height)
			draw_line(begin + offset, end + offset, Color.black)
		#if its a BC or EF, so we draw a line between them
		if note % 12 in [4, 11]:
			draw_line(begin, end, Color.black)
		if note % 12 == 0 and one_key_height > 8:
			draw_string(font, end * Vector2(0.25, 1) + offset + Vector2(0, 5), "C" + str(note / 12 - 1), Color.black)

func _gui_input(event):
	if (event is InputEventMouseButton and
		event.button_index == BUTTON_LEFT):
		if event.pressed:
			note_playing = 127 - int(128 * event.position.y / rect_size.y)
			midi_player.play_note(note_playing, 127)
		else:
			midi_player.play_note(note_playing, 0)
