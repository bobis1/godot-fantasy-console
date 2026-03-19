extends Node

var AssemblyFile
var AssemblyFileName: String
@export var hardware: Script

func _ready() -> void:
	AssemblyFile = FileAccess.get_file_as_string("user://" + AssemblyFileName)

func peek(addr: int):
	if addr > 0 && addr < Globals.ram.size():
		return Globals.ram[addr]
	return 0
	
func write(addr: int, value: int):
	if addr > 0 && addr < Globals.ram.size():
		Globals.ram[addr] = value

func spr(spriteIndex: int, x: int, y: int, w: int = 1, h: int = 1):
	for y_off in range(h):
		for x_off in range(w):
			var current_sprite = spriteIndex + x_off + (y_off * 16)
			hardware.draw_sprite(current_sprite, x + (x_off * 8), y + (y_off * 8))
