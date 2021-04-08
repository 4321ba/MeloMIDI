extends Node

var sample_rate: int
var texture_size: Vector2

var native_library = preload("res://bin/spectrum_analyzer.gdns").new()

onready var conversion_options_dialog: WindowDialog = $"/root/main_window/conversion_options_dialog"

func analyze_spectrum() -> Array:
	conversion_options_dialog.read_in_fft_options()
	print("Loading audio file ", options.options.misc.file_path)
	var file: File = File.new()
	file.open(options.options.misc.file_path, File.READ)
	var bytes: PoolByteArray = file.get_buffer(file.get_len())
	var return_array: Array = native_library.analyze_spectrum(bytes, options.options.fft.use_2_ffts, options.options.fft.fft_size_low, options.options.fft.low_high_exponent_low, options.options.fft.overamplification_multiplier_low, options.options.fft.fft_size_high, options.options.fft.low_high_exponent_high, options.options.fft.overamplification_multiplier_high, options.options.fft.hop_size, options.options.fft.subdivision, options.options.fft.tuning)
	sample_rate = return_array[0]
	texture_size = Vector2(return_array[1], return_array[2])

	var images: Array = native_library.generate_images()
	var spectrum_sprites: Array
	for image in images:
		var image_texture: ImageTexture = ImageTexture.new()
		image_texture.create_from_image(image)
		var spectrum_sprite: Sprite = Sprite.new()
		spectrum_sprite.centered = false
		spectrum_sprite.texture = image_texture
		spectrum_sprites.append(spectrum_sprite)
	return spectrum_sprites

func get_guessed_notes() -> PoolIntArray:
	conversion_options_dialog.read_in_note_recognition_options()
	return native_library.guess_notes(options.options.note_recognition.note_on_threshold, options.options.note_recognition.note_off_threshold, options.options.note_recognition.octave_removal_multiplier, options.options.note_recognition.minimum_length, options.options.note_recognition.volume_multiplier, options.options.note_recognition.percussion_removal)
