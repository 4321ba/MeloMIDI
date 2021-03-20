extends TextureRect
class_name SpectrumTexture
#this node and script manage the creation of one image

var height: int
var data: PoolRealArray

func pool_real_array_max(array: PoolRealArray) -> float:
	var maximum: float
	for i in array:
		if i > maximum:
			maximum = i
	return maximum

func _ready():
	var width: int = data.size() / height
	print("Creating image with %s pixels, it is %s high and %s wide" % [data.size(), height, width])
	var maximum: float = pool_real_array_max(data)
	
	var image: Image = Image.new()
	image.create(width, height, false, Image.FORMAT_RGBA8)
	image.lock()
	for x in width:
		for y in height:
			image.set_pixel(x, height-y-1, Color.from_hsv(data[x*height+y] / maximum, 1, 1))
	image.unlock()
	var image_texture: ImageTexture = ImageTexture.new()
	image_texture.create_from_image(image)
	texture = image_texture
	
#	alternatively, but it doesn't work yet:
#	var image_data: PoolByteArray = PoolByteArray()
#	for y in height:
#		for x in width:
#			var color: Color = Color.from_hsv(data[x*height+y] / maximum, 1, 1)
#			image_data.append(color.r)
#			image_data.append(color.g)
#			image_data.append(color.b)
#	var image: Image = Image.new()
#	image.create_from_data(width, height, false, Image.FORMAT_RGB8, image_data)
#	var image_texture: ImageTexture = ImageTexture.new()
#	image_texture.create_from_image(image)
#	texture = image_texture
