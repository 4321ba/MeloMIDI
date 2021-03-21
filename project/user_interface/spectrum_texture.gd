extends Sprite
class_name SpectrumTexture
#this node and script manage the creation of one image
#with large pieces multiple ones are needed, because of the <16384px limit

var width: int
var data: PoolRealArray

func _ready():
	var height: int = data.size() / width
	print("Creating image with %s pixels, it is %s high and %s wide" % [data.size(), height, width])
	
	var image_data: PoolByteArray = PoolByteArray()
	for y in height:
		for x in width:
			var weight: float = data[x * height + y]
			var color: Color = Color.from_hsv(weight, 1, 1)
			image_data.append(color.r8)
			image_data.append(color.g8)
			image_data.append(color.b8)
			image_data.append(color.a8)
	var image: Image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGBA8, image_data)
	#we want low pitch to be down and high pitch to be up
	image.flip_y()
	
	var image_texture: ImageTexture = ImageTexture.new()
	image_texture.create_from_image(image)
	texture = image_texture
