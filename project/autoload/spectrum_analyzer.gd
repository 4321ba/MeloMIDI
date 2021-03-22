extends Node

var sample_rate: int
var fft_size: int = 16384
var hop_size: int = 1024
var subdivision: int = 9
var texture_size: Vector2

const spectrum_texture_scene: PackedScene = preload("res://user_interface/spectrum_texture.tscn")
var native_library = preload("res://bin/spectrum_analyzer.gdns").new()

func pool_real_array_max(array: PoolRealArray) -> float:
	var maximum: float
	for i in array:
		if i > maximum:
			maximum = i
	return maximum

func analyze_spectrum(filename: String) -> SpectrumTexture:
	var magnitudes: PoolRealArray = native_library.analyze_spectrum(filename, fft_size, hop_size)
	sample_rate = magnitudes[-2]
	#This is the height of the output image:
	var frequency_limit_count: int = magnitudes[-1]
	magnitudes.resize(magnitudes.size() - 2)
	var width: int = magnitudes.size() / frequency_limit_count
	
	#we need to convert the data from frequencies spread linearly
	#to frequencies spread exponentially
	var converted_magnitudes: PoolRealArray = PoolRealArray()
	for x in width:
		for note in 128:
			#midi note 69 is 440hz, and every +12 midi note is *2 in frequency
			var note_frequency: float = 440 * pow(2, (note - 69) / 12.0)
			for sub in range(ceil(-subdivision / 2.0), ceil(subdivision / 2.0)):
				var frequency: float = note_frequency * pow(2, sub / 12.0 / subdivision)
				var from_frequency: float = frequency / pow(2, 1 / 24.0 / subdivision)
				var to_frequency: float = frequency * pow(2, 1 / 24.0 / subdivision)
				var begin_count: int = ceil(from_frequency * fft_size / sample_rate)
				var end_count: int = ceil(to_frequency * fft_size / sample_rate)
				
				var sum: float
				if begin_count == end_count:
					#for low notes we lerp between the 2 closest values
					begin_count -= 1
					var begin_frequency: float = begin_count * sample_rate / float(fft_size)
					var end_frequency: float = end_count * sample_rate / float(fft_size)
					var ratio: float = inverse_lerp(begin_frequency, end_frequency, frequency)
					sum = lerp(magnitudes[x * frequency_limit_count + begin_count], magnitudes[x * frequency_limit_count + end_count], ratio)
				else:
					#for high notes we add all the in-range values together
					for i in range(begin_count, end_count):
						sum += magnitudes[x * frequency_limit_count + i]
				
				var count: int = end_count - begin_count
				#compensation, because we can only add whole numbers so
				#we need to smooth the border between where 1 and where 2 or more are added
				#and also magnitudes are probably 2* as loud 1 octave lower
				#because there are /2 less samples/frequencies analyzed
				#compensation seemed too strong so I sqrt'd it
				sum *= sqrt(frequency / 110) / count
				converted_magnitudes.append(sum)
	
	var maximum: float = pool_real_array_max(converted_magnitudes)
	var normalized_magnitudes: PoolRealArray = PoolRealArray()
	for i in converted_magnitudes:
		normalized_magnitudes.append(i / maximum)
	
	texture_size = Vector2(width, normalized_magnitudes.size() / width)
	var spectrum_texture: SpectrumTexture = spectrum_texture_scene.instance()
	spectrum_texture.data = normalized_magnitudes
	spectrum_texture.width = width
	return spectrum_texture
