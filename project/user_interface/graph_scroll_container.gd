extends ScrollContainer
#this script is used for zooming and other related stuff

onready var graph_spacer: Control = $graph_spacer
onready var graph_area: Node2D = $graph_spacer/graph_area
onready var spectrum_sprites: Node2D = $graph_spacer/graph_area/spectrum_sprites
onready var stripes: Node2D = $graph_spacer/graph_area/stripes
onready var piano_scroll_container: ScrollContainer = $"../piano_scroll_container"
onready var timeline_scroll_container: ScrollContainer = $"../timeline_scroll_container"

func _input(event):
	if (event is InputEventMouseButton and
		(event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN) and
		event.pressed and
		event.control
		):
		if event.shift:
			if event.button_index == BUTTON_WHEEL_UP:
				zoom(Vector2(1, 1.2))
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom(Vector2(1, 1 / 1.2))
		else:
			if event.button_index == BUTTON_WHEEL_UP:
				zoom(Vector2(1.2, 1.2))
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom(Vector2(1 / 1.2, 1 / 1.2))
		#this makes so it doesn't scroll down/sideways
		#because of the built-in functionality
		get_tree().set_input_as_handled()

func reset(file_to_load):
	scroll_horizontal = 0
	scroll_vertical = 0
	graph_area.scale = Vector2(1, 1)
	
	var new_spectrum_sprites = spectrum_analyzer.analyze_spectrum(file_to_load)
	for spectrum_sprite in spectrum_sprites.get_children():
		spectrum_sprite.queue_free()
	var current_width := 0
	for spectrum_sprite in new_spectrum_sprites:
		spectrum_sprite.position.x = current_width
		current_width += spectrum_sprite.texture.get_width()
		spectrum_sprites.add_child(spectrum_sprite)
	stripes.update()
	update_graph_spacer()

func zoom(scale: Vector2):
	graph_area.scale *= scale
	update_graph_spacer()
	#we need to temporarily raise the limit so it isn't capped,
	#because the container's resize is only in the queue
	get_h_scrollbar().max_value = graph_spacer.rect_min_size.x * 2
	get_v_scrollbar().max_value = graph_spacer.rect_min_size.y * 2
	scroll_horizontal = scroll_horizontal * scale.x + (scale.x - 1) * rect_size.x / 2
	scroll_vertical = scroll_vertical * scale.y + (scale.y - 1) * rect_size.y / 2

func update_graph_spacer():
	var current_size: Vector2 = spectrum_analyzer.texture_size * graph_area.scale
	graph_spacer.rect_min_size = current_size
	piano_scroll_container.update_length(current_size)
	timeline_scroll_container.update_length(current_size)
