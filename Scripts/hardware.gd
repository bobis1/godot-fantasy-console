extends Node

var ram = PackedByteArray()
var texture
@export var Screen: TextureRect

const VramStart = 0x000
const VramEnd = 0x4B00
const PalleteStart = 0x4B01
const InputAddr = 0x4B31

func _ready() -> void:
	ram.resize(65536)
	ram.fill(0)
	SetDefaultPallete()
	
func SetDefaultPallete() -> void:
	#Think about color pallete later aswell
	var colors = [
		[0, 0, 0],
		[255, 0, 0],     
		[0, 255, 0],     
		[0, 0, 255],     
		[150,150,0],
		[230,201,137], #Yellow
		[160,80,60], #Brown
		[255, 204, 170], # peach
		[131, 118, 156], # Lavender
		[194, 195, 199], # light gray
		[194, 195, 199], #Dark gray
		[29, 43, 83] # dark blue
	]
	for i in colors.size():
		var base_address = PalleteStart + (i * 3)
		ram[base_address] = colors[i][0]
		ram[base_address + 1] = colors[i][1]
		ram[base_address + 2] = colors[i][2]
	
	pass
	
func WritePixel(x: int, y: int, ColorIndex: int) -> void:
	var pixel_index = y * 240 + x
	var byte_index = pixel_index / 2
	var current_byte = ram[byte_index]
	
	if pixel_index % 2 == 0:
		#Left pixel 
		current_byte &= 0x0F
		var new_color = ColorIndex << 4
		current_byte |= new_color
	else:
		#Right Pixel
		ColorIndex &= 0x0F
		current_byte &= 0xF0
		var new_color = ColorIndex
		current_byte |= new_color
	ram[byte_index] = current_byte
	pass


func update_display():
	var img = Image.create(240, 160, false, Image.FORMAT_RGB8)
	
	for i in range(19200):
		var current_byte = ram[VramStart + i]
		
		
		var pixel_index_left = i * 2
		var pixel_index_right = (i * 2) + 1
		var color_idx_left =  current_byte >> 4
		
		var x_left = pixel_index_left % 240
		var y_left = pixel_index_left / 240
		img.set_pixel(x_left, y_left, get_color_from_ram(color_idx_left))

		current_byte &= 0x0F
		var color_idx_right = current_byte
		var x_right = pixel_index_right % 240
		var y_right = pixel_index_right / 240
		img.set_pixel(x_right, y_right, get_color_from_ram(color_idx_right))
	
	texture = ImageTexture.create_from_image(img)
	Screen.texture = texture



func _process(delta: float) -> void:
	update_display()
	pass


func get_color_from_ram(ColorIndex: int) -> Color:
	var base = PalleteStart + (ColorIndex * 3)
	var red = ram[base] /255.0
	var green = ram[base + 1] / 255.0
	var blue = ram[base + 2] / 255.0
	return Color(red,green,blue)
