extends Node


var registers = [0, 0, 0, 0, 0, 0, 0, 0]
var pc = 0

enum {
	STOP,
	MOV_R_V,
	MOV_R_R,
	WRITE,
	LOAD,
	ADD,
	SUB,
	JMP,
	SPR
}

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

func run_cpu():
	Globals.ram[pc]



func compile(source_code: String) -> PackedByteArray:
	var bytecode = PackedByteArray()
	var lines = source_code.split("\n")

	for line in lines:
		line = line.strip_edges()
		if line == "" or line.begins_with(";"): continue # Skip empty lines/comments

		var tokens = line.replace(",", " ").split(" ", false)
		var command = tokens[0].to_upper()

		
	return bytecode
