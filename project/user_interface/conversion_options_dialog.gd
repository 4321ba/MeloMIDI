extends WindowDialog

onready var graph_scroll_container: ScrollContainer = $"../toolbar_separator/working_area/graph_scroll_container"

#fft options
onready var two_ffts_option: Button = $center/bottom_separator/options_body/fft_part/two_ffts_option
onready var fft_size_low_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_double/fft_size_low_option
onready var low_high_exponent_low_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_double/low_high_exponent_low_option
onready var overamplification_low_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_double/overamplification_low_option
onready var fft_size_high_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_double/fft_size_high_option
onready var low_high_exponent_high_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_double/low_high_exponent_high_option
onready var overamplification_high_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_double/overamplification_high_option
onready var hop_size_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_single/hop_size_option
onready var subdivision_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_single/subdivision_option
onready var tuning_option: SpinBox = $center/bottom_separator/options_body/fft_part/grid_single/tuning_option
#recognition options
onready var note_on_threshold_option: SpinBox = $center/bottom_separator/options_body/recognition_part/grid/note_on_threshold_option
onready var note_off_threshold_option: SpinBox = $center/bottom_separator/options_body/recognition_part/grid/note_off_threshold_option
onready var octave_removal_option: SpinBox = $center/bottom_separator/options_body/recognition_part/grid/octave_removal_option
onready var minimum_length_option: SpinBox = $center/bottom_separator/options_body/recognition_part/grid/minimum_length_option
onready var volume_multiplier_option: SpinBox = $center/bottom_separator/options_body/recognition_part/grid/volume_multiplier_option
onready var percussion_removal_option: SpinBox = $center/bottom_separator/options_body/recognition_part/grid/percussion_removal_option

func _ready():
	#we want to display the (default) values from the options singleton
	#fft options
	two_ffts_option.pressed = options.options.fft.use_2_ffts
	fft_size_low_option.value = options.options.fft.fft_size_low
	low_high_exponent_low_option.value = options.options.fft.low_high_exponent_low
	overamplification_low_option.value = options.options.fft.overamplification_multiplier_low
	fft_size_high_option.value = options.options.fft.fft_size_high
	low_high_exponent_high_option.value = options.options.fft.low_high_exponent_high
	overamplification_high_option.value = options.options.fft.overamplification_multiplier_high
	hop_size_option.value = options.options.fft.hop_size
	subdivision_option.value = options.options.fft.subdivision
	tuning_option.value = options.options.fft.tuning
	#recognition options
	note_on_threshold_option.value = options.options.note_recognition.note_on_threshold
	note_off_threshold_option.value = options.options.note_recognition.note_off_threshold
	octave_removal_option.value = options.options.note_recognition.octave_removal_multiplier
	minimum_length_option.value = options.options.note_recognition.minimum_length
	volume_multiplier_option.value = options.options.note_recognition.volume_multiplier
	percussion_removal_option.value = options.options.note_recognition.percussion_removal

func read_in_fft_options():
	#this will be called from spectrum_analyzer, to
	#make sure that it calculates with these options
	options.options.fft.use_2_ffts = two_ffts_option.pressed
	options.options.fft.fft_size_low = fft_size_low_option.value
	options.options.fft.low_high_exponent_low = low_high_exponent_low_option.value
	options.options.fft.overamplification_multiplier_low = overamplification_low_option.value
	options.options.fft.fft_size_high = fft_size_high_option.value
	options.options.fft.low_high_exponent_high = low_high_exponent_high_option.value
	options.options.fft.overamplification_multiplier_high = overamplification_high_option.value
	options.options.fft.hop_size = hop_size_option.value
	options.options.fft.subdivision = subdivision_option.value
	options.options.fft.tuning = tuning_option.value

func read_in_note_recognition_options():
	options.options.note_recognition.note_on_threshold = note_on_threshold_option.value
	options.options.note_recognition.note_off_threshold = note_off_threshold_option.value
	options.options.note_recognition.octave_removal_multiplier = octave_removal_option.value
	options.options.note_recognition.minimum_length = minimum_length_option.value
	options.options.note_recognition.volume_multiplier = volume_multiplier_option.value
	options.options.note_recognition.percussion_removal = percussion_removal_option.value

func _on_two_ffts_option_toggled(button_pressed):
	fft_size_high_option.editable = button_pressed
	low_high_exponent_high_option.editable = button_pressed
	overamplification_high_option.editable = button_pressed

func _on_recalculate_fft_pressed():
	if options.options.misc.file_path != "":
		graph_scroll_container.calculate_new_spectrum_sprites()

func _on_recalculate_notes_pressed():
	if options.options.misc.file_path != "":
		graph_scroll_container.calculate_new_notes()

func _on_recalculate_both_pressed():
	if options.options.misc.file_path != "":
		graph_scroll_container.calculate_new_spectrum_sprites()
		graph_scroll_container.calculate_new_notes()
