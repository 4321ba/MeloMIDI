extends Node

#fft options
var use_2_ffts: bool = true
var fft_size_low: int = 16384
var low_high_exponent_low: float = 0.6
var overamplification_multiplier_low: float = 2
var fft_size_high: int = 4096
var low_high_exponent_high: float = 0.6
var overamplification_multiplier_high: float = 2
var hop_size: int = 1024
var subdivision: int = 9
var tuning: float = 440

#note guesser options
var note_on_threshold: float = 0.1
var note_off_threshold: float = 0.05
var octave_removal_multiplier: float = 0.2
var minimum_length: int = 4
var volume_multiplier: float = 4
var percussion_removal: float = 1

var sample_rate: int
var texture_size: Vector2

var file_path: String

var native_library = preload("res://bin/spectrum_analyzer.gdns").new()

func analyze_spectrum() -> Array:
	print("Loading audio file ", file_path)
	var file: File = File.new()
	file.open(file_path, File.READ)
	var bytes: PoolByteArray = file.get_buffer(file.get_len())
	var return_array: Array = native_library.analyze_spectrum(bytes, use_2_ffts, fft_size_low, low_high_exponent_low, overamplification_multiplier_low, fft_size_high, low_high_exponent_high, overamplification_multiplier_high, hop_size, subdivision, tuning)
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
	return native_library.guess_notes(note_on_threshold, note_off_threshold, octave_removal_multiplier, minimum_length, volume_multiplier, percussion_removal)
