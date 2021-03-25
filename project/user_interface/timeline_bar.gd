extends Control
#this script is responsible for drawing the timeline on the top

var dragging: bool = false

func _gui_input(event):
	if not event is InputEventMouse or event.button_mask != BUTTON_LEFT:
		return
	if event is InputEventMouseButton:
		dragging = event.pressed
	if dragging:
		wave_player.replay_cursor_position_percent = min(max(event.position.x, 0), rect_size.x - 1) / rect_size.x
		update()

#this manages the timeline and triangle drawing
func _draw():
	if rect_size.x == 0:
		return
	var font: Font = get_font("font", "Label")
	#we want at most 10 time messages on screen (1280px/128px=10text on-screen)
	#so max_texts_to_draw is for the full timeline
	var max_texts_to_draw: float = rect_size.x / 128.0
	var full_time: float = spectrum_analyzer.texture_size.x * spectrum_analyzer.hop_size / spectrum_analyzer.sample_rate
	var min_seconds_per_text_drawn: float = full_time / max_texts_to_draw
	var step_size: float = pow(10, ceil(3 * log(min_seconds_per_text_drawn) / log(10)) / 3)
	var order_of_magnitude: int = floor(log(step_size) / log(10))
	
	step_size = stepify(step_size, pow(10, order_of_magnitude))
	var texts_to_draw: int = ceil(full_time / step_size)
	for i in texts_to_draw:
		var current_sec: float = i * step_size
		var current_pixel := Vector2(current_sec * rect_size.x / full_time + 1, 0)
		var minutes: int = current_sec / 60
		var seconds: float = current_sec - minutes * 60
		var opt_zero: String = "0" if seconds < 10 else ""
		draw_line(current_pixel, current_pixel + Vector2(0, rect_size.y - 1), Color.white)
		draw_string(font, current_pixel + Vector2(3, 20), "%s:%s%s" % [minutes, opt_zero, seconds])
	
	var cursor_position: float = wave_player.replay_cursor_position_percent * rect_size.x
	var points = PoolVector2Array([
		Vector2(cursor_position, rect_size.y),
		Vector2(cursor_position - 8, -1),
		Vector2(cursor_position + 8, -1)
		])
	draw_polygon(points, PoolColorArray([Color.white]))

