extends ScrollContainer

onready var graph_spacer: Control = $graph_spacer
onready var graph_area: Node2D = $graph_spacer/graph_area
onready var spectrum_textures: Node2D = $graph_spacer/graph_area/spectrum_textures
onready var endpoint: Node2D = $graph_spacer/graph_area/endpoint

func _input(event):
	if (event is InputEventMouseButton and
		(event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN) and
		event.pressed and
		Input.is_action_pressed("control_key")
		):
		if Input.is_action_pressed("shift_key"):
			if event.button_index == BUTTON_WHEEL_UP:
				zoom(Vector2(1, 1.2))
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom(Vector2(1, 1 / 1.2))
		else:
			if event.button_index == BUTTON_WHEEL_UP:
				zoom(Vector2(1.2, 1.2))
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom(Vector2(1 / 1.2, 1 / 1.2))
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
	print(scroll_horizontal)
	scroll_horizontal = scroll_horizontal * scale.x + (scale.x - 1) * rect_size.x / 2
	print(scroll_horizontal)
	scroll_vertical = scroll_vertical * scale.y + (scale.y - 1) * rect_size.y / 2
	print(endpoint.position * graph_area.scale, " ", scroll_horizontal, " ", scroll_vertical)

func update_graph_spacer():
	graph_spacer.rect_min_size = endpoint.position * graph_area.scale
