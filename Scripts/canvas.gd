extends Control

var grid_size = 8
var sprite_data = []
var current_color_index = 1

var history = []
var history_index = -1

var VersionCount = 0

var SpriteIndex: int
var loadingIndexInputted: bool = false

var isIndexSubmitted: bool
var isNameSubmitted: bool

var spriteName: String
var loadingIndex: int
var loadingPath: String
@export var NamingPopup: Control
@export var LoadingFileDialouge: FileDialog
@export var LoadingPopup: Control

var palette = [
	Color8(0, 0, 0, 0),
	Color8(255, 0, 0),       # 1: Red
	Color8(0, 255, 0),       # 2: Green
	Color8(0, 0, 255),       # 3: Blue
	Color8(150, 0, 150),     # 4: Purple
	Color8(230, 201, 137),   # 5: Yellow
	Color8(160, 80, 60),     # 6: Brown
	Color8(255, 204, 170),   # 7: Peach
	Color8(131, 118, 156),   # 8: Lavender
	Color8(194, 195, 199),   # 9: Light gray
	Color8(104, 105, 109),   # 10: Dark Gray
	Color8(29, 43, 83),      # 11: Dark blue
	Color8(126, 37, 83),     # 12: Dark Purple
	Color8(168, 231, 46),    # 13: Lime Green
	Color8(117, 70, 101),    # 14: Mauve
	Color8(18, 83, 89)       # 15: Blue-Green
]

func _ready():
	sprite_data.resize(grid_size * grid_size)
	sprite_data.fill(0) 

func _gui_input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_paint_pixel(event.position)

func _paint_pixel(mouse_pos: Vector2):
	var cell_size = size.x / grid_size
	
	var x = int(mouse_pos.x / cell_size)
	var y = int(mouse_pos.y / cell_size)
	
	if x >= 0 and x < grid_size and y >= 0 and y < grid_size:
		var index = (y * grid_size) + x
		
		if sprite_data[index] != current_color_index:
			sprite_data[index] = current_color_index
			VersionCount += 1
			#var file = FileAccess.open("user://Versions" + spriteName + str(VersionCount) +".dat", FileAccess.WRITE)
			#file.store_buffer(get_sprite_as_buffer())
			queue_redraw()
			_add_to_history(get_sprite_as_buffer())

func _draw():
	var cell_size = size.x / grid_size
	
	for i in range(sprite_data.size()):
		var x = i % grid_size
		var y = int(i / grid_size)
		
		var memory_value = sprite_data[i]
		var actual_color = palette[memory_value]
		
		var rect = Rect2(Vector2(x, y) * cell_size, Vector2(cell_size, cell_size))
		draw_rect(rect, actual_color)







func _on_black_pressed() -> void:
	current_color_index = 0
	pass 


func _on_red_pressed() -> void:
	current_color_index = 1
	pass 


func _on_green_pressed() -> void:
	current_color_index = 2
	pass 


func _on_blue_pressed() -> void:
	current_color_index = 3
	pass 


func _on_purple_pressed() -> void:
	current_color_index = 4
	pass 

func _on_yellow_pressed() -> void:
	current_color_index = 5
	pass


func _on_brown_pressed() -> void:
	current_color_index = 6
	pass


func _on_peach_pressed() -> void:
	current_color_index = 7
	pass 



func _on_lavender_pressed() -> void:
	current_color_index = 8
	pass


func _on_light_gray_pressed() -> void:
	current_color_index = 9
	pass


func _on_dark_gray_pressed() -> void:
	current_color_index = 10
	pass



func _on_dark_blue_pressed() -> void:
	current_color_index = 11
	pass


func _on_dark_purple_pressed() -> void:
	current_color_index = 12
	pass



func _on_lime_green_pressed() -> void:
	current_color_index = 13
	pass 


func _on_mauve_pressed() -> void:
	current_color_index = 14
	pass


func _on_teal_pressed() -> void:
	current_color_index = 15
	pass 


func _on_save_pressed() -> void:
	save_to_file()
	pass


func get_sprite_as_buffer() -> PackedByteArray:
	var buffer = PackedByteArray()
	buffer.resize(32) 
	for i in range(32):
		var pixel_left = sprite_data[i * 2]      
		var pixel_right = sprite_data[i * 2 + 1]  
		var packed_byte = (pixel_left << 4) | (pixel_right & 0x0F)
		buffer[i] = packed_byte
		
	return buffer
	
	
func load_sprite_from_buffer(buffer: PackedByteArray) -> void:
	for i in range(32):
		var pixel_right = buffer[i] & 0x0F
		var pixel_left = (buffer[i] >> 4) & 0x0F
		sprite_data[i * 2] = pixel_left
		sprite_data[i * 2 + 1] = pixel_right
	queue_redraw()


func save_to_file():
	NamingPopup.visible = true




func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	pass 



func _on_line_edit_text_submitted(new_text: String) -> void:
	spriteName = new_text
	#var file = FileAccess.open("user://"+ str(SpriteIndex) +spriteName+".dat", FileAccess.WRITE)
	#file.store_buffer(get_sprite_as_buffer())
	#sprite_data.append_array(get_sprite_as_buffer())
	#Globals.isLoaded = false
	#isNameSubmitted = true
	#if isIndexSubmitted && isNameSubmitted:
			#NamingPopup.visible = false
	var packedSprite = get_sprite_as_buffer()
	var start = SpriteIndex * 32
	for i in range(32):
		Globals.ram[start + 0x4B32 + i] = packedSprite[i]

	pass



func _on_scripting_pressed() -> void:
	get_tree().change_scene_to_file("res://Scripting.tscn")
	pass




func _on_undo_pressed() -> void:
	if history_index > 0:
		history_index -= 1
		load_sprite_from_buffer(history[history_index])
	pass


func _on_redo_pressed() -> void:
	if history_index < history.size() - 1:
		history_index += 1
		load_sprite_from_buffer(history[history_index])
	pass


func _on_sprite_index_text_submitted() -> void:
	if isIndexSubmitted && isNameSubmitted:
		NamingPopup.visible = false
	pass


func _on_sprite_index_text_changed(new_text: String) -> void:
	SpriteIndex = new_text.to_int()
	isIndexSubmitted = true
	pass


func _on_cartridge_pressed() -> void:
	get_tree().change_scene_to_file("res://CartridgeSave.tscn")
	pass


func _on_load_pressed() -> void:
	LoadingPopup.visible = true
	LoadingFileDialouge.popup_centered()
	pass 


func _on_loading_index_line_text_submitted(new_text: String) -> void:
	loadingIndex = new_text.to_int()
	load_sprite_from_buffer(Globals.ram.slice(loadingIndex*32, (loadingIndex*32)+32))
	isIndexSubmitted = true
	pass 


func _on_file_dialog_file_selected(path: String) -> void:
	loadingPath = path
	if isIndexSubmitted:
		var file = FileAccess.open(loadingPath, FileAccess.READ)
		var fileLoadedSprite = file.get_buffer(32)
		load_sprite_from_buffer(fileLoadedSprite)
		file.close()
	pass


func _on_loadfrom_file_pressed() -> void:
	pass


func _on_clear_pressed() -> void:
	sprite_data.resize(grid_size * grid_size)
	sprite_data.fill(0)
	queue_redraw()
	var start = SpriteIndex * 32
	for i in range(32):
		Globals.ram[start + i + 0x4B32] = 0
	pass
	
	
func _add_to_history(current_version: PackedByteArray):
	if history_index < history.size() - 1:
		history = history.slice(0, history_index + 1)
	
	history.append(current_version)
	history_index += 1
