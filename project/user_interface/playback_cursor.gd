extends Line2D
#this manages how the playback cursor moves (the white line that moves while playing back)

onready var timeline_bar: Control = $".."
onready var timeline_scroll_container: ScrollContainer = $"../.."
onready var graph_spacer: Control = $"../../../graph_scroll_container/graph_spacer"
onready var collision: CollisionShape2D = $area/collision

func _physics_process(_delta):
	if wave_player.playing:
		var playback_cursor_position_percent := wave_player.get_playback_position() / wave_player.stream.get_length()
		var playback_cursor_position := timeline_bar.rect_size.x * playback_cursor_position_percent
		position.x = playback_cursor_position
		if points.size() == 0:
			points = PoolVector2Array([Vector2(0, 0),Vector2(0, 0)])
		points[1].y = graph_spacer.rect_min_size.y + 34
		collision.shape.a.y = -graph_spacer.rect_min_size.y
		collision.shape.b = points[1]
		
		#if option is set  or  if we're left/right outside and other option is set
		if (options.options.general.screen_follows_cursor == options.CURSOR_ALWAYS_LEFT or (
			(timeline_scroll_container.scroll_horizontal + get_viewport_rect().size.x - 40 < playback_cursor_position or
			timeline_scroll_container.scroll_horizontal > playback_cursor_position) and
			options.options.general.screen_follows_cursor == options.JUMP_IF_PLAYING_OFFSCREEN)):
			timeline_scroll_container.scroll_horizontal = playback_cursor_position
		if options.options.general.screen_follows_cursor == options.CURSOR_ALWAYS_MIDDLE:
			timeline_scroll_container.scroll_horizontal = playback_cursor_position - (get_viewport_rect().size.x - 40) / 2
		if options.options.general.triangle_follows_cursor:
			wave_player.replay_cursor_position_percent = playback_cursor_position_percent
			timeline_bar.update()
	elif points.size() > 0:
		points = PoolVector2Array()
		collision.shape.a = Vector2(0, 0)
		collision.shape.b = Vector2(0, 0)

func _on_area_area_entered(area: Area2D):
	var note: Note = area.get_parent()
	midi_player.play_note(note.note, note.velocity)

func _on_area_area_exited(area: Area2D):
	var note: Note = area.get_parent()
	midi_player.play_note(note.note, 0)
