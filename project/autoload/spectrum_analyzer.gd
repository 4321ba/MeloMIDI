extends Node

var fft_size: int = 16384
var hop_size: int = 1024
var subdivision: int = 9
var tuning: float = 440

var sample_rate: int
var texture_size: Vector2

var native_library = preload("res://bin/spectrum_analyzer.gdns").new()

func analyze_spectrum(filename: String) -> Array:
	var return_array: Array = native_library.analyze_spectrum(filename, fft_size, hop_size, subdivision, tuning)
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
