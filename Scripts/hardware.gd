extends Node

@export var Screen: TextureRect
@export var CPU: Node
const VramStart = 0x000
const VramEnd = 0x4B00
const PalleteStart = 0x4B01
const InputAddr = 0x4B31
const SpriteStart = 0x4B32
const InstructionStart = 0x5000
const SpriteSize = 32

var Input_byte
var img: Image
var texture: ImageTexture

var player_x = 120
var player_y = 65

var wrapping_enabled: bool = true

var dir = DirAccess.open("user://")




func _ready() -> void:
	if !Globals.IsRamInit:
			Globals.ram.resize(65536)
			Globals.ram.fill(0)
			Globals.IsRamInit = true
			SetDefaultPallete()
	img = Image.create(240, 160, false, Image.FORMAT_RGB8)
	texture = ImageTexture.create_from_image(img)
	Screen.texture = texture
	print("Screen value: ", Screen)
	print("Screen is null: ", Screen == null)
	draw_test_pattern()
	Input_byte = Globals.ram[InputAddr]
	Globals.pc = InstructionStart
	if dir == null: print("Could not open folder"); return
	dir.list_dir_begin()
	load_sprite_from_file("user://1save_sprite.dat", 1)
	load_sprite_from_file("user://hello.dat", 2)












# VRAM/Rendering
func SetDefaultPallete() -> void:
	#Think about color pallete later aswell
	var colors = [
		[0, 0, 0],
		[255, 0, 0],
		[0, 255, 0],
		[0, 0, 255],
		[150,0,150],
		[230,201,137], #Yellow
		[160,80,60], #Brown
		[255, 204, 170], # peach
		[131, 118, 156], # Lavender
		[194, 195, 199], # light gray
		[104, 105, 109], #Dark gray
		[29, 43, 83], # dark blue
		[126, 37, 83], # Dark Purple
		[168,231,46], # Lime Green
		[117,70,101], #Mauve
		[18,83,89] # Blue-Green
	]
	for i in colors.size():
		var base_address = PalleteStart + (i * 3)
		Globals.ram[base_address] = colors[i][0]
		Globals.ram[base_address + 1] = colors[i][1]
		Globals.ram[base_address + 2] = colors[i][2]
	
	pass
	
func WritePixel(x: int, y: int, ColorIndex: int) -> void:
	if(wrapping_enabled):
		x = x % 240
		y = y % 160
	var pixel_index = y * 240 + x
	var byte_index = pixel_index / 2
	var current_byte = Globals.ram[byte_index]
	
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
	Globals.ram[byte_index] = current_byte
	
	pass


func update_display():
	for i in range(19200):
		var current_byte = Globals.ram[VramStart + i]

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
	texture.update(img)



func _process(delta: float) -> void:
	update_display()
	CheckInput()
	#if Input_byte & 0x01: player_y -= 1 # UP (Bit 0)
	#if Input_byte & 0x02: player_y += 1 # DOWN (Bit 1)
	#if Input_byte & 0x04: player_x -= 1 # LEFT (Bit 2)
	#if Input_byte & 0x08: player_x += 1 # RIGHT (Bit 3)
	draw_test_pattern()
#
	#draw_sprite(1, player_x, player_y)
	#draw_sprite(2, 120, 120)
	#draw_sprite(1, 200, 200)
	#draw_sprite(3, 120,120)
	CPU.run_cpu()
	update_display()
	if !Globals.isLoaded:
		for file: String in dir.get_files():
			var resource = dir.get_current_dir() + "/" + file
			var sprite_index = file.to_int()
			if Globals.wantCleared:
				dir.remove(resource)
				print(resource + "Removed")
				pass
			load_sprite_from_file(resource, sprite_index)
			print(resource)
			Globals.isLoaded = true


	if(Input.is_key_pressed(KEY_R)): get_tree().change_scene_to_file("res://Editor.tscn")
	pass
	#draw_test_pattern()
	#Globals.ram[0] = 0x11
	#update_display()

func CheckInput():
	if Input.is_action_pressed("UP"):
		Globals.ram[InputAddr] = 1
	elif Input.is_action_pressed("DOWN"):
		Globals.ram[InputAddr] = 2
	elif Input.is_action_pressed("LEFT"):
		Globals.ram[InputAddr] = 3
	elif Input.is_action_pressed("RIGHT"):
		Globals.ram[InputAddr] = 4
	elif Input.is_action_pressed("A"):
		Globals.ram[InputAddr] = 5
	elif Input.is_action_pressed("B"):
		Globals.ram[InputAddr] = 6
	else:
		Globals.ram[InputAddr] = 0

func get_color_from_ram(ColorIndex: int) -> Color:
	var base = PalleteStart + (ColorIndex * 3)
	var red = Globals.ram[base] /255.0
	var green = Globals.ram[base + 1] / 255.0
	var blue = Globals.ram[base + 2] / 255.0
	return Color(red,green,blue)
	
	
func draw_sprite(index: int, screen_x: int, screen_y: int) -> void:
	var base_addr = SpriteStart + (index * SpriteSize)
	for i in range(64):
		var sx = i % 8
		var sy = i / 8
		
		# Each byte has 2 pixels, find the right one
		var byte_offset = i / 2
		var current_byte = Globals.ram[base_addr + byte_offset]
		var color_idx: int
		
		if i % 2 == 0:
			color_idx = current_byte >> 4      # Get top 4 bits
		else:
			color_idx = current_byte & 0x0F    # Get bottom 4 bits
			
		# Treat Color 0 as "Transparent" so sprites aren't just solid blocks
		if color_idx != 0:
			WritePixel(screen_x + sx, screen_y + sy, color_idx)
	
	
	
	
func fill_rect(x: int, y: int, width: int, height: int, color_index: int) -> void:
	for i in range(y, y + height):
		for j in range(x, x + width):
			WritePixel(j, i, color_index)

func draw_test_pattern() -> void:
	# 1. Clear screen to Dark Blue (Index 11)
	fill_rect(0, 0, 240, 160, 11)
	
	# 2. Draw a Red border (Index 1)
	for x in range(240):
		WritePixel(x, 0, 1)   # Top
		WritePixel(x, 159, 1) # Bottom
	for y in range(160):
		WritePixel(0, y, 1)   # Left
		WritePixel(239, y, 1) # Right
		
	fill_rect(20, 20, 40, 40, 2)  # Green Square
	fill_rect(70, 20, 40, 40, 3)  # Blue Square
	fill_rect(120, 20, 40, 40, 5) # Yellow Square
	fill_rect(170, 20, 40, 40, 6) # Brown Square


func load_sprite_from_file(file_path: String, sprite_index: int):
	if FileAccess.file_exists(file_path):
		var buffer = FileAccess.get_file_as_bytes(file_path)
		var start_address = SpriteStart + (sprite_index * SpriteSize)
		for i in range(32):
			Globals.ram[start_address + i] = buffer[i]
