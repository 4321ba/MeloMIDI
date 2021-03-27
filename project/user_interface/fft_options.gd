extends WindowDialog

onready var graph_scroll_container: ScrollContainer = $"../toolbar_separator/working_area/graph_scroll_container"

onready var fft_size_option: SpinBox = $center/v_box/grid/fft_size_option
onready var hop_size_option: SpinBox = $center/v_box/grid/hop_size_option
onready var subdivision_option: SpinBox = $center/v_box/grid/subdivision_option
onready var tuning_option: SpinBox = $center/v_box/grid/tuning_option
onready var low_high_exponent_option: SpinBox = $center/v_box/grid/low_high_exponent_option
onready var overamplification_option: SpinBox = $center/v_box/grid/overamplification_option

func _unhandled_key_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false

func _on_recalculate_fft_pressed():
	spectrum_analyzer.fft_size = fft_size_option.value
	spectrum_analyzer.hop_size = hop_size_option.value
	spectrum_analyzer.subdivision = subdivision_option.value
	spectrum_analyzer.tuning = tuning_option.value
	spectrum_analyzer.low_high_exponent = low_high_exponent_option.value
	spectrum_analyzer.overamplification_multiplier = overamplification_option.value
	graph_scroll_container.reset()
