extends ScrollContainer

onready var graph_scroll_container: ScrollContainer = $"../graph_scroll_container"
onready var piano_bar: Control = $piano_bar

func _ready():
	get_v_scrollbar().share(graph_scroll_container.get_v_scrollbar())
	#we need to have a hscrollbar at the bottom, because we share
	#the vscrollbar, and when there's a hscrollbar in the main graph
	#area, then the sharing would break the bottom 12 pixels
	#or more depending on the theme 
	get_h_scrollbar().rect_min_size.y = get_h_scrollbar().rect_size.y
	get_h_scrollbar().mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = load("res://themes/scrollbar_remover.tres")

func _on_graph_scroll_container_scale_changed(new_endpoint):
	piano_bar.rect_min_size.y = new_endpoint.y
