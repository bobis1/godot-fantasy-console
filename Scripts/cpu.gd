extends Node


var registers = [0, 0, 0, 0, 0, 0, 0, 0]
var pc = 0
var isStopped: bool
var isRunning: bool

enum {
	STOP,
	MOV_R_V,
	MOV_R_R,
	WRITE, #WRITE to ram
	LOAD, # Get value from ram
	ADD, #Adds two registers
	SUB, #
	JMP,
	SPR
}

var instruction = PackedByteArray([0, 0, 0, 0])

var AssemblyFile
var AssemblyFileName: String
@export var hardware: Script

func _ready() -> void:
	AssemblyFile = FileAccess.get_file_as_string("user://" + AssemblyFileName)
	isStopped = false

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
	isRunning = true
	Globals.ram[pc]
	var opcode = Globals.ram[pc]
	match opcode:
		MOV_R_V:
			registers[Globals.ram[pc + 1]] = Globals.ram[pc + 2]
			pc += 3
		STOP:
			isStopped = true
			pc += 1
		MOV_R_R:
			registers[Globals.ram[pc + 1]] = registers[Globals.ram[pc + 2]]
			pc += 3
		WRITE:
			Globals.ram[pc + 1] = Globals.ram[pc + 2]
			pc += 4
		ADD:
			Globals.ram[pc + 1] += Globals.ram[pc + 2]
			pc += 3
		SUB:
			Globals.ram[pc + 1] = Globals.ram[pc + 1] - Globals.ram[pc + 2]
			pc += 5
		JMP:
			pc = (Globals.ram[pc + 1] * 256) + Globals.ram[pc + 2]
		SPR:
			spr(Globals.ram[pc + 1], Globals.ram[pc + 2], Globals.ram[pc + 3], Globals.ram[pc + 4], Globals.ram[pc + 5])
			pc += 6
	isRunning = false

func _process(delta: float) -> void:
	if !isStopped && !isRunning:
		run_cpu()


func compile(source_code: String) -> PackedByteArray:
	var bytecode = PackedByteArray()
	var lines = source_code.split("\n")

	for line in lines:
		line = line.strip_edges()
		if line == "" or line.begins_with(";"): continue 
		var tokens = line.replace(",", " ").split(" ", false)
		var command = tokens[0].to_upper()
		match command:
			"MOV_R_V":
				bytecode.append(MOV_R_V)
				bytecode.append(tokens[1].replace("R", "").to_int() )
				bytecode.append(tokens[2].to_int())
			"STOP":
				bytecode.append(STOP)
			"MOV_R_R":
				bytecode.append(MOV_R_R)
				bytecode.append(tokens[1].replace("R", "").to_int())
				bytecode.append(tokens[2].replace("R", "").to_int())
			"WRITE":
				bytecode.append(WRITE)
				bytecode.append(tokens[1].to_int() / 256)
				bytecode.append(tokens[1].to_int() % 256)
				bytecode.append(tokens[2].to_int())
			"ADD":
				bytecode.append(ADD)
				bytecode.append(tokens[1].replace("R", "").to_int())
				bytecode.append(tokens[2].replace("R", "").to_int())
			"SUB":
				bytecode.append(SUB)
				bytecode.append(tokens[1].to_int() / 256)
				bytecode.append(tokens[2].to_int() % 256)
				bytecode.append(tokens[3].to_int() / 256)
				bytecode.append(tokens[4].to_int() % 256)
			"JMP":
				bytecode.append(JMP)
				bytecode.append(tokens[1].to_int() / 256)
				bytecode.append(tokens[2].to_int() % 256)
			"SPR":
				bytecode.append(SPR)
				bytecode.append(tokens[1].to_int())
				bytecode.append(tokens[2].to_int())
				bytecode.append(tokens[3].to_int())
				bytecode.append(tokens[4].to_int())
				bytecode.append(tokens[5].to_int())
	return bytecode
