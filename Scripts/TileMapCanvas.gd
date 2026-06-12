extends Control


const SpriteStart = 0x4B32
const SpriteSize = 32
const mapHeight = 24
const mapWidth = 30
var grid_size = 8
var sprite_data = []
var current_color_index = 1
const pixel_size: int = 8
var history = []
var history_index = -1

var VersionCount = 0

var SpriteIndex: int = 1
var MapIndex: int = 0
var loadingIndexInputted: bool = false

var isIndexSubmitted: bool
var isNameSubmitted: bool
var isOnSprite: bool = false

var spriteName: String
var loadingIndex: int
var loadingPath: String
var currentSpriteID: int
@export var NamingPopup: Control
@export var LoadingPopup: Control
@export var SpriteChooserPopup: Control

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
	sprite_data.resize(mapHeight * mapWidth)
	sprite_data.fill(0) 

func _gui_input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_paint_pixel(event.position)
			print("Mouse Pos: ", event.position)

func _paint_pixel(mouse_pos: Vector2):
	var cell_size_x = size.x / mapWidth
	var cell_size_y = size.y / mapHeight
	var pixelSize = cell_size_x/8
	var x = int(mouse_pos.x / cell_size_x)
	var y = int(mouse_pos.y / cell_size_y)
	
	if x >= 0 and x < mapWidth and y >= 0 and y < mapHeight:
			var index = (y * mapWidth) + x  
			if sprite_data[index] != currentSpriteID:
				sprite_data[index] = currentSpriteID
				VersionCount += 1
				queue_redraw()

func _draw():
	var cell_size = size.x / mapWidth
	var cell_size_y = size.y / mapHeight
	var visual_pixel_size = cell_size / 8.0 
	print("Canvas Size", size)
	for i in range(sprite_data.size()):
		var x = i % mapWidth
		var y = int(i / mapWidth)
		var current_sprite_id = sprite_data[i]
		
		if current_sprite_id != 0:
			draw_sprite(current_sprite_id, x * cell_size, y * cell_size_y, visual_pixel_size)



func _on_save_pressed() -> void:
	NamingPopup.visible = true
	pass


func get_sprite_as_buffer() -> PackedByteArray:
	var buffer = PackedByteArray()
	buffer.resize(32) 
	for i in range(32):
		var pixel_left = sprite_data[i * 2]      
		var pixel_right = sprite_data[i * 2 + 1]  
		var packed_byte = (pixel_left << 4) | (pixel_right & 0x0F)
		buffer[i] = packed_byte
	NamingPopup.visible = false
	return buffer
	
	
func load_sprite_from_buffer(buffer: PackedByteArray) -> void:
	for i in range(32):
		var pixel_right = buffer[i] & 0x0F
		var pixel_left = (buffer[i] >> 4) & 0x0F
		sprite_data[i * 2] = pixel_left
		sprite_data[i * 2 + 1] = pixel_right
	queue_redraw()






func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	pass 



func _on_line_edit_text_submitted(new_text: String) -> void:
	spriteName = new_text

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
	#var packedSprite = get_sprite_as_buffer()
	#var start = SpriteIndex * 32
	#NamingPopup.visible = false
	SaveMapToRam(MapIndex, 0x7000)
	pass


func _on_sprite_index_text_changed(new_text: String) -> void:
	MapIndex = new_text.to_int()
	pass


func _on_cartridge_pressed() -> void:
	get_tree().change_scene_to_file("res://CartridgeSave.tscn")
	pass


func _on_load_pressed() -> void:
	LoadingPopup.visible = true
	pass 


func _on_loading_index_line_text_submitted(new_text: String) -> void:
	loadingIndex = new_text.to_int()
	loadMapFromRam(loadingIndex, 0x7000)
	pass 


func _on_file_dialog_file_selected(path: String) -> void:
	loadingPath = path
	if isIndexSubmitted:
		var file = FileAccess.open(loadingPath, FileAccess.READ)
		var fileLoadedSprite = file.get_buffer(32)
		load_sprite_from_buffer(fileLoadedSprite)
		file.close()
	pass


func _on_clear_pressed() -> void:
	sprite_data.resize(mapHeight * mapWidth)
	sprite_data.fill(0)
	queue_redraw()
	var start = MapIndex * 720
	for i in range(720):
		Globals.ram[start + i + 0x7000] = 0
	pass
	
	
func _add_to_history(current_version: PackedByteArray):
	if history_index < history.size() - 1:
		history = history.slice(0, history_index + 1)
	
	history.append(current_version)
	history_index += 1


func _on_loading_line_edit_text_submitted(new_text: String) -> void:
	var index = new_text.to_int()
	var start = 0x7000
	loadMapFromRam(index, start)
	LoadingPopup.visible = false
	pass


func _on_choose_sprite_pressed() -> void:
	SpriteChooserPopup.visible = true
	pass


func _on_sprite_index_sprite_chooser_text_submitted(new_text: String) -> void:
	currentSpriteID = new_text.to_int()
	SpriteChooserPopup.visible = false
	pass
	
	
func draw_sprite(index: int, start_x: float, start_y: float, p_size: float) -> void:
	var base_addr = SpriteStart + (index * SpriteSize)
	for i in range(64):
		var sx = i % 8
		var sy = i / 8
		
		var byte_offset = i / 2
		var current_byte = Globals.ram[base_addr + byte_offset]
		var color_idx: int

		if i % 2 == 0:
			color_idx = current_byte >> 4     
		else:
			color_idx = current_byte & 0x0F   
			
		if color_idx != 0:
			var final_x = start_x + (sx * p_size)
			var final_y = start_y + (sy * p_size)
			var rect = Rect2(final_x, final_y, p_size, p_size)
			draw_rect(rect, palette[color_idx])
			
			
func SaveMapToRam(MapIndex: int, MapStart: int):
	var mapIndex = MapStart + (MapIndex * 720)
	for i in 720:
		Globals.ram[i + mapIndex] = sprite_data[i]
	pass

func loadMapFromRam(MapIndex: int, MapStart):
	var mapIndex = MapStart + (MapIndex * 720)
	for i in 720:
		sprite_data[i] = Globals.ram[i+mapIndex]
	queue_redraw()
	pass


func _on_tile_map_save_text_changed(new_text: String) -> void:
	MapIndex = new_text.to_int()
	pass


func _on_tile_map_save_text_submitted(new_text: String) -> void:
	SaveMapToRam(MapIndex, 0x7000)
	NamingPopup.visible = false
	Globals.isOnTileMap = true
	pass
