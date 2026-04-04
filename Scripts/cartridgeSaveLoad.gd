extends Node2D
var catridgeData: PackedByteArray
var targetDir: String
var cartridgeName: String
var footer: PackedByteArray
var loadingDir: String
@export var Naming: Control
@export var errorDia: Control
@export var SaveDia: FileDialog
@export var loadDia: FileDialog
@export var loading: Control


var isReadyToSave: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	footer.resize(4)
	footer.encode_u32(0, Globals.spriteData.size())
	isReadyToSave = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_pressed() -> void:
	var dupRam = Globals.ram.duplicate()
	dupRam.append_array(Globals.spriteData)
	dupRam.append_array(footer)
	catridgeData = dupRam
	Naming.visible = true
	SaveDia.popup_centered()
	pass

func _on_load_pressed() -> void:
	loadDia.visible = true
	
	pass


func save_cartridge() -> void:
	if !targetDir.is_empty() && !cartridgeName.is_empty():
		var img = Image.create(140, 180, false, Image.FORMAT_RGBA8)
		img.load("res://cartridge.png")
		var path = targetDir+"/"+cartridgeName+".png"
		print("Attempting to save to: ", ProjectSettings.globalize_path(path))
		img.save_png(path)
		var file = FileAccess.open(path, FileAccess.READ_WRITE)
		if file:
			file.seek_end()
			file.store_buffer(catridgeData)
			file.close()
			Naming.visible = false
		else:
			errorDia.visible = true
	else:
		errorDia.visible = true
	


func _on_file_dialog_dir_selected(dir: String) -> void:
	targetDir = dir
	pass


func _on_line_edit_text_submitted(new_text: String) -> void:
	cartridgeName = new_text
	if isReadyToSave:
		save_cartridge()
	pass


func _on_file_dialog_confirmed() -> void:
	isReadyToSave = true
	pass

#Opening a cartridge
func _on_file_dialog_file_selected(path: String) -> void:
	loadingDir = path
	var file = FileAccess.open(path, FileAccess.READ)
	#file.seek_end(-4)
	#var footer = file.get_buffer(4)
	#var sprite_size = footer.decode_u32(0)
	file.seek_end(-(Globals.ram.size()))
	var newRam = file.get_buffer(Globals.ram.size())
	Globals.ram = newRam
	#var newSpriteData = file.get_buffer(sprite_size)
	#Globals.spriteData = newSpriteData
	pass 
