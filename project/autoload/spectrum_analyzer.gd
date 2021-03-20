extends Node

var sample_rate: int
var native_library: Object = preload("res://bin/spectrum_analyzer.gdns").new()
const spectrum_texture_scene: PackedScene = preload("res://user_interface/spectrum_texture.tscn")

func analyze_spectrum(filename: String, fft_size: int = 16384, hop_size: int = 1024) -> SpectrumTexture:
	var magnitudes: PoolRealArray = native_library.analyze_spectrum(filename, fft_size, hop_size)
	sample_rate = magnitudes[-2]
	var height: int = magnitudes[-1]
	magnitudes.resize(magnitudes.size() - 2)
	
	var spectrum_texture: SpectrumTexture = spectrum_texture_scene.instance()
	spectrum_texture.data = magnitudes
	spectrum_texture.height = height
	return spectrum_texture
