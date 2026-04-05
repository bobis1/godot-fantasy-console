extends Node


var registers = [0, 0, 0, 0, 0, 0, 0, 0]

enum {
	STOP,
	MOV_R_V,
	MOV_R_R,
	WRITE, #WRITE to ram
	LOAD, # Get value from ram
	ADD, #Adds two registers
	SUB, 
	JMP,
	SPR,
	IF,
	#SPRFromspriteData
}

var instruction = PackedByteArray([0, 0, 0, 0])

var AssemblyFile
var AssemblyFileName: String
@export var hardware: Node

func _ready() -> void:
	AssemblyFile = FileAccess.get_file_as_string("user://" + AssemblyFileName)
	Globals.isStopped = false

func peek(addr: int):
	if addr > 0 && addr < Globals.ram.size():
		return Globals.ram[addr]
	return 0
	
func write(addr: int, value: int):
	if addr > 0 && addr < Globals.ram.size():
		Globals.ram[addr] = value

func spr(spriteIndex: int, x: int, y: int):
	hardware.draw_sprite(spriteIndex, x, y)

func run_cpu():
	Globals.isStopped = false
	var cycles_this_frame = 0
	var max_cycles = 1000
	while !Globals.isStopped and cycles_this_frame < max_cycles:
		Globals.ram[Globals.pc]
		var opcode = Globals.ram[Globals.pc]
		#print("PC: ", Globals.pc, " Opcode: ", opcode)
		cycles_this_frame += 1
		match opcode:
			MOV_R_V:
				registers[Globals.ram[Globals.pc + 1]] = Globals.ram[Globals.pc + 2]
				Globals.pc += 3
			STOP:
				Globals.isStopped = true
				Globals.pc += 1
			MOV_R_R:
				registers[Globals.ram[Globals.pc + 1]] = registers[Globals.ram[Globals.pc + 2]]
				Globals.pc += 3
			WRITE:
				var addr = Globals.ram[Globals.pc + 1]
				Globals.ram[addr] = Globals.ram[Globals.pc + 2]
				Globals.pc += 4
			ADD:
				var addr = Globals.ram[Globals.pc + 1]
				Globals.ram[addr] += Globals.ram[Globals.pc + 2]
				Globals.pc += 3
			SUB:
				var addr = Globals.ram[Globals.pc + 1]
				Globals.ram[addr] = Globals.ram[Globals.pc + 1] - Globals.ram[Globals.pc + 2]
				Globals.pc += 3
			JMP:
				Globals.pc = (Globals.ram[Globals.pc + 1] * 256) + Globals.ram[Globals.pc + 2]
			SPR:
				spr(Globals.ram[Globals.pc + 1], Globals.ram[Globals.pc + 2], Globals.ram[Globals.pc + 3])
				Globals.pc += 4
				print("SPR run")
			IF:
				if (Globals.ram[Globals.pc + 1] == Globals.ram[Globals.pc + 2]):
					Globals.pc += Globals.ram[Globals.pc + 3]
				else :
					Globals.pc += 4
			_:
				print("Unknown opcode: ", opcode, " at PC: ", Globals.pc)
				Globals.pc += 1 



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
				bytecode.append(tokens[1].to_int() % 256)
				bytecode.append(tokens[2].to_int() / 256)
				bytecode.append(tokens[2].to_int() % 256)
			"JMP":
				bytecode.append(JMP)
				bytecode.append(tokens[1].to_int() / 256)
				bytecode.append(tokens[1].to_int() % 256)
			"SPR":
				bytecode.append(SPR)
				bytecode.append(tokens[1].to_int())
				bytecode.append(tokens[2].to_int())
				bytecode.append(tokens[3].to_int())
			"IF":
				bytecode.append(IF)
				bytecode.append(tokens[1].to_int())
				bytecode.append(tokens[2].to_int())
				bytecode.append(tokens[3].to_int())
			
	print("Bytecode length: ", bytecode.size())
	print("Bytecode: ", bytecode)
	return bytecode
