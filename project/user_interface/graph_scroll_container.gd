extends ScrollContainer
#this script is used for zooming and other related stuff

onready var graph_spacer: Control = $graph_spacer
onready var graph_area: Node2D = $graph_spacer/graph_area
onready var spectrum_textures: Node2D = $graph_spacer/graph_area/spectrum_textures
onready var endpoint: Node2D = $graph_spacer/graph_area/endpoint
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

func add_spectrum_texture(spectrum_texture: SpectrumTexture):
	for spectrum_texture in spectrum_textures.get_children():
		spectrum_texture.queue_free()
	spectrum_textures.add_child(spectrum_texture)
	endpoint.position = spectrum_analyzer.texture_size
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
	var current_size: Vector2 = endpoint.position * graph_area.scale
	graph_spacer.rect_min_size = current_size
	piano_scroll_container.update_length(current_size)
	timeline_scroll_container.update_length(current_size)

func reset():
	scroll_horizontal = 0
	scroll_vertical = 0
	graph_area.scale = Vector2(1, 1)
