extends Node


var registers = []

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
	MOV_V_R
	#SPRFromspriteData
}

var instruction = PackedByteArray([0, 0, 0, 0])

var AssemblyFile
var AssemblyFileName: String
@export var hardware: Node

func _ready() -> void:
	AssemblyFile = FileAccess.get_file_as_string("user://" + AssemblyFileName)
	Globals.isStopped = false
	registers.resize(8)
	registers.fill(0)

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
		print("PC: ", Globals.pc, " Op: ", opcode, " Next: ", Globals.ram[Globals.pc+1])
		#print("PC: ", Globals.pc, " Opcode: ", opcode)
		cycles_this_frame += 1
		match opcode:
			MOV_R_V:
				var regind = Globals.ram[Globals.pc + 1] 
				if regind < 0 || regind >= registers.size():
					Globals.pc += 4
				else:
					registers[Globals.ram[Globals.pc + 1]] = Globals.ram[Globals.pc + 2]
					Globals.pc += 4
			STOP:
				Globals.isStopped = true
				Globals.pc += 1
			MOV_R_R:
				registers[Globals.ram[Globals.pc + 1]] = registers[Globals.ram[Globals.pc + 2]]
				Globals.pc += 3
			WRITE:
				var highByte = Globals.ram[Globals.pc + 1]
				var lowByte = Globals.ram[Globals.pc + 2]
				var addr = (highByte * 256) + lowByte
				Globals.ram[addr] = getCorrectValue(3)
				Globals.pc += 5
			ADD:
				var addr = Globals.ram[Globals.pc + 1]
				registers[addr] += getCorrectValue(2)
				Globals.pc += 4
			SUB:
				var addr = Globals.ram[Globals.pc + 1]
				registers[addr] = registers[addr] - getCorrectValue(2)
				Globals.pc += 4
			JMP:
				Globals.pc = (Globals.ram[Globals.pc + 1] * 256) + Globals.ram[Globals.pc + 2]
			SPR:
				spr(getCorrectValue(1), getCorrectValue(3),getCorrectValue(5))
				Globals.pc += 7
			IF:
				var val1 = getCorrectValue(1)
				var val2 = getCorrectValue(3)
				var pcInc = Globals.ram[Globals.pc + 5]
				if (val1 == val2):
					Globals.pc += 6
					print("Button Match")
				else :
					Globals.pc += 6 + pcInc
			MOV_V_R:
				var highByte = Globals.ram[Globals.pc+2]
				var lowByte =  Globals.ram[Globals.pc + 3]
				var addr = (highByte * 256) + lowByte
				registers[Globals.ram[Globals.pc + 1]] = Globals.ram[addr]
				Globals.pc += 4
			_:
				print("Unknown opcode: ", opcode, " at PC: ", Globals.pc)
				Globals.pc += 1 


# Note to self: This takes 2 bytes
func getCorrectValue(pcOffset: int) -> int:
	var mode = Globals.ram[Globals.pc + pcOffset]
	var value = Globals.ram[Globals.pc + pcOffset + 1]
	if mode == 1:
		return registers[Globals.ram[Globals.pc + pcOffset + 1]]
	return value



#func compile(source_code: String) -> PackedByteArray:#
	#var bytecode = PackedByteArray()
	#var lines = source_code.split("\n")
#
	#for line in lines:
		#line = line.strip_edges()
		#if line == "" or line.begins_with(";"): continue 
		#var tokens = line.replace(",", " ").split(" ", false)
		#var command = tokens[0].to_upper()
		#match command:
			#"MOV_R_V":
				#bytecode.append(MOV_R_V)
				#bytecode.append(tokens[1].replace("R", "").to_int() )
				#bytecode.append(tokens[2].to_int())
			#"STOP":
				#bytecode.append(STOP)
			#"MOV_R_R":
				#bytecode.append(MOV_R_R)
				#bytecode.append(tokens[1].replace("R", "").to_int())
				#bytecode.append(tokens[2].replace("R", "").to_int())
			#"WRITE":
				#bytecode.append(WRITE)
				#bytecode.append(tokens[1].to_int() / 256)
				#bytecode.append(tokens[1].to_int() % 256)
				#bytecode.append(tokens[2].to_int())
			#"ADD":
				#bytecode.append(ADD)
				#bytecode.append(tokens[1].replace("R", "").to_int())
				#bytecode.append(tokens[2].replace("R", "").to_int())
			#"SUB":
				#bytecode.append(SUB)
				#bytecode.append(tokens[1].to_int() / 256)
				#bytecode.append(tokens[1].to_int() % 256)
				#bytecode.append(tokens[2].to_int() / 256)
				#bytecode.append(tokens[2].to_int() % 256)
			#"JMP":
				#bytecode.append(JMP)
				#bytecode.append(tokens[1].to_int() / 256)
				#bytecode.append(tokens[1].to_int() % 256)
			#"SPR":
				#bytecode.append(SPR)
				#bytecode.append(tokens[1].to_int())
				#bytecode.append(tokens[2].to_int())
				#bytecode.append(tokens[3].to_int())
			#"IF":
				#bytecode.append(IF)
				#bytecode.append(tokens[1].to_int())
				#bytecode.append(tokens[2].to_int())
				#bytecode.append(tokens[3].to_int())
			#
	#print("Bytecode length: ", bytecode.size())
	#print("Bytecode: ", bytecode)
	#return bytecode
