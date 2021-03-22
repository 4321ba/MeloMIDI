extends ScrollContainer

onready var graph_scroll_container: ScrollContainer = $"../graph_scroll_container"
onready var timeline_bar: Control = $timeline_bar

func _ready():
	get_h_scrollbar().share(graph_scroll_container.get_h_scrollbar())
	#see comment in piano_scroll_container.gd, except h<->v and x<->y
	get_v_scrollbar().rect_min_size.x = get_v_scrollbar().rect_size.x
	get_v_scrollbar().mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = load("res://themes/scrollbar_remover.tres")

func _on_graph_scroll_container_scale_changed(new_endpoint):
	timeline_bar.rect_min_size.x = new_endpoint.x
